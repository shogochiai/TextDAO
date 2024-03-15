import { keccak256 } from 'js-sha3';
import BN from 'bn.js';

// Convert a hex string to a BN object for arithmetic operations.
function hexToBN(hexString: string): BN {
  return new BN(hexString.slice(2), 16); // Remove the '0x' prefix.
}

// Calculate a slot for a mapping with a single key.
function calculateMappingSlot(key: number, baseSlot: string): string {
  const keyHex = new BN(key).toString(16);
  const encoded = `0x${keyHex}${baseSlot.slice(2)}`; // Simulate abi.encodePacked
  const hash = keccak256(encoded);
  return `0x${hash}`;
}

// Constants
const psBaseSlot = '0xf1a4d8eab6724b783b75a5c8d6b4a5edac1afaa52adaa7d3c57201451ce8c400';

// Additional slot calculations as per the list provided
const calculateSlots = (): { [key: string]: string } => {
  let slots: { [key: string]: string } = {};
  slots['psFirstProposal'] = calculateMappingSlot(0, psBaseSlot);
  slots['psNextProposalId'] = `0x${hexToBN(psBaseSlot).add(new BN(1)).toString(16)}`;

  // Base slot for subsequent calculations
  let nextProposalIdSlot = slots['psNextProposalId'];
  ['ExpiryDuration', 'TallyInterval', 'RepsNum', 'QuorumScore'].forEach((slotName, index) => {
    slots[`psc${slotName}`] = `0x${hexToBN(nextProposalIdSlot).add(new BN(index + 1)).toString(16)}`;
  });

  // For proposals, commands, tallies, meta, headers, commands actions, excluding ProposalMeta for "First" prefix
  let firstProposalSlot = slots['psFirstProposal'];
  ['Headers', 'Commands', 'Tallied', 'ProposalMeta'].forEach((slotName, index) => {
    slots[`psfp${slotName}`] = `0x${hexToBN(firstProposalSlot).add(new BN(index)).toString(16)}`;
    // Apply "First" prefix conditionally
    if (slotName !== 'ProposalMeta') {
      slots[`psfpFirst${slotName}`] = calculateMappingSlot(0, slots[`psfp${slotName}`]);
    }
  });

  let firstHeaderSlot = slots['psfpFirstHeaders'];
  slots['psfpfhId'] = firstHeaderSlot; // Same as psfpFirstHeaderSlot
  slots['psfpfhCurrentScore'] = `0x${hexToBN(firstHeaderSlot).add(new BN(1)).toString(16)}`;
  slots['psfpfhMetadataURI'] = `0x${hexToBN(firstHeaderSlot).add(new BN(2)).toString(16)}`;
  slots['psfpfhTagIds'] = `0x${hexToBN(firstHeaderSlot).add(new BN(3)).toString(16)}`;
  slots['psfpfhFirstTagId'] = calculateMappingSlot(0, slots['psfpfhTagIds']);

  let firstCommandSlot = slots['psfpFirstCommands'];
  slots['psfpfcId'] = firstCommandSlot;
  slots['psfpfcActions'] = `0x${hexToBN(firstCommandSlot).add(new BN(1)).toString(16)}`;
  slots['psfpfhFirstAction'] = calculateMappingSlot(0, slots['psfpfcActions']);
  slots['psfpfhfaFunc'] = slots['psfpfhFirstAction'];
  slots['psfpfhfaAbiParams'] = `0x${hexToBN(slots['psfpfhFirstAction']).add(new BN(1)).toString(16)}`;
  slots['psfpfcCurrentScore'] = `0x${hexToBN(firstCommandSlot).add(new BN(2)).toString(16)}`;

  let proposalMetaSlot = slots['psfpProposalMeta'];
  slots['psfppmCurrentScore'] = proposalMetaSlot;
  ['HeaderRank', 'CommandRank', 'NextHeaderTallyFrom', 'NextCmdTallyFrom', 'Reps', 'NextRepId', 'CreatedAt'].forEach((slotName, index) => {
    slots[`psfppm${slotName}`] = `0x${hexToBN(proposalMetaSlot).add(new BN(index + 1)).toString(16)}`;
  });

  slots['psfppmhrFirstHeaderRank'] = calculateMappingSlot(0, slots['psfppmHeaderRank']);
  slots['psfppmcrFirstCommandRank'] = calculateMappingSlot(0, slots['psfppmCommandRank']);
  slots['psfppmcrFirstRep'] = calculateMappingSlot(0, slots['psfppmReps']);

  return slots;
};


const slots = calculateSlots();
console.log(slots);


/*
---

In TypeScript, do that for all slot listed.
*/