import * as fs from 'fs';
import { calculateSlots } from "./slot";
import { sortStructsByParentChild } from "./ast";
import { extractStorage } from "./extractor";
import { CompileFailedError, CompileResult, compileSol, ASTReader } from "solc-typed-ast";

interface InputData {
  network: string;
  contractAddress: string;
  schemaPath: string;
}

const INPUT_DATA: InputData = {
  network: "ethereum",
  contractAddress: "<your target contract>",
  schemaPath: "src/textdao/storages/Schema.sol"
};

(async () => {
  const storage = await getStorage(INPUT_DATA);
  console.log(storage);
})();


async function getStorage(inputData: InputData): Promise<{ [key: string]: string }> {
  const result:CompileResult = await compileSol(inputData.schemaPath, "auto");
  const reader = new ASTReader();
  const sourceUnits = reader.read(result.data);  
  const slots = calculateSlots(sortStructsByParentChild(sourceUnits[0].vContracts[0].raw.nodes));
  const storage = await extractStorage(inputData.network, inputData.contractAddress, slots);
  return storage;
}