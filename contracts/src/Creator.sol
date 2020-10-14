// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

import "buidler-deploy/solc_0.7/proxy/Proxied.sol";
import "@nomiclabs/buidler/console.sol";

contract Creator is Proxied {
    // -----------------------------------------
    // Events
    // -----------------------------------------

    // -----------------------------------------
    // Storage
    // -----------------------------------------

    string creatorTitle;
    uint256 subscriptionPrice;
    uint256 projectDuration;

    // -----------------------------------------
    // Constructor
    // -----------------------------------------

    function init(
        string memory _creatorTitle,
        uint256 _subscriptionPrice,
        uint256 _projectDuration
    ) public {
        creatorTitle = _creatorTitle;
        subscriptionPrice = _subscriptionPrice;
        projectDuration = _projectDuration;
    }

    // -----------------------------------------
    // External Functions
    // -----------------------------------------
}
