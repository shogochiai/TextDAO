import * as fs from 'fs';
import { calculateSlots } from "./slot";
import { readStructFromABIJson } from "./ast";
import { extractStorage } from "./extractor";

interface InputData {
  network: string;
  contractAddress: string;
  abiJson: string;
}

const INPUT_DATA: InputData = {
  network: "ethereum",
  contractAddress: "<your target contract>",
  abiJson: fs.readFileSync('out/Schema.sol/Schema.json', 'utf-8')
};

(async () => {
  const storage = await getStorage(INPUT_DATA);
  console.log(storage);
})();

async function getStorage(inputData: InputData): Promise<{ [key: string]: string }> {
  const structDefinitions = await readStructFromABIJson(inputData.abiJson);
  const slots = calculateSlots(structDefinitions);
  const storage = await extractStorage(inputData.network, inputData.contractAddress, slots);
  return storage;
}