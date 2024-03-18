import { calculateSlots } from "./slot";
import { StructDefinition, BaseSlots, readStructFromABI } from "./ast";

(async (_) => {
    const baseSlots = new BaseSlots({
        ProposeStorage: "0xf1a4d8eab6724b783b75a5c8d6b4a5edac1afaa52adaa7d3c57201451ce8c400",
        TextSaveProtectedStorage: "0x0a45678f7ac13226a0ead4e3b54db0ab263e1a30cc1ea3f19d7212aea5cd1d00",
        MemberJoinProtectedStorage: "0x2f8cab7d49dc616a0e8eb4e6f8b67d31c656445bf0c9ad5e38bc38d1128dcc00",
        VRFStorage: "0x67f28ff67f7d7020f2b2ac7c9bd5f2a6dd9f19a9b15d92c4070c4572728ab000",
        ConfigOverrideStorage: "0x531151f4103280746205c56419d2c949e0976d9ee39d3c364618181eba5ee500"
    });

    const structDefinitionNodes = await readStructFromABI('out/StorageScheme.sol/StorageScheme.json');
    structDefinitionNodes.forEach(structDefinitionNode => {
        const structDefinition = StructDefinition.fromASTNode(structDefinitionNode, baseSlots, null);

        for (const member of structDefinition.members) {
            const slotId = member.calculateSlotId();
            console.log(`${structDefinition.name}.${member.name}: ${slotId}`);
        }
            
    });

})().then();