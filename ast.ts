import { keccak256 } from 'js-sha3';
import * as BN from 'bn.js';

export class BaseSlots {
    baseSlots: { [key: string]: string };

    constructor(_baseSlots: { [key: string]: string }) {
        this.baseSlots = _baseSlots;
    }
}

class StructMember {
    name: string;
    type: string;
    isMapping: boolean;
    keyType: string | null;
    valueType: StructMember | null;
    slotId: string | null;
    parent: StructDefinition | null;

    constructor(name: string, type: string, parent: StructDefinition | null) {
        this.name = name;
        this.type = type;
        this.isMapping = false;
        this.keyType = null;
        this.valueType = null;
        this.slotId = null;
        this.parent = parent;
    }

    static fromASTNode(node: any, parent: StructDefinition | null): StructMember {
        let typeStr;
        if (node.typeDescriptions) {
            typeStr = node.typeDescriptions.typeString;
        } else if (node.valueType) {
            typeStr = node.valueType.name;
        }
        if (node.name === "") {
            typeStr = typeStr.split(" ").length > 1 ? typeStr.split(" ")[1] : typeStr;
            typeStr = typeStr.split(".").length > 1 ? typeStr.split(".")[1] : typeStr;
            node.name = typeStr;
        }

        let member = new StructMember(node.name, typeStr, parent);

        if (!!node.typeName && node.typeName.keyType) {
            member.isMapping = true;
            member.keyType = node.typeName.keyType.typeDescriptions.typeString;

            const valueType = StructMember.fromASTNode({
                name: '',
                typeDescriptions: node.typeName.valueType.typeDescriptions,
            }, parent);
            member.valueType = valueType;
        }

        return member;
    }

    calculateSlotId(parentSlotId: string | null = null, key: number | null = null): string {
        if (this.isMapping) {
            if (this.valueType === null) {
                throw new Error('Mapping value type is null');
            }
            return this.valueType.calculateSlotId(calculateMappingSlot(key!, parentSlotId!), key);
        } else if (this.type === 'address' || this.type === 'bytes32') {
            return parentSlotId !== null ? parentSlotId : '0x0';
        } else {
            let baseSlot = parentSlotId;
            if (baseSlot === null && this.parent !== null) {
                baseSlot = this.parent.baseSlot();
            }
            const hash = keccak256(baseSlot);
            return `0x${hash}`;
        }
    }
}

export class StructDefinition {
    name: string;
    members: StructMember[];
    baseSlots: BaseSlots;
    parent: StructDefinition | null;
    documentation: string | null;

    constructor(name: string, members: StructMember[], baseSlots: BaseSlots, parent: StructDefinition | null, documentation: string | null) {
        this.name = name;
        this.members = members;
        this.baseSlots = baseSlots;
        this.parent = parent;
        this.documentation = documentation;
    }

    static fromASTNode(node: any, baseSlots: BaseSlots, parentStruct: StructDefinition | null): StructDefinition {
        const members = node.members.map((memberNode: any) => StructMember.fromASTNode(memberNode, null));
        const documentation = node.documentation ? node.documentation.text : null;
        const structDefinition = new StructDefinition(node.name, members, baseSlots, parentStruct, documentation);
        structDefinition.setParentForMembers();
        return structDefinition;
    }

    setParentForMembers() {
        this.members.forEach(member => {
            member.parent = this;
        });
    }

    baseSlot() {
        if (this.parent === null) {
            return this.baseSlots.baseSlots[this.name] ? this.baseSlots.baseSlots[this.name] : '0x0';
        } else {
            return this.parent.baseSlot();
        }
    }
}

function calculateMappingSlot(key: number, baseSlot: string): string {
    if (key === null) {
        throw new Error('key is null');
    }
    if (baseSlot === null) {
        throw new Error('baseSlot is null');
    }
    const keyHex = new BN(key).toString(16);
    const encoded = `0x${keyHex}${baseSlot.slice(2)}`; // Simulate abi.encodePacked
    const hash = keccak256(encoded);
    return `0x${hash}`;
}

// Example function to read an AST from a JSON file
export async function readStructFromABI(filePath: any) {
    const data = await JSON.parse(require("fs").readFileSync(filePath));
    const _library: any = data.ast.nodes.filter((c: any) => c.nodeType === 'ContractDefinition');
    const _structs: any = _library[0].nodes.filter((c: any) => c.nodeType === 'StructDefinition');

    // Sort structs based on their parent-child relationships
    const sortedStructs = sortStructsByParentChild(_structs);

    return sortedStructs;
}

function sortStructsByParentChild(structs: any[]): StructDefinition[] {
    const baseSlots: BaseSlots = new BaseSlots({});
    const rootStructs: StructDefinition[] = [];
    const structMap: { [key: string]: StructDefinition } = {};

    // Create a map of struct definitions and identify root structs
    structs.forEach((struct: any) => {
        const structDefinition = StructDefinition.fromASTNode(struct, baseSlots, null);
        structMap[structDefinition.name] = structDefinition;
        if (structDefinition.documentation !== null) {
            rootStructs.push(structDefinition);
        }
    });

    // Set parent-child relationships for non-root structs
    Object.values(structMap).forEach((struct: StructDefinition) => {
        if (struct.documentation === null) {
            struct.members.forEach((member: StructMember) => {
                if (member.type in structMap) {
                    member.parent = structMap[member.type];
                }
            });
        }
    });

    return rootStructs;
}