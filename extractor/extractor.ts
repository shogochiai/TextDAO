import { ethCallWithCodeOverride } from './ethCall';
import { SlotsAndEDFS } from './slot';

const CONTRACT_CODE = '0x5f5b80361460135780355481526020016001565b365ff3'; // Optimized contract code from dedaub.com/blog/bulk-storage-extraction

export interface SlotKV {
    EDFS: string; // Entity-Document-Field Specifier
    slotId: string;
    value: string;
  }
  

export async function extractStorage(network: string, contractAddress: string, slotsAndEDFS: SlotsAndEDFS): Promise<{ [key: string]: SlotKV }> {
    const slots = slotsAndEDFS.slots;
    const EDFS = slotsAndEDFS.EDFS;
    const batchSize = 15_000; // Maximum number of slots to fetch in a single batch
    const batches: string[][] = [];

    // Split the slots into batches
    const slotIds = Object.values(slots);
    const extractedSlots: { [key: string]: SlotKV } = {};

    const results:any = await ethCallWithCodeOverride(network, contractAddress, constructCalldata(slotIds), CONTRACT_CODE);

    const resultArray: string[] = [];
    for (const result of results) {
        const resultString = result.toString(16).padStart(64, '0');
        resultArray.push(resultString);
    }
    for (let i = 0; i < slotIds.length; i++) {
        extractedSlots[EDFS[i]] = {
            EDFS: EDFS[i],
            slotId: slotIds[i],
            value: resultArray[i]
        };
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
        throw new Error(`Storage location ${slot} exceeds 32 bytes (${location.length/2} bytes)`);
      }
  
      // Reverse the byte order for big-endian
      location = location.match(/.{2}/g)!.reverse().join("");
  
      calldata += location;
    }
  
    return calldata;
  }