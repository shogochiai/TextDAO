import { calculateSlots } from "./slot";
import { readStructFromABI } from "./ast";
import { extractStorage } from "./extractor";

(async (_) => {
    const structDefinitions = await readStructFromABI('out/Schema.sol/Schema.json');
    const slots = calculateSlots(structDefinitions);

    const storage = await extractStorage(slots);

    console.log(storage);
})().then();

