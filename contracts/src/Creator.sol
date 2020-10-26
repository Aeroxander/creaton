// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

import "hardhat-deploy/solc_0.7/proxy/Proxied.sol";
import "./utils/SafeMath.sol";
import "hardhat/console.sol";
import "./ERC1155/ERC1155MixedFungibleMintable.sol";

contract Creator is Proxied {
    using SafeMath for uint256;
    // -----------------------------------------
    // Events
    // -----------------------------------------

    // -----------------------------------------
    // Storage
    // -----------------------------------------

    address owner;
    string avatarURL;
    string creatorTitle;
    uint256 subscriptionPrice;

    // -----------------------------------------
    // Constructor
    // -----------------------------------------

    function init(
        string calldata _avatarURL,
        string calldata _creatorTitle,
        uint256 _subscriptionPrice
    ) public {
        owner = msg.sender;
        avatarURL = _avatarURL;
        creatorTitle = _creatorTitle;
        subscriptionPrice = _subscriptionPrice;
    }

    // -----------------------------------------
    // External Functions
    // -----------------------------------------

    function setAvatarURL(string calldata _newURL) external {
        require(msg.sender == owner);
        avatarURL = _newURL;
    }
}
