// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

import "buidler-deploy/solc_0.7/proxy/Proxied.sol";
import "@nomiclabs/buidler/console.sol";

contract Creator {
    // -----------------------------------------
    // Events
    // -----------------------------------------

    // -----------------------------------------
    // Storage
    // -----------------------------------------

    // -----------------------------------------
    // Constructor
    // -----------------------------------------

    // function postUpgrade(uint256 id) public proxied {}

    constructor() {
      // the proxied modifier from `buidler-deploy` ensure postUpgrade effect can only be 
      // used once when the contract is deployed without proxy
      // postUpgrade(id);
    }

    // -----------------------------------------
    // External Functions
    // -----------------------------------------
}