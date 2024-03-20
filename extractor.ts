import { ethCallWithCodeOverride } from './ethCall';

const CONTRACT_ADDRESS = "0x5f5b80361460135780355481526020016001565b365ff3";
const CONTRACT_CODE = '0x5f5b80361460135780355481526020016001565b365ff3'; // Optimized contract code from the blog post

export async function extractStorage(slots: { [key: string]: string }): Promise<{ [key: string]: string }> {
    const batchSize = 15_000; // Maximum number of slots to fetch in a single batch
    const batches: string[][] = [];

    // Split the slots into batches
    const slotIds = Object.values(slots);
    for (let i = 0; i < slotIds.length; i += batchSize) {
        batches.push(slotIds.slice(i, i + batchSize));
    }
    const extractedSlots: { [key: string]: string } = {};
    const tasks = [];

    for (const batch of batches) {
        const calldata = '0x' + batch.map(slotId => slotId.slice(64).padStart(64, '0')).join('');

        tasks.push(ethCallWithCodeOverride(CONTRACT_ADDRESS, calldata, { code: CONTRACT_CODE }));
    }

    const results = await Promise.all(tasks);
    console.log(results);

    let offset = 0;
    for (const batch of batches) {
        const result = results[offset];
        for (let i = 0; i < batch.length; i++) {
            const slotName = Object.keys(slots).find(key => slots[key] === batch[i]);
            if (slotName) {
                const slotValue = '0x' + result.slice(i * 64, (i + 1) * 64);
                extractedSlots[slotName] = slotValue;
            }
        }
        offset++;
    }

    return extractedSlots;
}