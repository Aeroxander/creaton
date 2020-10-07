// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

import "buidler-deploy/solc_0.7/proxy/Proxied.sol";
import "@nomiclabs/buidler/console.sol";

contract Creaton is Proxied {
    // -----------------------------------------
    // Events
    // -----------------------------------------

    event MessageChanged(address indexed user, string message);

    // -----------------------------------------
    // Storage
    // -----------------------------------------

    mapping(address => string) _messages;

    // -----------------------------------------
    // Constructor
    // -----------------------------------------

    function postUpgrade(uint256 id) public proxied {}

    constructor(uint256 id) {
        postUpgrade(id); // the proxied modifier from `buidler-deploy` ensure postUpgrade effect can only be used once when the contract is deployed without proxy
    }

    // -----------------------------------------
    // External Functions
    // -----------------------------------------

    function setMessage(string calldata message) external {
        _messages[msg.sender] = message;
        emit MessageChanged(msg.sender, message);
    }

    function fails(string calldata message) external {
        console.log("it fails: '%s'", message);
        emit MessageChanged(msg.sender, message);
        revert("fails");
    }
}
