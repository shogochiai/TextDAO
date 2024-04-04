// main.ts
import {
  CompileFailedError,
  CompileResult,
  compileSol,
  ASTReader,
  PathOptions,
  VariableDeclaration,
  assert
} from "solc-typed-ast";
import * as fs from 'fs';
import * as dotenv from "dotenv";
import { keccak256 } from 'js-sha3';
import * as BN from 'bn.js';
import { extractStorage, SlotKV, regexpStruct } from "./extractor";
import * as path from 'path';
const rootPath: string = path.resolve(__dirname + "/..");
dotenv.config({ path: `${rootPath}/.env` });




const TEXT_DAO_ADDR = process.env.TEXT_DAO_ADDR || "";

interface InputData {
  network: string;
  contractAddress: string;
  schemaPath: string;
  storagePath: string;
}

const INPUT_DATA: InputData = {
  network: "ethereum",
  contractAddress: TEXT_DAO_ADDR,
  schemaPath: `${rootPath}/src/textdao/storages/Schema.sol`,
  storagePath: `${rootPath}/src/_utils/Constants.sol`,
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
    
    if (this.belongsTo instanceof StructDefinition && this.belongsTo.parent instanceof IteratorItem) {
      // If the effective-prev is an IteratorItem (array element), use its slot ID directly
      parentSlotId = this.belongsTo.parent.slot;
    } else if (this.belongsTo instanceof StructDefinition && parentSlotId === null) {
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
      for (let i = 0; i < 2; i++) {
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
        if (currentParent.parent){
          // SkipStructDefinition with parent
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

  // Bug: prop[0].slotId and prop[1].slotId are conflicting.
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
  next(): StructDefinition | null {
    if (this.typeKind === TypeKind.NaiveStruct) {
      for (const node of global.AstNode) {
        if (node.nodeType === 'StructDefinition' && node.name === this.valueType) {
          const newStruct = new StructDefinition(node.name, null);
          newStruct.parent = this;
  
          // Get the parent IteratorItem's mappingKey
          let parentMappingKey = null;
          if (this.belongsTo instanceof IteratorItem) {
            parentMappingKey = this.belongsTo.mappingKey;
          }
  
          newStruct.members = node.members.map((member: any, index: number) => {
            const newMember = Member.fromASTNode(member, index, newStruct);
  
            // If the parent has a mappingKey, update the member's name to include it
            if (parentMappingKey !== null) {
              newMember.name = newMember.name.replace(/\[\d+\]/, `[${parentMappingKey}]`);
            }
  
            return newMember;
          });
  
          newStruct.members.forEach((member) => {
            member.slot = member.calculateSlot();
            if (member.iter) {
              member.iter.items.forEach((item) => {
                item.slot = item.calculateSlot();
  
                // If the parent has a mappingKey, update the item's name to include it
                if (parentMappingKey !== null) {
                  item.name = item.name.replace(/\[\d+\]/, `[${parentMappingKey}]`);
                }
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
      if (currentParent instanceof IteratorItem) {
        nameHierarchy = currentParent.getTypeAndName() + " >>> " + nameHierarchy;
        currentParent = (<Member>currentParent.belongsTo);
      } else if (currentParent instanceof Member) {
        nameHierarchy = currentParent.getTypeAndName() + " >>> " + nameHierarchy;
        currentParent = currentParent.belongsTo;
      } else if (currentParent instanceof StructDefinition) {
        if (currentParent.parent){
          let structAsMember = currentParent.parent;
          // skip adding StructDefinition data to hierarchy
          currentParent = currentParent.parent; // member
        } else {
          nameHierarchy = `${currentParent.name} _` + " >>> " + nameHierarchy;
          currentParent = null;  
        }
      } else {
      }
    }
    // console.log(nameHierarchy);

    return nameHierarchy;
  }

  getTypeAndName(): string {
    return `${this.valueType} ${this.name}`;
  }


}



async function execute(inputData: InputData): Promise<void> {
  let remappingStrs = fs.readFileSync(`${rootPath}/remappings.txt`).toString().split("\n");
  const result: CompileResult = await compileSol(inputData.schemaPath, "auto");
  const baseSlotResult: CompileResult = await compileSol(inputData.storagePath, "auto", <PathOptions>{ remapping: remappingStrs });
  
  const reader = new ASTReader();
  const sourceUnits = reader.read(result.data);

  const baseSlotReader = new ASTReader();
  const baseSlotSourceUnits = baseSlotReader.read(baseSlotResult.data);
  
  let baaeSlotObjects = baseSlotSourceUnits[0].children[1].children;
  let baseSlots = baaeSlotObjects.map(obj=>{
    if (obj instanceof VariableDeclaration) {
      return obj.raw.value.value;
    }
  });
  baseSlots = baseSlots.filter(slot => slot);
  // console.log(baseSlots);

  global.AstNode = sourceUnits[0].vContracts[0].raw.nodes;
  global.ResultStructs = [];
  
  // TODO: Check order and correspondence of definitions
  const RootStructs: StructDefinition[] = [];
  for (const node of global.AstNode) {
    if (node.nodeType === 'StructDefinition' && node.documentation && node.documentation.text.includes("@custom:storage-location erc7201:")) {
      const struct = new StructDefinition(node.name, baseSlots.shift() || null);
      RootStructs.push(struct);
    } else if (node.nodeType === 'StructDefinition' && node.documentation && node.documentation.text.includes("@custom:indexer-dsl erc7546:")) {
      /*
        [Natspec]
          @custom:indexer-dsl erc7546:method(EDFS, anotherMethodOutput)
        [Methods]
          setIteration(ProposeStorage.proposals, ProposeStorage.nextProposalId)
          setIteration(ProposeStorage.proposals[i].headers, ProposeStorage.proposals[i].headers.length)
          setUintKey(ConfigOverrideStorage.overrides, ConfigOverrideStorage.bytes4SigList)
        [Notes]
          A dynamic iterable without no setIteration causes runtime error in indexer.
          An UintKey-less address or bytes mappings cause runtime error in indexer.
      */

    }
  }

  for (const node of global.AstNode) {
    if (node.nodeType === 'StructDefinition' && node.documentation && node.documentation.text.includes("@custom:indexer-dsl erc7546:iteratorLength=")) {
      // get DSL and set meta const
    }
  }


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


const loggerFlag: boolean = false;
const loggerCond1: string = "proposals[2";
const loggerCond2: string = "tagIds[";
function logResult(): { [key: string]: SlotKV } {
  const uniqueAObjects = new Map();
  const uniqueBObjects = new Map();
  const uniqueCObjects = new Map();
  const edfsToSlotKV: { [key: string]: SlotKV } = {};

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
      if (loggerFlag && a.name.includes(loggerCond1) && a.name.includes(loggerCond2)) console.log(`${a.name}: ${a.slot}`);
      edfsToSlotKV[aKey] = {
        EDFS: aKey,
        slotId: a.slot,
        value: "", // Set the value property to an empty string or any appropriate default value
      };
    }

    a.members.forEach((b) => {
      const bKey = b.getEDFS();
      if (uniqueBObjects.has(bKey)) {
        const existingB = uniqueBObjects.get(bKey);
        if (isMoreContentful(b, existingB)) {
          uniqueBObjects.set(bKey, b);
          if (loggerFlag) console.log(`${bKey}: ${b.slot}`);
          edfsToSlotKV[bKey] = {
            EDFS: bKey,
            slotId: b.slot,
            value: "", // Set the value property to an empty string or any appropriate default value
          };
        }
      } else {
        uniqueBObjects.set(bKey, b);
        if (loggerFlag && bKey.includes(loggerCond1) && bKey.includes(loggerCond2)) console.log(`${bKey}: ${b.slot}`);
        edfsToSlotKV[bKey] = {
          EDFS: bKey,
          slotId: b.slot,
          value: "", // Set the value property to an empty string or any appropriate default value
        };
      }

      if (b.iter) {
        b.iter.items.forEach((c) => {
          const cKey = c.getEDFS();
          if (uniqueCObjects.has(cKey)) {
            const existingC = uniqueCObjects.get(cKey);
            if (isMoreContentful(c, existingC)) {
              uniqueCObjects.set(cKey, c);
              edfsToSlotKV[cKey] = {
                EDFS: cKey,
                slotId: c.slot,
                value: "", // Set the value property to an empty string or any appropriate default value
              };
            }
          } else {
            uniqueCObjects.set(cKey, c);
            edfsToSlotKV[cKey] = {
              EDFS: cKey,
              slotId: c.slot,
              value: "", // Set the value property to an empty string or any appropriate default value
            };
          }

          if (loggerFlag && cKey.includes(loggerCond1) && cKey.includes(loggerCond2)) console.log(`${cKey}: ${c.slot}`);
        });
      }
    });
  });

  return edfsToSlotKV;
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
  const slotKVs: { [key: string]: SlotKV } = logResult();

  const extractedSlots:{ [key: string]: SlotKV } = await extractStorage(INPUT_DATA.network, INPUT_DATA.contractAddress, slotKVs);
  Object.keys(extractedSlots).map(a=>{
    console.log(`${extractedSlots[a].EDFS}: ${extractedSlots[a].EDFS.split("[").length - 1} - ${extractedSlots[a].slotId} = ${extractedSlots[a].value}`);    
  })
})().catch(e=>{ console.error(e) });