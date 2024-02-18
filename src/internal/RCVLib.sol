pragma solidity ^0.8.23;

import { StorageLib } from "./StorageLib.sol";

library RCVLib {
  function vote() public {
    StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();

  }
}