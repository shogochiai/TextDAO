import { assert } from "solc-typed-ast";
import { ethCallWithCodeOverride } from "./ethCall";

const CONTRACT_CODE = "0x5f5b80361460135780355481526020016001565b365ff3"; // Optimized contract code from dedaub.com/blog/bulk-storage-extraction

export interface SlotsAndEDFS {
  slots: { [key: string]: string };
  EDFS: string[];
}

export interface SlotKV {
  EDFS: string; // Entity-Document-Field Specifier
  slotId: string;
  value?: string | null;
}

export async function extractStorage(
  network: string,
  contractAddress: string,
  slotKVs: { [key: string]: SlotKV }
): Promise<{ [key: string]: SlotKV }> {
  // console.log(Object.values(slotKVs).map((slotKV) => slotKV.EDFS));
  const slots = Object.values(slotKVs).map((slotKV) => slotKV.slotId);
  const EDFS = Object.keys(slotKVs);
  const batchSize = 5000; // Maximum number of slots to fetch in a single batch
  const batches: string[][] = [];

  assert(slots.length == EDFS.length, "same length");

  // Split the slots into batches
  for (let i = 0; i < slots.length; i += batchSize) {
    batches.push(slots.slice(i, i + batchSize));
  }


  const extractedSlots: { [key: string]: SlotKV } = {};
  for (const batch of batches) {
      const _calldata = constructCalldata(batch);
      if (_calldata.length > 379010 /* We knew this number from experiments */) {
        throw new Error("Too large.");
      }

      const results: any = await ethCallWithCodeOverride(
        network,
        contractAddress,
        _calldata,
        CONTRACT_CODE
      );

      const resultStr: string = results.toString(16).padStart(64, "0")
      const resultArray = resultStr.slice(2).match(/.{64}/g);

      assert(batch.length == resultArray.length, `batch.length:${batch.length} resultArray.length:${resultArray.length}`);

      for (let i = 0; i < batch.length; i++) {
        const slotId = batch[i];

        // TODO: squashing DO happens because intermediate-unused node must be squashed.
        const matchedSlotKVs = {}; 
        Object.keys(slotKVs)
          .filter(slotKVKey=> slotKVs[slotKVKey].slotId === slotId )
          .map(slotKVKey=>{
            matchedSlotKVs[slotKVKey] = {};
            const edfsPath = slotKVKey.split(" >>> ");
            const lastNode = edfsPath[edfsPath.length - 1];
            const isIteratorItem: boolean = lastNode.includes("[");
            const isNonIteratorStruct:boolean = regexpStruct(lastNode)[0].charAt(0) === regexpStruct(lastNode)[0].charAt(0).toUpperCase();
            if (isIteratorItem) {
              matchedSlotKVs[slotKVKey]["1st"] = slotKVKey;
            } else if (isNonIteratorStruct) {
              matchedSlotKVs[slotKVKey]["2nd"] = slotKVKey;
            } else {
              matchedSlotKVs[slotKVKey]["other"] = slotKVKey;
            }
            return slotKVKey;
          })
          .map(slotKVKey=>{
            if (matchedSlotKVs[slotKVKey]["1st"]) {
              extractedSlots[matchedSlotKVs[slotKVKey]["1st"]] = {
                EDFS: matchedSlotKVs[slotKVKey]["1st"],
                slotId,
                value: resultArray[i],
              };
            } else if (matchedSlotKVs[slotKVKey]["2nd"]) {
              extractedSlots[matchedSlotKVs[slotKVKey]["2nd"]] = {
                EDFS: matchedSlotKVs[slotKVKey]["2nd"],
                slotId,
                value: resultArray[i],
              };
            } else if (matchedSlotKVs[slotKVKey]["other"]) {
              extractedSlots[matchedSlotKVs[slotKVKey]["other"]] = {
                EDFS: matchedSlotKVs[slotKVKey]["other"],
                slotId,
                value: resultArray[i],
              };
            } else {
              throw new Error("No slot match.");
            }
          })

      }
      if (batch !== batches[batches.length - 1]) {
        await new Promise(resolve => setTimeout(resolve, 3000)); // Wait for 3 seconds before the next call
      }
  }

  return extractedSlots;
}

function constructCalldata(slots: string[]): string {
  let calldata = "0x";
  for (const slot of slots) {
    // Remove the "0x" prefix if present
    let location = slot.replace(/^0x/, "");

    // Ensure the length is 64 characters (32 bytes)
    if (location.length < 64) {
      location = location.padStart(64, "0");
    } else if (location.length > 64) {
      throw new Error(
        `Storage location ${slot} exceeds 32 bytes (${
          location.length / 2
        } bytes)`
      );
    }

    // Reverse the byte order for big-endian
    location = location.match(/.{2}/g)!.reverse().join("");

    calldata += location;
  }

  return calldata;
}

export function regexpStruct(str: string): string[] {
  if (!str) throw new Error("Empty input to regexpStruct");
  let matched = str.match(/^struct\s+\w+\.(\w+)/)?.slice(1, 3);
  if (matched) {
    return matched;
  } else {
    return [str];
  }
}
