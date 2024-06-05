// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Schema } from "bundle/textDAO/storages/Schema.sol";

library Types {
    struct ProposalArg {
        Schema.Header header;
        Schema.Command cmd;
        Schema.ProposalMeta proposalMeta;
    }
    struct ProposalVars {
        uint[] headerRank;
        uint[] cmdRank;
        bool[] cmdConds;
        bool cmdCondSum;
        Schema.Header[3] topHeaders;
        Schema.Command[3] topCommands;
        uint headerRank2;
        uint cmdRank2;
    }
}
