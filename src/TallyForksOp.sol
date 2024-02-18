// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "./internal/StorageLib.sol";
import { SortLib } from "./internal/SortLib.sol";

contract TallyForksOp {
    function tallyForks(uint pid) external returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        StorageLib.Proposal storage $p = $.proposals[pid];
        StorageLib.Header[] storage $headers = $p.headers;
        StorageLib.Command[] storage $cmds = $p.cmds;

        require($p.proposalMeta.expireAt > block.timestamp, "This proposal has been expired. You cannot run new tally to update ranks.");

        uint[] memory headerRank = SortLib.rankHeaders($headers);
        uint[] memory cmdRank = SortLib.rankCmds($cmds);

        $p.proposalMeta.headerRank[0] = headerRank[0];
        $p.proposalMeta.headerRank[1] = headerRank[1];
        $p.proposalMeta.headerRank[2] = headerRank[2];
        $p.proposalMeta.nextHeaderTallyFrom = $headers.length;
        $p.proposalMeta.cmdRank[0] = cmdRank[0];
        $p.proposalMeta.cmdRank[1] = cmdRank[1];
        $p.proposalMeta.cmdRank[2] = cmdRank[2];
        $p.proposalMeta.nextCmdTallyFrom = $cmds.length;

    }
}
