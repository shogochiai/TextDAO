import * as fs from 'fs';
import { calculateSlots, SlotsAndEDFS } from "./slot";
import { sortStructsByParentChild } from "./ast";
import { extractStorage, SlotKV } from "./extractor";
import { CompileFailedError, CompileResult, compileSol, ASTReader } from "solc-typed-ast";
import * as dotenv from 'dotenv';
dotenv.config();
const TEXT_DAO_ADDR = process.env.TEXT_DAO_ADDR || '';

interface InputData {
  network: string;
  contractAddress: string;
  schemaPath: string;
}

const INPUT_DATA: InputData = {
  network: "ethereum",
  contractAddress: TEXT_DAO_ADDR,
  schemaPath: "../src/textdao/storages/Schema.sol"
};

(async () => {
  const storage = await getStorage(INPUT_DATA);
  // console.log(Object.keys(storage).join("\n"));
})();


async function getStorage(inputData: InputData): Promise<{ [key: string]: SlotKV }> {
  const result:CompileResult = await compileSol(inputData.schemaPath, "auto");
  const reader = new ASTReader();
  const sourceUnits = reader.read(result.data);  
  const slotsAndEDFS:SlotsAndEDFS = calculateSlots(sortStructsByParentChild(sourceUnits[0].vContracts[0].raw.nodes));

  const storage: { [key: string]: SlotKV } = await extractStorage(inputData.network, inputData.contractAddress, slotsAndEDFS);
  return storage;
}