import fetchPolyfill from 'node-fetch-polyfill';

const globalThis: any = global;
globalThis.fetch = fetchPolyfill;

const alchemyApiUrl = 'https://eth-mainnet.g.alchemy.com/v2/docs-demo';

export async function ethCallWithCodeOverride(
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
    id: 1,
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