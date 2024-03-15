// Example function to read an AST from a JSON file
async function readStructFromABI(filePath:any) {
    const data = await JSON.parse(require("fs").readFileSync(filePath));
    const _library:any = data.ast.nodes.filter((c:any) => c.nodeType === 'ContractDefinition');
    // console.log(_library[0].nodes);
    return _library[0].nodes;
}

// Function to find and process structs (or any other elements)
function processStructs(ast:any) {
    const structs:any = ast.filter((c:any) => c.nodeType === 'StructDefinition');
    structs.forEach((struct:any) => {
        if (!!struct.documentation) {
            console.log(struct.documentation.text);
        }
        console.log(`struct ${struct.name} ${struct.members.length > 0 ? "{" : ""}`);

        struct.members.forEach((member:any) => {
            if (member.typeName.keyType) {
                console.log(
                "    mapping(" +
                    member.typeName.keyType.typeDescriptions.typeString
                    + " => " +
                    member.typeName.valueType.typeDescriptions.typeString
                + `) ${member.name};`
                );
            } else {
                console.log(`    ${member.typeDescriptions.typeString} ${member.name};`);
            }
        });
        if (struct.members.length > 0) {
            console.log("}");
            console.log("");
        }

        // TODO: Calc slots with https://hackmd.io/@kIid5I1TQM2sYFp03p5Mjw/BJb7LXxAa


        // TODO: Extract all slots' data with https://dedaub.com/blog/bulk-storage-extraction
    });
}


(async (_) => {
    // Assuming you've saved the AST to a file, replace 'path/to/ast.json' with your actual file path
    const ast:any = await readStructFromABI('out/StorageScheme.sol/StorageScheme.json');
    await processStructs(ast); 
})().then();