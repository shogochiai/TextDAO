import fetchPolyfill from 'node-fetch-polyfill';
import * as fs from 'fs';
import * as path from 'path';

interface Data {
  name: string;
}


function getChainList(): { [key:string]: number } {
    const filePath = path.join(__dirname, 'chainIds.json');
    const fileContent = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(fileContent);
}
const chainList = getChainList();

const globalThis: any = global;
globalThis.fetch = fetchPolyfill;

const apiUrl = 'http://127.0.0.1:8545';

export async function ethCallWithCodeOverride(
    network: string,
    contractAddress: string,
    data: string,
    contractCode: string
): Promise<any> {
  const payload = {
    jsonrpc: '2.0',
    method: 'eth_call',
    params: [
      {
        to: contractAddress,
        data,
        gas: '0x0',
        gasPrice: '0x9184e72a000',
        value: '0x0',
      },
      'latest', // or any other block number or tag
      // { code: contractCode } // stateOverride parameter
    ],
    id: chainList[network],
  };


  const response = await fetch(apiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const res = await response.json();
  console.log(res);
  return res.result;
}
