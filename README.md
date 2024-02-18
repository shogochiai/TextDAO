# TextDAO

## Overview
- A DAO with ERC-7546 UCS, it means DAO plugin architecture.
- RCV voting for text diff review.

## Motivation
- No more google docs for DAOs.
- Any groupware would be acceptable for daily discourse.
- But decision making over treasury and law must be on this DAO.

---
# Architecture

## Data Model

Sample implementation of voting for forked options (RCV) is [here](./src/TallyForksOp.sol)
i.e., headers and cmds are forkable RCV voting target in this document.

### TextSavePassOp

#### Amazingly simple contract
```
contract TextSavePassOp {
  function textSave(uint pid, uint textId, bytes32[] metadataURIs) public onlyPassed(pid) {
    texts[textId] = metadataURIs;
  }
}
```

#### Sample Tx Composition
```
// Must be JS, but written in Solidity...
Command memory cmd;
cmd.id = $.newCommandId();
Action memory act;
act.addr = TEXT_SAVE_OP_ADDR;
act.func = "textSave(uint256, uint256, bytes32[])";
act.abiParams = abi.encode(pid, $.newTextId(), [cid1, cid2]);
act.actions[0] = act;

// Just FYI, calldata will be like this in ExecuteOp.sol
/* 
bytes.concat(
  bytes4(keccak256(act.actions[i].func)),
  _abiParams.actions[i].abiParams
)
*/


```


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
