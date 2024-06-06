// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";

import { Tally } from "bundle/textDAO/functions/Tally.sol";
import { Storage, Schema } from "bundle/textDAO/storages/Storage.sol";

contract TallyTest is MCTest {

    function setUp() public {
        _use(Tally.tally.selector, address(new Tally()));
    }

    function test_tally_success() public {
        uint pid = 0;
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 1000;
        $.config.tallyInterval = 1000;

        Schema.Header[] storage $headers = $p.headers;
        Schema.Command[] storage $cmds = $p.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
            $cmds[i].actions.push();
            Schema.Action storage $action = $cmds[i].actions[0];
            $action.func = "tally(uint256)";
        }
        $cmds.push();

        $.config.quorumScore = 8;

        $p.headers[8].currentScore = 10;
        $p.headers[9].currentScore = 9;
        $p.headers[3].currentScore = 8;
        $p.cmds[4].currentScore = 10;
        $p.cmds[5].currentScore = 9;
        $p.cmds[6].currentScore = 8;

        Tally(address(this)).tally(pid);

        assertEq($p.proposalMeta.headerRank[0], 8);
        assertEq($p.proposalMeta.headerRank[1], 9);
        assertEq($p.proposalMeta.headerRank[2], 3);
        assertEq($p.proposalMeta.nextHeaderTallyFrom, 10);
        assertEq($p.proposalMeta.cmdRank[0], 4);
        assertEq($p.proposalMeta.cmdRank[1], 5);
        assertEq($p.proposalMeta.cmdRank[2], 6);
        assertEq($p.proposalMeta.nextCmdTallyFrom, 11);
    }

    function test_tally_failCommandQuorumWithOverride() public {
        uint pid = 0;
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];
        Schema.ConfigOverrideStorage storage $configOverride = Storage.$ConfigOverride();

        $p.proposalMeta.createdAt = 0;
        $.config.expiryDuration = 1000;
        $.config.tallyInterval = 1000;

        Schema.Header[] storage $headers = $p.headers;
        Schema.Command[] storage $cmds = $p.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
            $cmds[i].actions.push();
            Schema.Action storage $action = $cmds[i].actions[0];
            $action.func = "tally(uint256)";
        }
        $cmds.push();

        $.config.quorumScore = 8;
        $configOverride.overrides[Tally.tally.selector].quorumScore = 15;

        $p.headers[8].currentScore = 10;
        $p.headers[9].currentScore = 9;
        $p.headers[3].currentScore = 8;
        $p.cmds[4].currentScore = 10;
        $p.cmds[5].currentScore = 9;
        $p.cmds[6].currentScore = 8;

        Tally(address(this)).tally(pid);

        assertEq($p.proposalMeta.headerRank[0], 8);
        assertEq($p.proposalMeta.headerRank[1], 9);
        assertEq($p.proposalMeta.headerRank[2], 3);
        assertEq($p.proposalMeta.nextHeaderTallyFrom, 10);
        assertEq($p.proposalMeta.cmdRank[0], 0);
        assertEq($p.proposalMeta.cmdRank[1], 0);
        assertEq($p.proposalMeta.cmdRank[2], 0);
        assertEq($p.proposalMeta.nextCmdTallyFrom, 0);
    }


    function test_tally_revert_expired(uint256 executionBlockTime, uint256 createdAt, uint256 expirationTime) public {
        vm.assume(expirationTime >= createdAt);
        uint256 expiryDuration = expirationTime - createdAt;
        Storage.$Proposals().config.expiryDuration = expiryDuration;
        Storage.$Proposals().config.tallyInterval = 1;
        Storage.$Proposals().proposals[0].proposalMeta.createdAt = createdAt;

        vm.assume(executionBlockTime >= expirationTime);

        vm.warp(executionBlockTime);
        vm.expectRevert("This proposal has been expired. You cannot run new tally to update ranks.");
        Tally(address(this)).tally(0);
    }

}
