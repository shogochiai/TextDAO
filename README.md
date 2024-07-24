# TextDAO (Deprecated)

- Moved to [ecdysisxyz/TextDAO](https://github.com/ecdysisxyz/TextDAO)

# Version Sensitivity Info
- foundry: 1a4960d 2024-03-20T00:19:54.542150000Z
- mc: 257d4f5
- solidity: 0.8.24

## Overview
- A DAO with ERC-7546 UCS, it means DAO plugin architecture.
- RCV voting for text diff review.

## Motivation
- No more google docs for DAOs.
- Any groupware would be acceptable for daily discourse.
- But decision making over treasury and law must be on this DAO.

## How to start
- TDD with `forge test`
- Run `anvil --chain-id 1`
- Prepare `.env`
- `forge script script/Deployment.s.sol --rpc-url http://127.0.0.1:8545 --broadcast`
- `forge script script/Filler.s.sol --rpc-url http://127.0.0.1:8545 --broadcast`

### extractor
- `solc --standard-json < extractor/solcSlotRequest.json > ~/Downloads/astnode.json &&  cat ~/Downloads/astnode.json | jq . 1> ~/Downloads/astnodeFormatted.json`
- `forge script script/SlotTester.s.sol --rpc-url http://127.0.0.1:8545 --broadcast`
- `cast storage --chain=1 --rpc-url http://127.0.0.1:8545 0x4826533B4897376654Bb4d4AD88B7faFD0C98528 1`
- `cast storage --chain=1 --rpc-url http://127.0.0.1:8545 0x4826533B4897376654Bb4d4AD88B7faFD0C98528 0xeb29eb983a061a3feb4d4d7a2bced0182db2198396ce3beb0ace67382563d6e4` (ProposeStorage.proposals[0].tallied[0] for ERC-7201 dynamic base slot)
- `npx ts-node extractor/main.ts`

---
# Architecture
## Functions
### Join Request
- ProposeOp({JoinPassOp, arg1, arg2})
  - if no collateral then revert
  - pick Reps and let them vote
- MajorityVoteForForksOp
  - Assume there exist just a few vote options.
- ExecuteOp

### RCV (Ranked Choice Voting)
- ProposeOp(XxxPassOp, [...aFewPassOpParams])
- MajorityVoteForInspectionOp
  - A nice params need to be provided to RCV to mimic majority voting
  - pick Reps
- MajorityVoteForProposalOp
- ExecuteOp

### Law
- ProposeOp([{TextSavePassOp, pid, textId, [textURI1, textURI2]}, {XxxPassOp}])
- MajorityVoteForInspectionOp
  - pick Reps
- ForkOp([textURI3, textURI4]) // TextSavePassOp, pid, and textId are to be omitted?
- RankedChoiceVoteForForksOp(fid, [...ranks])
  - onlyReps
- TallyForksOp
- ExecuteOp
- TextSavePassOp() // modeling https://gist.github.com/shogochiai/fc636df8c13be967f37884acf8e8f6f3
- ex) ProposeOp(AddBotPassOp, botAddr)

--- Common Util Ops
- ProposeOp(XxxPassOp)
  - You have to proetct inspectors from
  - onlyMemberOrDoxxedOrAnonWithColl
    - Member and Doxxed
      - rate limit per person per day
    - Anon
      - Need collateral

- ForkOp(cid)
  - onlyRepsOrBot
  - no need collateral
      - rate limit per person per day
        - limit share

- ExecuteOp
  - Check executable condition for all voting types
  - RCV: the 1st winning fork is to be executed.
  - Majority: RCV with only 1 choice and only 1 session.
  - QV: RCV with credit and many options.

## Miscellaneous

### L1 Shadow Tally
- SubmitTallyOracleDataOp
- VetoTallyOracleOp
- SetTallyOracleOp

### QV for collective funding
- If you want QV
  - it means your want a cool donation system, rather DAO
      - then use `clrfund/monorepo`

### RNG
- ChainLink VRF

### Deploy Script Design
- /src/nouns/verbs structure is mandatory
- verbs belong to a noun
- nouns are mutually relatable
- A protocol is the set of nouns

---

# How to dev
- `forge test`
