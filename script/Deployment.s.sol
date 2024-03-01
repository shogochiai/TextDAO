// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {console2} from "forge-std/console2.sol";
import { UCSTest } from "../../utils/UCSTest.sol";
import { UCSScript } from "@ucs-std/utils/UCSScript.sol";
import { UCSScriptUtils } from "@ucs-std/utils/UCSScriptUtils.sol";
import { CloneOp } from "@ucs-std/src/ops/CloneOp.sol";

import { Propose } from "~/textDAO/functions/Propose.sol";
import { Fork } from "~/textDAO/functions/Fork.sol";
import { Vote } from "~/textDAO/functions/Vote.sol";
import { Tally } from "~/textDAO/functions/Tally.sol";
import { Execute } from "~/textDAO/functions/Execute.sol";
import { MemberJoinProtected } from "~/textDAO/functions/protected/MemberJoinProtected.sol";
import { SetConfigsProtected } from "~/textDAO/functions/protected/SetConfigsProtected.sol";
import { ConfigOverrideProtected } from "~/textDAO/functions/protected/ConfigOverrideProtected.sol";
import { SaveTextProtected } from "~/textDAO/functions/protected/SaveTextProtected.sol";


contract Deployment is UCSScript {
    function setUp() public startBroadcastWithDeployerPrivKey {

        vm.deal(deployer, 100 ether);

        address multisigAddr;



        address yamato = ucs.use("Clone", CloneOp.clone.selector, address(new CloneOp()))
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
                            .getProxyAddress();

    }

}
