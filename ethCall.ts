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

const alchemyApiUrl = 'https://eth-mainnet.g.alchemy.com/v2/docs-demo';

export async function ethCallWithCodeOverride(
    network: string,
    contractAddress: string,
    data: string,
    stateOverride: { [key: string]: string } = {}
): Promise<string> {
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
        ...stateOverride,
      },
    ],
    id: chainList[network],
  };

  const response = await fetch(alchemyApiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const res = await response.json();
  return res.result;
}