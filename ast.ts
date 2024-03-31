import { keccak256 } from 'js-sha3';
import * as BN from 'bn.js';

export class BaseSlots {
    baseSlots: { [key: string]: string };

    constructor(_baseSlots: { [key: string]: string }) {
        this.baseSlots = _baseSlots;
    }
}
const baseSlots = new BaseSlots({
    ProposeStorage: "0xf1a4d8eab6724b783b75a5c8d6b4a5edac1afaa52adaa7d3c57201451ce8c400",
    TextSaveProtectedStorage: "0x0a45678f7ac13226a0ead4e3b54db0ab263e1a30cc1ea3f19d7212aea5cd1d00",
    MemberJoinProtectedStorage: "0x2f8cab7d49dc616a0e8eb4e6f8b67d31c656445bf0c9ad5e38bc38d1128dcc00",
    VRFStorage: "0x67f28ff67f7d7020f2b2ac7c9bd5f2a6dd9f19a9b15d92c4070c4572728ab000",
    ConfigOverrideStorage: "0x531151f4103280746205c56419d2c949e0976d9ee39d3c364618181eba5ee500"
});


export class StructMember {
    name: string;
    type: string;
    index: number; // as struct member
    isMapping: boolean;
    isArray: boolean;
    keyType: string | null;
    valueType: StructMember | null;
    slotId: string | null;
    parent: StructDefinition | null;

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

    calculateSlotId(mappingKey?:number | null): string {
        if (this.parent) {
            // If the parent's slotId is not calculated yet, calculate it first
            const parentSlotId = this.parent.slotId ? this.parent.slotId : this.parent.calculateSlotId();
    
            if (this.isMapping || this.isArray) {
                if (mappingKey >= 0) {
                    if (this.valueType === null) {
                        throw new Error('Mapping value type is null');
                    }
                    const slotIdHex = "0x" + (parseInt(parentSlotId, 16) + this.index).toString(16); // mapping base slot as a member
                    const mappingSlot = calculateMappingSlot(mappingKey, slotIdHex);
                    return mappingSlot;
                } else {
                    const slotIdHex = "0x" + (parseInt(parentSlotId, 16) + this.index).toString(16); // slot for a member
                    this.slotId = slotIdHex; // Cache the calculated slotId
                    return slotIdHex;
                }
            } else {
                // Calculate slot ID based on parent's slot ID and member index
                const slotIdHex = "0x" + (parseInt(parentSlotId, 16) + this.index).toString(16);
                this.slotId = slotIdHex; // Cache the calculated slotId
                return slotIdHex;
            }
        } else if (this.parent === null) {
            // This is the root StructDefinition
            const baseSlot = this.parent.baseSlot();
            this.slotId = baseSlot; // Cache the base slot
            return baseSlot;
        } else {
            throw new Error('Unable to calculate slot ID for this member');
        }
    }
    getTypeAndName(){
        if (this.parent) {
            if (this.isMapping) {
                return `mapping(${this.keyType} => ${this.valueType.type}) ${this.name}`;
            } else {
                return `${this.type} ${this.name}`;
            }
        } else if (this.parent === null) {
            return `${this.type} root`;
        } else {
            throw new Error('Unable to getTypeAndName slot ID for this member');
        }
    }
    getEDFS():string{
        let nameHierarchy = this.getTypeAndName();
        let currentParent : StructMember | StructDefinition = this.parent;

        while (currentParent !== null) {
            if (currentParent instanceof StructMember) {
                nameHierarchy = currentParent.getTypeAndName() + " >>> " + nameHierarchy;
                currentParent = currentParent.parent;    
            } else {
                // TODO: dictDefinitionToMember will solve finding member name here
                nameHierarchy = `${currentParent.name} _` + " >>> " + nameHierarchy;
                currentParent = currentParent.parent;
            }
        }

        return nameHierarchy;
    }
}

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

/*
/// mapping hash in ERC-7201 style
struct Data {　// baseSlot
    uint a;
    uint b;
    mapping(uint=>uint) elements;// index 2 ==> keccak256(abi.encode(mappingKey, baseSlot+2))
}
Data data;
*/
function calculateMappingSlot(mappingKey: number, mappingSlotIdAsMember: string): string {
    if (mappingKey === null) {
        throw new Error('key is null');
    }
    if (mappingSlotIdAsMember === null) {
        throw new Error('baseSlot is null');
    }
    const mappingKeyHex = new BN(mappingKey).toString(16);
    const encoded = `0x${mappingKeyHex}${mappingSlotIdAsMember.slice(2)}`; // Simulate abi.encodePacked
    const hash = keccak256(encoded);
    return `0x${hash}`;
}

export function sortStructsByParentChild(structs: any[]): StructDefinition[] {

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

    // structDefinitionsWithRef.push(...rootStructDefinitions);
    return structDefinitionsWithRef;


    // // Set ref information for all Struct Definitions
    // // Starting from root
    // let structDefinitionsWithRef: StructDefinition[] = [];
    // rootStructDefinitions.map(cursorDefinition => {
    //     structDefinitionsWithRef = dig(cursorDefinition, structMap, structDefinitionsWithRef);
    // });

    // // structDefinitionsWithRef.push(...rootStructDefinitions);
    // return structDefinitionsWithRef;
}


// amend key
// fill parent
// go to member digging
function dig(cursorDefinition: StructDefinition, structMap: { [key: string]: StructDefinition }, structDefinitionsWithRef: StructDefinition[]): StructDefinition[] {
    let childDefinition:StructDefinition | null;

    cursorDefinition.members.forEach(member => {    
        let tempKey;
        if (member.isMapping) {
            tempKey = member.valueType.type;
        } else if (member.isArray) {
            tempKey = member.type.split("[]").length > 1 ? member.type.split("[]")[0] : member.type;
        } else {
            tempKey = member.type.split(" ").length > 1 ? member.type.split(" ")[1] : member.type;
            tempKey = tempKey.split(".").length > 1 ? tempKey.split(".")[1] : tempKey;
        }

        // mapping member must be expanded to 10 items and all those must have each slotId

        // Only for struct-related members
        // get corresponding definition and fill info
        if (tempKey in structMap) {

            childDefinition = structMap[tempKey];
            // cursorDefinition = structMap[extractClassName(cursorDefinition.name)];

            if (member.isMapping) {
                // mapping element struct as a member
                for (let mappingKey = 0; mappingKey< 10; mappingKey++) {
                    let nthChildDefinition = deepCopy(childDefinition);
                    nthChildDefinition.name = `${nthChildDefinition.name}[${mappingKey}]`;
                    member.parent = cursorDefinition;

                    nthChildDefinition.parent = cursorDefinition;

                    const slotIdHex = "0x" + (parseInt(nthChildDefinition.parent.slotId, 16)).toString(16);
                    const mappingMemberSlot = calculateMappingSlot(mappingKey, slotIdHex);

                    nthChildDefinition.slotId = mappingMemberSlot;
                    structDefinitionsWithRef.push(nthChildDefinition);
                    structDefinitionsWithRef = dig(nthChildDefinition, structMap, structDefinitionsWithRef);
                }
            } else if (member.isArray) {
                // struct array
                for (let arrayIndex = 0; arrayIndex< 10; arrayIndex++) {
                    let nthChildDefinition = deepCopy(childDefinition);
                    nthChildDefinition.name = `${nthChildDefinition.name}[${arrayIndex}]`;
                    member.parent = cursorDefinition;
                    nthChildDefinition.parent = cursorDefinition;
                    const slotIdHex = "0x" + (parseInt(nthChildDefinition.parent.slotId, 16)).toString(16);
                    const mappingMemberSlot = calculateMappingSlot(arrayIndex, slotIdHex);

                    nthChildDefinition.slotId = mappingMemberSlot;
                    structDefinitionsWithRef.push(nthChildDefinition);
                    structDefinitionsWithRef = dig(nthChildDefinition, structMap, structDefinitionsWithRef);
                }
            } else {
                // naive struct as a member
                member.parent = cursorDefinition;
                childDefinition.parent = cursorDefinition;
                childDefinition.slotId = member.calculateSlotId();
                structDefinitionsWithRef.push(childDefinition);
                structDefinitionsWithRef = dig(childDefinition, structMap, structDefinitionsWithRef);    
            }
            // if root
            if (!cursorDefinition.parent) {
                if (!structDefinitionsWithRef.some(item => item.name === cursorDefinition.name)) {
                    structDefinitionsWithRef.push(cursorDefinition);
                }
            }

        } else {
            // 
        }
    });
    return structDefinitionsWithRef;
}
function deepCopy<T>(obj: T, cache?: WeakMap<any, any>): T {
    if (!cache) {
      cache = new WeakMap();
    }
  
    if (typeof obj !== 'object' || obj === null) {
      return obj;
    }
  
    // Check if the object has already been copied
    if (cache.has(obj)) {
      return cache.get(obj) as T;
    }
  
    let copy: any;
  
    if (obj instanceof Array) {
      copy = [];
      cache.set(obj, copy);
      copy = obj.map(item => deepCopy(item, cache));
    } else {
      copy = {};
      cache.set(obj, copy);
      for (const key in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, key)) {
          copy[key] = deepCopy((obj as { [key: string]: any })[key], cache);
        }
      }
    }
  
    return copy as T;
  }