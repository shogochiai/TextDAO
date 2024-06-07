// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import { console2 } from "forge-std/console2.sol";
import { MCDevKit } from "@devkit/MCDevKit.sol";
import { MCScript } from "@devkit/MCScript.sol";

import { Clone } from "@mc-std/functions/Clone.sol";
import { Initialize } from "bundle/textDAO/functions/onlyonce/Initialize.sol";
import { Propose } from "bundle/textDAO/functions/Propose.sol";
import { Fork } from "bundle/textDAO/functions/Fork.sol";
import { Vote } from "bundle/textDAO/functions/Vote.sol";
import { Tally } from "bundle/textDAO/functions/Tally.sol";
import { Execute } from "bundle/textDAO/functions/Execute.sol";
import { Getter } from "bundle/textDAO/functions/Getter.sol";
import { MemberJoinProtected } from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";
import { SetConfigsProtected } from "bundle/textDAO/functions/protected/SetConfigsProtected.sol";
import { ConfigOverrideProtected } from "bundle/textDAO/functions/protected/ConfigOverrideProtected.sol";
import { SaveTextProtected } from "bundle/textDAO/functions/protected/SaveTextProtected.sol";
import { TextDAOFacade } from "bundle/textDAO/interfaces/TextDAOFacade.sol";

contract Deployment is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {

        vm.deal(deployer, 100 ether);


        address voteAddr = address(new Vote());
        mc.init("textdao");
        mc.use("Clone", Clone.clone.selector, address(new Clone()));
        mc.use("Initialize", Initialize.initialize.selector, address(new Initialize()));
        mc.use("Propose", Propose.propose.selector, address(new Propose()));
        mc.use("Fork", Fork.fork.selector, address(new Fork()));
        mc.use("VoteHeaders", Vote.voteHeaders.selector, voteAddr);
        mc.use("VoteCmds", Vote.voteCmds.selector, voteAddr);
        mc.use("Tally", Tally.tally.selector, address(new Tally()));
        mc.use("Execute", Execute.execute.selector, address(new Execute()));
        mc.use("MemberJoinProtected", MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
        mc.use("SetConfigsProtected", SetConfigsProtected.setProposalsConfig.selector, address(new SetConfigsProtected()));
        mc.use("ConfigOverrideProtected", ConfigOverrideProtected.overrideProposalsConfig.selector, address(new ConfigOverrideProtected()));
        mc.use("SaveTextProtected", SaveTextProtected.saveText.selector, address(new SaveTextProtected()));

        address getter = address(new Getter());
        mc.use("getProposal", Getter.getProposal.selector, getter);
        mc.use("getNextProposalId", Getter.getNextProposalId.selector, getter);
        mc.use("getProposalsConfig", Getter.getProposalsConfig.selector, getter);
        mc.use("getText", Getter.getText.selector, getter);
        mc.use("getNextTextId", Getter.getNextTextId.selector, getter);
        mc.use("getMember", Getter.getMember.selector, getter);
        mc.use("getNextMemberId", Getter.getNextMemberId.selector, getter);
        mc.use("getVRFRequest", Getter.getVRFRequest.selector, getter);
        mc.use("getNextVRFId", Getter.getNextVRFId.selector, getter);
        mc.use("getSubscriptionId", Getter.getSubscriptionId.selector, getter);
        mc.use("getVRFConfig", Getter.getVRFConfig.selector, getter);
        mc.use("getConfigOverride", Getter.getConfigOverride.selector, getter);

        mc.useFacade(address(new TextDAOFacade())); // for Etherscan proxy read/write
        address textdao = mc.deploy().toProxyAddress();

        bytes memory encodedData = abi.encodePacked("TEXT_DAO_ADDR=", vm.toString(address(textdao)));
        vm.writeLine(
            string(
                abi.encodePacked(vm.projectRoot(), "/.env")
            ),
            string(encodedData)
        );
    }
}
