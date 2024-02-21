// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { UCSTestBase } from "~/_predicates/UCSTestBase.sol";
import { Propose } from "~/textDAO/functions/Propose.sol";
import { Fork } from "~/textDAO/functions/Fork.sol";
import { Vote } from "~/textDAO/functions/Vote.sol";
import { ExecuteProposal } from "~/textDAO/functions/ExecuteProposal.sol";
import { TallyForks } from "~/textDAO/functions/TallyForks.sol";
import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { SaveTextUnsafe } from "~/textDAO/functions/unsafe/SaveTextUnsafe.sol";
import { MemberJoinUnsafe } from "~/textDAO/functions/unsafe/MemberJoinUnsafe.sol";

contract Test3 is UCSTestBase {

    function setUp() public override {
        implementations[Propose.propose.selector] = address(new Propose());
        implementations[Fork.fork.selector] = address(new Fork());
        implementations[ExecuteProposal.executeProposal.selector] = address(new ExecuteProposal());
        implementations[Vote.voteHeaders.selector] = address(new Vote());
        implementations[Vote.voteCmds.selector] = address(new Vote());
        implementations[TallyForks.tallyForks.selector] = address(new TallyForks());
        implementations[SaveTextUnsafe.saveText.selector] = address(new SaveTextUnsafe());
        implementations[MemberJoinUnsafe.memberJoin.selector] = address(new MemberJoinUnsafe());
    }

    function test_configOverride_successQuorum() public {
        
    } 


}
