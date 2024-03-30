import { keccak256 } from 'js-sha3';
import * as BN from 'bn.js';
import { StructDefinition, StructMember } from "./ast";

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

export interface SlotsAndEDFS {
    slots: { [key: string]: string };
    EDFS: string[];
}

export function calculateSlots(structDefinitions: StructDefinition[]): SlotsAndEDFS {
      const slots: { [key: string]: string } = {};
      const members: StructMember[] = [];
      const EDFS: string[] = [];
  
      for (const structDefinition of structDefinitions) {
          members.push(...collectMembers(structDefinition));
      }
  
      for (const member of members) {
          if (member.isMapping || member.isArray) {
              for(var i = 0; i < 10; i++) {
                  EDFS.push(`${member.name}[${i}]`);
                  slots[`${member.name}[${i}]`] = member.calculateSlotId(i);
              }
          } else {
            EDFS.push(`${member.name}`);
            slots[`${member.name}`] = member.calculateSlotId();
          }
      }
        
      return <SlotsAndEDFS>{ slots, EDFS };
  }
  
  function collectMembers(structDefinition: StructDefinition | StructMember): StructMember[] {
      const members: StructMember[] = [];
      let targets: StructMember[];
  
      if ((<any>structDefinition).children) {
          targets = (<any>structDefinition).children;
      } else {
          targets = (<any>structDefinition).members;
      }
  
      for (const member of targets) {
          members.push(<StructMember>member);
  
          if ((<StructMember>member).children) {
              members.push(...collectMembers(<StructMember>member));
          }
      }
  
      return members;
  }