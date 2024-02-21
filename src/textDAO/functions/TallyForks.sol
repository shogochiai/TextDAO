// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "~/textDAO/storages/StorageLib.sol";
import { SortLib } from "~/_predicates/SortLib.sol";

contract TallyForks {
    function tallyForks(uint pid) external returns (bool) {
        StorageLib.ProposeStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        StorageLib.Header[] storage $headers = $p.headers;
        StorageLib.Command[] storage $cmds = $p.cmds;

        require($p.proposalMeta.createdAt + $.config.expiryDuration > block.timestamp, "This proposal has been expired. You cannot run new tally to update ranks.");

        uint[] memory headerRank = new uint[]($headers.length);
        headerRank = SortLib.rankHeaders($headers);
        uint[] memory cmdRank = new uint[]($cmds.length);
        cmdRank = SortLib.rankCmds($cmds);

        $p.proposalMeta.headerRank = new uint[](3);
        $p.proposalMeta.headerRank[0] = headerRank[0];
        $p.proposalMeta.headerRank[1] = headerRank[1];
        $p.proposalMeta.headerRank[2] = headerRank[2];
        $p.proposalMeta.nextHeaderTallyFrom = $headers.length;
        $p.proposalMeta.cmdRank = new uint[](3);
        $p.proposalMeta.cmdRank[0] = cmdRank[0];
        $p.proposalMeta.cmdRank[1] = cmdRank[1];
        $p.proposalMeta.cmdRank[2] = cmdRank[2];
        $p.proposalMeta.nextCmdTallyFrom = $cmds.length;

    }
}
