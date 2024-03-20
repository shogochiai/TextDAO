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
        address textdao = mc.use("Clone", Clone.clone.selector, address(new Clone()))
                            .use("Propose", Propose.propose.selector, address(new Propose()))
                            .use("Fork", Fork.fork.selector, address(new Fork()))
                            .use("Vote", Vote.voteHeaders.selector, voteAddr)
                            .use("Vote", Vote.voteCmds.selector, voteAddr)
                            .use("Tally", Tally.tally.selector, address(new Tally()))
                            .use("Execute", Execute.execute.selector, address(new Execute()))
                            .use("MemberJoinProtected", MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()))
                            .use("SetConfigsProtected", SetConfigsProtected.setProposalsConfig.selector, address(new SetConfigsProtected()))
                            .use("ConfigOverrideProtected", ConfigOverrideProtected.overrideProposalsConfig.selector, address(new ConfigOverrideProtected()))
                            .use("SaveTextProtected", SaveTextProtected.saveText.selector, address(new SaveTextProtected()))
                            // .set(address(new TextDAOFacade())) // for Etherscan proxy read/write
                            .deploy()
                            // .deploy("TextDAO", abi.encodeCall(SetConfigsProtected.setProposalsConfig, (0, Schema.ProposalsConfig())))
                            .toProxyAddress();

        console2.logAddress(textdao);

    }

}
