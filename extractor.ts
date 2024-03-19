import { calculateSlots } from "./slot";
import { StructDefinition, StructMember, BaseSlots, readStructFromABI } from "./ast";

(async (_) => {
    const structDefinitions = await readStructFromABI('out/StorageScheme.sol/StorageScheme.json');

    const slots = extractSlots(structDefinitions);

    console.log(slots);
})().then();

function extractSlots(structDefinitions: StructDefinition[]): { [key: string]: string } {
// function extractSlots(structDefinitions: StructDefinition[]): { [key: string]: StructMember } {
    // const slots: { [key: string]: StructMember } = {};
    const slots: { [key: string]: string } = {};
    const members: StructMember[] = [];

    for (const structDefinition of structDefinitions) {
        members.push(...collectMembers(structDefinition));
    }

    for (const member of members) {
        slots[member.name] = member.calculateSlotId();
    }


    return slots;
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