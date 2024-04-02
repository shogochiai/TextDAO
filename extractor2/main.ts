// main.ts
import {
  CompileFailedError,
  CompileResult,
  compileSol,
  ASTReader,
} from "solc-typed-ast";
import * as dotenv from "dotenv";
import { keccak256 } from 'js-sha3';
import * as BN from 'bn.js';

dotenv.config();
const TEXT_DAO_ADDR = process.env.TEXT_DAO_ADDR || "";

interface InputData {
  network: string;
  contractAddress: string;
  schemaPath: string;
}

const INPUT_DATA: InputData = {
  network: "ethereum",
  contractAddress: TEXT_DAO_ADDR,
  schemaPath: "../src/textdao/storages/Schema.sol",
};


class StructDefinition {
  members: Member[];
  parent: Member | IteratorItem | null;
  constructor(public name: string, public slot: string | null) {
    this.members = [];
    // 1. Search corresponding name Struct from with global.AstNode and instantiate this object
    // 2. By using global.AstNode's members of the struct, create Member objects and store that to this.members
    // 3. By using global.AstNode's members Array and Mapping information, create IteratorItem objects and put them to each iterable Member object
    // 4. As mentioned in Member.next() and IteratorItem.next() explanation, calculate slotId of members and iteratorItems and memo-nize it to those object itself

    for (const node of global.AstNode) {
      if (node.nodeType === 'StructDefinition' && node.name === this.name) {
        this.members = node.members.map((member: any, index: number) => Member.fromASTNode(member, index, this));
        this.members.forEach((member) => {
          member.slot = member.calculateSlot();
          if (member.iter) {
            member.iter.items.forEach((item) => {
              item.slot = item.calculateSlot();
            });
          }
        });
        break;
      }
    }
  }

  prev(): Member | null {
    if (global.ResultStructs.length === 0) {
      throw new Error("ResultStructs is not filled yet.");
    }
    for (const struct of global.ResultStructs) {
      for (const member of struct.members) {
        if (member.typeKind === TypeKind.NaiveStruct && member.valueType === this.name) {
          return member;
        } else if (member.typeKind === TypeKind.Mapping || member.typeKind === TypeKind.Array) {
          for (const item of member.iter.items) {
            if (item.typeKind === TypeKind.NaiveStruct && item.valueType === this.name) {
              return item;
            }
          }
        }
      }
    }
    return null;
  }
}



enum TypeKind {
  Mapping,
  Array,
  NaiveStruct,
  Primitive
}

class Member {
  constructor(
    public name: string,
    public typeKind: TypeKind,
    public valueType: string,
    public structIndex: number,
    public slot: string,
    public belongsTo: Member | StructDefinition,
    public iter: IteratorMeta | null
  ) {}

  calculateSlot(): string {
    let parentSlotId = this.belongsTo.slot;
    if (this.belongsTo instanceof StructDefinition && parentSlotId === null) {
      // member-structDef->member reference
      let parentMember:Member = this.belongsTo.prev();
      if (parentMember === null) {
        throw new Error(`No prev() with the parent ${this.belongsTo.name}`);
      }
  
      parentSlotId = parentMember.slot;
    }
    if (parentSlotId === null) {
      throw new Error('Parent slot ID is null');
    }

    const slotIdHex = "0x" + new BN(parentSlotId.slice(2), 16).add(new BN(this.structIndex)).toString(16);
    return slotIdHex;
  }

  next(): StructDefinition | null {
    if (this.typeKind === TypeKind.NaiveStruct) {
      for (const struct of global.ResultStructs) {
        if (struct.name === this.valueType) {
          return struct;
        }
      }

      for (const node of global.AstNode) {
        if (node.nodeType === 'StructDefinition' && node.name === this.valueType) {
          const newStruct = new StructDefinition(node.name, null);
          newStruct.parent = this;
          newStruct.members = node.members.map((member: any, index: number) => Member.fromASTNode(member, index, newStruct));
          newStruct.members.forEach((member) => {
            member.slot = member.calculateSlot();
            if (member.iter) {
              member.iter.items.forEach((item) => {
                item.slot = item.calculateSlot();
              });
            }
          });
          global.ResultStructs.push(newStruct);
          return newStruct;
        }
      }
    }
    return null;
  }

  static fromASTNode(node: any, index: number, parent: Member | StructDefinition): Member {
    let typeStr;
    let keyTypeStr;
    let valueTypeStr;
    let typeKind: TypeKind;

    if (node.typeName) {
      if (node.typeName.nodeType === "ElementaryTypeName") {
        if (node.typeName.typeDescriptions) {
          typeStr = node.typeName.typeDescriptions.typeString;
          typeKind = TypeKind.Primitive;
        } else {
          throw new Error("No typeString.");
        }
      } else if (node.typeName.nodeType === "Mapping") {
        keyTypeStr = node.typeName.keyType.typeDescriptions.typeString;
        valueTypeStr = regexpStruct(node.typeName.valueType.typeDescriptions.typeString)[0];
        typeStr = `mapping(${keyTypeStr} => ${valueTypeStr})`;
        typeKind = TypeKind.Mapping;
      } else if (node.typeName.nodeType === "UserDefinedTypeName") {
        typeStr = regexpStruct(node.typeName.typeDescriptions.typeString)[0];
        typeKind = TypeKind.NaiveStruct;
      } else if (node.typeName.nodeType === "ArrayTypeName") {
        keyTypeStr = "uint256";
        valueTypeStr = regexpStruct(node.typeName.baseType.typeDescriptions.typeString)[0];
        typeStr = `${valueTypeStr}[]`;
        typeKind = TypeKind.Array;
      } else {
        throw new Error("No nodeType.");
      }
    } else {
      if (node.typeDescriptions) {
        typeStr = regexpStruct(node.typeDescriptions.typeString)[0];
        typeKind = TypeKind.NaiveStruct;
      } else {
        throw new Error("No typeString.");
      }
    }
    if (node.name === "") node.name = typeStr;


    let member = new Member(node.name, typeKind, valueTypeStr, index, null, parent, null);

    member.slot = member.calculateSlot();

    // TODO: Mapping of Mapping, Mapping of Array, Array of Array
    if (member.typeKind === TypeKind.Array || member.typeKind === TypeKind.Mapping) {
      let items: IteratorItem[] = [];
      let iterTypeKind: TypeKind;
      if (member.valueType.charAt(0) === member.valueType.charAt(0).toUpperCase()) {
        iterTypeKind = TypeKind.NaiveStruct;
      } else {
        iterTypeKind = TypeKind.Primitive;
      }
      for (let i = 0; i < 10; i++) {
        let newItem = new IteratorItem(`${member.name}[${i}]`, iterTypeKind, valueTypeStr, index, "", member, `${i}`);
        newItem.slot = newItem.calculateSlot();
        items.push(newItem);
      }
      member.iter = new IteratorMeta(keyTypeStr, items);
      member.valueType = valueTypeStr;
    } else {
      member.valueType = typeStr;
    }

    return member;
  }

  getEDFS(): string {
    let nameHierarchy = this.getTypeAndName();
    let currentParent: Member | StructDefinition = this.belongsTo;

    while (currentParent !== null) {
      if (currentParent instanceof Member) {
        nameHierarchy = currentParent.getTypeAndName() + " >>> " + nameHierarchy;
        currentParent = currentParent.belongsTo;
      } else {
        // TODO: dictDefinitionToMember will solve finding member name here
        if (currentParent.parent){
          // nameHierarchy = `${currentParent.parent.valueType} ${currentParent.parent.name}` + " >>> " + nameHierarchy;
          currentParent = currentParent.parent;  
        } else {
          nameHierarchy = `${currentParent.name} _` + " >>> " + nameHierarchy;
          currentParent = null;  
        }
      }
    }

    return nameHierarchy;
  }

  getTypeAndName(): string {
    return `${this.valueType} ${this.name}`;
  }
}

class IteratorMeta {
  constructor(public keyType: string | null, public items: IteratorItem[]) {}
}

class IteratorItem extends Member {
  constructor(
    public name: string,
    public typeKind: TypeKind,
    public valueType: string,
    public structIndex: number,
    public slot: string,
    public belongsTo: Member | StructDefinition,
    public mappingKey: string | null
  ) {
    super(name, typeKind, valueType, structIndex, slot, belongsTo, null);
  }

  calculateSlot(): string {
    const parentSlotId = this.belongsTo.slot;
    if (parentSlotId === null || this.mappingKey === null) {
      throw new Error('Parent slot ID or mapping key is null');
    }

    const mappingSlot = calculateMappingSlot(parseInt(this.mappingKey), parentSlotId);
    return mappingSlot;
  }

  // 1. Create new StructDefinition on-the-fly with AstNode global variable and register that StructDefinition to StructDefinitionDictionary global variable.
  // 2. Calculate all members's slotId and all iterItems' slotId on-the-fly and memo-nize it to corresponding members' or items' slotId field.
  // 3. Return the newly createdStructDefinition
  // TODO: Implement creation of new StructDefinition based on the valueType
  next(): StructDefinition | null {
    if (this.typeKind === TypeKind.NaiveStruct) {
      for (const struct of global.ResultStructs) {
        if (struct.name === this.valueType && struct.parent.mappingKey === this.mappingKey) {
          return struct;
        }
      }

      for (const node of global.AstNode) {
        if (node.nodeType === 'StructDefinition' && node.name === this.valueType) {
          const newStruct = new StructDefinition(node.name, null);
          newStruct.parent = this;
          newStruct.members = node.members.map((member: any, index: number) => Member.fromASTNode(member, index, newStruct));
          newStruct.members.forEach((member) => {
            member.slot = member.calculateSlot();
            if (member.iter) {
              member.iter.items.forEach((item) => {
                item.slot = item.calculateSlot();
              });
            }
          });
          global.ResultStructs.push(newStruct);
          return newStruct;
        }
      }
    }
    return null;
  }

  getEDFS(): string {
    let nameHierarchy = this.getTypeAndName();
    let currentParent: Member | StructDefinition = this.belongsTo;

    while (currentParent !== null) {
      if (currentParent instanceof Member) {
        nameHierarchy = currentParent.getTypeAndName() + " >>> " + nameHierarchy;
        currentParent = currentParent.belongsTo;
      } else {
        // TODO: dictDefinitionToMember will solve finding member name here
        if (currentParent.parent){
          nameHierarchy = `${currentParent.parent.valueType} ${currentParent.parent.name}` + " >>> " + nameHierarchy;
          currentParent = currentParent.parent;  
        } else {
          nameHierarchy = `${currentParent.name} _` + " >>> " + nameHierarchy;
          currentParent = null;  
        }
      }
    }

    return nameHierarchy;
  }

  getTypeAndName(): string {
    return `${this.valueType} ${this.name}`;
  }


}



async function execute(inputData: InputData): Promise<void> {
  const result: CompileResult = await compileSol(inputData.schemaPath, "auto");
  const reader = new ASTReader();
  const sourceUnits = reader.read(result.data);
  global.AstNode = sourceUnits[0].vContracts[0].raw.nodes;
  global.ResultStructs = [];
  
  const RootStructs: StructDefinition[] = [
    new StructDefinition(
      "ProposeStorage",
      "0xf1a4d8eab6724b783b75a5c8d6b4a5edac1afaa52adaa7d3c57201451ce8c400"
    ),
    new StructDefinition(
      "TextSaveProtectedStorage",
      "0x0a45678f7ac13226a0ead4e3b54db0ab263e1a30cc1ea3f19d7212aea5cd1d00"
    ),
    new StructDefinition(
      "MemberJoinProtectedStorage",
      "0x2f8cab7d49dc616a0e8eb4e6f8b67d31c656445bf0c9ad5e38bc38d1128dcc00"
    ),
    new StructDefinition(
      "VRFStorage",
      "0x67f28ff67f7d7020f2b2ac7c9bd5f2a6dd9f19a9b15d92c4070c4572728ab000"
    ),
    new StructDefinition(
      "ConfigOverrideStorage",
      "0x531151f4103280746205c56419d2c949e0976d9ee39d3c364618181eba5ee500"
    ),
  ];

  RootStructs.forEach((rootStruct) => {
    global.ResultStructs.push(rootStruct);
    dig(rootStruct);
  });
}

function dig(struct: StructDefinition) {
  struct.members.forEach((member) => {
    if (member.iter) {
      member.iter.items.forEach((item, i) => {
        if (item.typeKind !== TypeKind.Primitive) {
          let newStruct = item.next();
          global.ResultStructs.push(newStruct);
          dig(newStruct); 
        }
      });
    } else {
      if (member.typeKind !== TypeKind.Primitive) {
        let newStruct = member.next();
        global.ResultStructs.push(newStruct);
        dig(newStruct);
      }
    }
  });
}

function calculateMappingSlot(mappingKey: number, mappingSlotIdAsMember: string): string {
  if (mappingSlotIdAsMember === null) {
    throw new Error('baseSlot is null');
  }
  const mappingKeyHex = new BN(mappingKey).toString(16);
  const encoded = `0x${mappingKeyHex}${mappingSlotIdAsMember.slice(2)}`; // Simulate abi.encodePacked
  const hash = keccak256(encoded);
  return `0x${hash}`;
}

function regexpStruct(str: string): string[] {
  if (!str) throw new Error("Empty input to regexpStruct");
  let matched = str.match(/^struct\s+\w+\.(\w+)/)?.slice(1, 3);
  if (matched) {
    return matched;
  } else {
    return [str];
  }
}

function logResult() {
  const uniqueAObjects = new Map();
  const uniqueBObjects = new Map();
  const uniqueCObjects = new Map();

  global.ResultStructs.forEach((a) => {
    const aKey = a.name;
    if (uniqueAObjects.has(aKey)) {
      const existingA = uniqueAObjects.get(aKey);
      if (isMoreContentful(a, existingA)) {
        uniqueAObjects.set(aKey, a);
      }
    } else {
      uniqueAObjects.set(aKey, a);
    }

    if (a.slot) {
      console.log(`${a.name}: ${a.slot}`);
    }

    a.members.forEach((b) => {
      const bKey = b.getEDFS();
      if (uniqueBObjects.has(bKey)) {
        const existingB = uniqueBObjects.get(bKey);
        if (isMoreContentful(b, existingB)) {
          uniqueBObjects.set(bKey, b);
          console.log(`${bKey}: ${b.slot}`);
        }
      } else {
        uniqueBObjects.set(bKey, b);
        console.log(`${bKey}: ${b.slot}`);
      }

      if (b.iter) {
        b.iter.items.forEach((c) => {
          const cKey = c.getEDFS();
          if (uniqueCObjects.has(cKey)) {
            const existingC = uniqueCObjects.get(cKey);
            if (isMoreContentful(c, existingC)) {
              uniqueCObjects.set(cKey, c);
            }
          } else {
            uniqueCObjects.set(cKey, c);
          }

          console.log(`${cKey}: ${c.slot}`);
        });
      }
    });
  });
}

function isMoreContentful(obj1, obj2) {
  const simplified1 = simplifyObject(obj1);
  const simplified2 = simplifyObject(obj2);
  return JSON.stringify(simplified1).length > JSON.stringify(simplified2).length;
}

function simplifyObject(obj) {
  const simplified = {};

  for (const key in obj) {
    if (obj.hasOwnProperty(key)) {
      const value = obj[key];

      if (key === 'belongsTo' || key === 'parent') {
        // Exclude circular reference properties
        continue;
      }

      if (Array.isArray(value)) {
        simplified[key] = value.map(simplifyObject);
      } else if (typeof value === 'object' && value !== null) {
        simplified[key] = simplifyObject(value);
      } else {
        simplified[key] = value;
      }
    }
  }

  return simplified;
}

(async () => {
  await execute(INPUT_DATA);
  logResult();
})().catch(e=>{ console.error(e) });