// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;


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

        address multisigAddr;



        address yamato = mc.use("Clone", Clone.clone.selector, address(new Clone()))
                            .use("Propose", Propose.deposit.selector, address(new Propose()))
                            .use("Fork", Fork.fork.selector, address(new Fork()))
                            .use("Vote", Vote.vote.selector, address(new Vote()))
                            .use("Tally", Tally.tally.selector, address(new Tally()))
                            .use("Execute", Execute.execute.selector, address(new Execute()))
                            .use("MemberJoinProtected", MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()))
                            .use("SetConfigsProtected", SetConfigsProtected.setConfigs.selector, address(new SetConfigsProtected()))
                            .use("ConfigOverrideProtected", ConfigOverrideProtected.configOverride.selector, address(new ConfigOverrideProtected()))
                            .use("SaveTextProtected", SaveTextProtected.saveTextProtected.selector, address(new SaveTextProtected()))
                            .set(address(new TextDAOFacade())) // for Etherscan proxy read/write
                            .deploy(abi.encodeCall(SetConfigsProtected.setConfigs, multisigAddr))
                            .toProxyAddress();

    }

}
