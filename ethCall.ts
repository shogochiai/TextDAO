import fetchPolyfill from 'node-fetch-polyfill';
import * as fs from 'fs';
import * as path from 'path';

interface Data {
  name: string;
}


function getChainList(): { [key:string]: number } {
    const filePath = path.join(__dirname, 'chainIds.json');
    const fileContent = fs.readFileSync(filePath, 'utf-8')
    const idToNetwork = JSON.parse(fileContent);
    const networkToId = Object.fromEntries(Object.entries(idToNetwork).map(([k, v]) => [v, k]));
    return networkToId;
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
  let overrides = {};
  overrides[`${contractAddress}`] = { code: contractCode };

  const gasPrice = '0x45c77'; // got by gasEstimation 

  let payload:any = {
    jsonrpc: '2.0',
    method: 'eth_call',
    params: [
      {
        to: contractAddress,
        data,
        gas: '0x4C4B40', // 5,000,000 gas (less than block gas limit)
        gasPrice,
        value: '0x0',
      },
      'latest' // or any other block number or tag
    ],
    id: chainList[network],
  };
  payload.params.push(overrides);

  const response = await fetch(apiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const responseBody:any = await response.text();

  return JSON.parse(responseBody).result;
}
