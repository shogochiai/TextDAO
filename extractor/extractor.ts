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
  const slots = Object.values(slotKVs).map((slotKV) => slotKV.slotId);
  const EDFS = Object.keys(slotKVs);
  const batchSize = 15_000; // Maximum number of slots to fetch in a single batch
  const batches: string[][] = [];

  // Split the slots into batches
  for (let i = 0; i < slots.length; i += batchSize) {
    batches.push(slots.slice(i, i + batchSize));
  }

  const extractedSlots: { [key: string]: SlotKV } = {};

  for (const batch of batches) {
    const results: any = await ethCallWithCodeOverride(
      network,
      contractAddress,
      constructCalldata(batch),
      CONTRACT_CODE
    );

    const resultArray: string[] = results.toString(16).padStart(64, "0")

    for (let i = 0; i < batch.length; i++) {
      const slotId = batch[i];
      const EDFS = Object.keys(slotKVs).find(
        (key) => slotKVs[key].slotId === slotId
      );

      if (EDFS) {
        extractedSlots[EDFS] = {
          EDFS,
          slotId,
          value: resultArray[i],
        };
      }
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