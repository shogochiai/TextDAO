# ERC-7546 UCS TDD Example

## Overview
- This is a Foundry project
- DoubleOp and ProposeUp are tested
- To remove all proxy thingies, ops-related-state is being stored under the test contract itself. (No UCS proxy creation, just focus on functions and unit testing.)
- You can [fuzz state](https://mirror.xyz/shogochiai.eth/qw8PutYbxhm3g8FaW9g4NjKq14giC8jVtq_aMFOvkSU) hence scenario testing can be removed. This is for making unit test simpler and faster.

## Screenshots

![test cases](./docs/images/test-cases.png)
![propose op](./docs/images/proposeop.png)
![test result](./docs/images/test-result.png)
