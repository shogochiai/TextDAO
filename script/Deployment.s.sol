// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import { console2 } from "forge-std/console2.sol";
import { MCDevKit } from "@devkit/MCDevKit.sol";
import { MCScript } from "@devkit/MCScript.sol";

import { Clone } from "@mc-std/functions/Clone.sol";
import { Propose } from "bundle/textdao/functions/Propose.sol";
import { Fork } from "bundle/textdao/functions/Fork.sol";
import { Vote } from "bundle/textdao/functions/Vote.sol";
import { Tally } from "bundle/textdao/functions/Tally.sol";
import { Execute } from "bundle/textdao/functions/Execute.sol";
import { MemberJoinProtected } from "bundle/textdao/functions/protected/MemberJoinProtected.sol";
import { SetConfigsProtected } from "bundle/textdao/functions/protected/SetConfigsProtected.sol";
import { ConfigOverrideProtected } from "bundle/textdao/functions/protected/ConfigOverrideProtected.sol";
import { SaveTextProtected } from "bundle/textdao/functions/protected/SaveTextProtected.sol";


contract Deployment is MCScript {
    function setUp() public startBroadcastWithDeployerPrivKey {

        vm.deal(deployer, 100 ether);


        address voteAddr = address(new Vote());
        mc.use("Clone", Clone.clone.selector, address(new Clone()));
        mc.use("Propose", Propose.propose.selector, address(new Propose()));
        mc.use("Fork", Fork.fork.selector, address(new Fork()));
        mc.use("Vote", Vote.voteHeaders.selector, voteAddr);
        mc.use("Vote", Vote.voteCmds.selector, voteAddr);
        mc.use("Tally", Tally.tally.selector, address(new Tally()));
        mc.use("Execute", Execute.execute.selector, address(new Execute()));
        mc.use("MemberJoinProtected", MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
        mc.use("SetConfigsProtected", SetConfigsProtected.setProposalsConfig.selector, address(new SetConfigsProtected()));
        mc.use("ConfigOverrideProtected", ConfigOverrideProtected.overrideProposalsConfig.selector, address(new ConfigOverrideProtected()));
        mc.use("SaveTextProtected", SaveTextProtected.saveText.selector, address(new SaveTextProtected()));
        // mc.set(address(new TextDAOFacade())); // for Etherscan proxy read/write
        address textdao = mc.deploy().toProxyAddress();
    }
}
