import { keccak256 } from 'js-sha3';
import * as BN from 'bn.js';

export class BaseSlots {
    baseSlots: { [key: string]: string };

    constructor(_baseSlots: { [key: string]: string }) {
        this.baseSlots = _baseSlots;
    }
}

export class StructMember {
    name: string;
    type: string;
    index: number;
    isMapping: boolean;
    isArray: boolean;
    keyType: string | null;
    valueType: StructMember | null;
    slotId: string | null;
    parent: StructDefinition | null;
    children: StructMember[] | null;

    constructor(name: string, type: string, index: number, parent: StructDefinition | null) {
        this.name = name;
        this.type = type;
        this.index = index;
        this.isMapping = false;
        this.isArray = false;
        this.keyType = null;
        this.valueType = null;
        this.slotId = null;
        this.parent = parent;
        this.children = null;
    }

    static fromASTNode(node: any, index:number, parent: StructDefinition | null): StructMember {
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
        if (!typeStr && node.type) {
            typeStr = node.type.split(" ").length > 1 ? node.type.split(" ")[1] : node.type;
            typeStr = typeStr.split(".").length > 1 ? typeStr.split(".")[1] : typeStr;
        } else {
            if (node.typeDescriptions.typeString) {
                typeStr = node.typeDescriptions.typeString.split(" ").length > 1 ? node.typeDescriptions.typeString.split(" ")[1] : node.typeDescriptions.typeString;
                typeStr = typeStr.split(".").length > 1 ? typeStr.split(".")[1] : typeStr;    
            } else {
                // no chance
            }
        }

        let member = new StructMember(node.name, typeStr, index, parent);
        if (!member.type) {
            member.type = node.typeDescriptions+"[]";
        } else if (member.type.indexOf("=>") > 0) {
            console.log("=>") // => and undefined are in
        } else {
            if (!!node.typeName && node.typeName.keyType) {
                member.isMapping = true;
                member.keyType = node.typeName.keyType.typeDescriptions.typeString;
    
                const valueType = StructMember.fromASTNode({
                    name: '',
                    typeDescriptions: node.typeName.valueType.typeDescriptions,
                }, index, parent);
                member.valueType = valueType;
            } else if (node.nodeType === "ArrayTypeName") {
                // array element (primitive)
            } else if (member.type.indexOf("[]") >= 0) {
                // array itself
                member.isArray = true;
                member.keyType = "uint256";
    
                if (node.typeName.baseType.name) {
                    // primitive array
                    member.valueType = StructMember.fromASTNode({
                        name: node.name,
                        typeDescriptions: node.typeName.baseType.name,
                    }, index, parent);
                } else {
                    // struct array
        
                    member.valueType = StructMember.fromASTNode({
                        name: node.name,
                        typeDescriptions: typeStr,
                    }, index, parent);
                }
            } else {
                // primitives
            }
    
            return member;    
        }

    }

    calculateSlotId(key?:number | null): string {
        if (this.parent) {
            // If the parent's slotId is not calculated yet, calculate it first
            const parentSlotId = this.parent.slotId ? this.parent.slotId : this.parent.calculateSlotId();
    
            if (!!key && (this.isMapping || this.isArray)) {
                if (this.valueType === null) {
                    throw new Error('Mapping value type is null');
                }
                // Special rule for mappings and arrays
                const mappingSlot = calculateMappingSlot(key, parentSlotId);
                return this.valueType.calculateSlotId();
            } else {
                // Calculate slot ID based on parent's slot ID and member index
                const slotId = parentSlotId + this.index;
                this.slotId = slotId; // Cache the calculated slotId
                return slotId;
            }
        } else if (this.parent === null) {
            // This is the root StructDefinition
            const baseSlot = this.parent.baseSlot();
            this.slotId = baseSlot; // Cache the base slot
            return baseSlot;
        } else {
            throw new Error('Unable to calculate slot ID for this member');
        }
    }}

export class StructDefinition {
    name: string;
    members: StructMember[];
    baseSlots: BaseSlots;
    slotId: string | null;
    parent: StructDefinition | null;
    documentation: string | null;

    constructor(name: string, members: StructMember[], baseSlots: BaseSlots, parent: StructDefinition | null, documentation: string | null) {
        this.name = name;
        this.members = members;
        this.baseSlots = baseSlots;
        this.parent = parent;
        this.documentation = documentation;
        this.slotId = null;
    }

    static fromASTNode(node: any, baseSlots: BaseSlots, parentStruct: StructDefinition | null): StructDefinition {
        const members = node.members.map((memberNode: any, index: number) => {
            return StructMember.fromASTNode(memberNode, index, null);
        });
        const documentation = node.documentation ? node.documentation.text : null;
        const structDefinition = new StructDefinition(node.name, members, baseSlots, parentStruct, documentation);
        structDefinition.setParentForMembers();
        return structDefinition;
    }

    setParentForMembers() {
        this.members.forEach(member => {
            member.parent = this;
            if (member.children) {
                member.children.forEach(child => {
                    child.parent = this;
                });
            }
        });
    }

    baseSlot() {
        if (this.baseSlots.baseSlots[this.name]) {
            return this.baseSlots.baseSlots[this.name];
        } else {
            throw new Error(`${this.name} is not in BaseSlots.`);
        }
    }
    calculateSlotId():string{
        if (this.slotId) {
            return this.slotId;
        } else {
            if (this.documentation) {
                return this.baseSlot();
            } else {
                if (this.parent) {
                    if (this.parent.slotId) {
                        return this.parent.slotId;
                    } else {
                        return this.parent.calculateSlotId();
                    }        
                } else {
                    throw new Error(`<${this.name}> All StructMember and StructDefinition must have parent.`);
                }
            }
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
    const baseSlots = new BaseSlots({
        ProposeStorage: "0xf1a4d8eab6724b783b75a5c8d6b4a5edac1afaa52adaa7d3c57201451ce8c400",
        TextSaveProtectedStorage: "0x0a45678f7ac13226a0ead4e3b54db0ab263e1a30cc1ea3f19d7212aea5cd1d00",
        MemberJoinProtectedStorage: "0x2f8cab7d49dc616a0e8eb4e6f8b67d31c656445bf0c9ad5e38bc38d1128dcc00",
        VRFStorage: "0x67f28ff67f7d7020f2b2ac7c9bd5f2a6dd9f19a9b15d92c4070c4572728ab000",
        ConfigOverrideStorage: "0x531151f4103280746205c56419d2c949e0976d9ee39d3c364618181eba5ee500"
    });

    let rootStructDefinitions: StructDefinition[] = [];
    const structMap: { [key: string]: StructDefinition } = {};

    // Create a map of struct definitions and identify root structs
    // name => StructDefinition
    structs.forEach((struct: any) => {
        const structDefinition = StructDefinition.fromASTNode(struct, baseSlots, null);
        structMap[structDefinition.name] = structDefinition;
        if (structDefinition.documentation !== null) {
            rootStructDefinitions.push(structDefinition);
        }
    });

    // Set ref information for all Struct Definitions
    // Starting from root
    let structDefinitionsWithRef: StructDefinition[] = [];
    rootStructDefinitions.map(cursorDefinition => {
        structDefinitionsWithRef = dig(cursorDefinition, structMap, structDefinitionsWithRef);
    });

    return structDefinitionsWithRef;
}

// amend key
// get members and copy to children
// fill parent
// go to children digging
function dig(cursorDefinition: StructDefinition, structMap: { [key: string]: StructDefinition }, structDefinitionsWithRef: StructDefinition[]): StructDefinition[] {
    let childDefinition:StructDefinition | null;
    cursorDefinition.members.forEach(member => {
        // make member name from type info
        let tempKey;
        if (member.isMapping) {
            tempKey = member.valueType.type;
        } else if (member.isArray) {
            tempKey = member.type.split("[]").length > 1 ? member.type.split("[]")[0] : member.type;
        } else {
            tempKey = member.type.split(" ").length > 1 ? member.type.split(" ")[1] : member.type;
            tempKey = tempKey.split(".").length > 1 ? tempKey.split(".")[1] : tempKey;    
        }

        // get corresponding definition and fill info
        if (tempKey in structMap) {
            childDefinition = structMap[tempKey];
            childDefinition.parent = cursorDefinition;
            structDefinitionsWithRef = dig(childDefinition, structMap, structDefinitionsWithRef);
            structDefinitionsWithRef.push(childDefinition);
        }
    });

    return structDefinitionsWithRef;
}