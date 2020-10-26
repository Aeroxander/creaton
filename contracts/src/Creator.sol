// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;

import "buidler-deploy/solc_0.7/proxy/Proxied.sol";
import "./utils/SafeMath.sol";
import "@nomiclabs/buidler/console.sol";
import "./ERC1155/ERC1155MixedFungibleMintable.sol";

//import "openzeppelin-solidity/contracts/presets/ERC1155PresetMinterPauser.sol";

contract Creator is Proxied, ERC1155MixedFungibleMintable {
    using SafeMath for uint256;
    // -----------------------------------------
    // Events
    // -----------------------------------------

    // -----------------------------------------
    // Storage
    // -----------------------------------------

    string[] public metadataURL;
    address public owner ;
    string public avatarURL;
    string public creatorTitle;
    uint256 public subscriptionPrice;
    mapping(address => uint256) public currentCollateral;

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

    function subscribe(uint256 _amount) external {
        require(_amount != 0x0, "Missing subscription amount");
        require(currentCollateral[msg.sender] == 0x0, "Already subscribed");
        currentCollateral[msg.sender] = _amount;
    }

    function setAvatarURL(string calldata _newURL) external {
        require(msg.sender == owner);
        avatarURL = _newURL;
    }

    function setMetadataURL(string calldata _url) external {
        require(msg.sender == owner);
        metadataURL.push(_url);
    }

    function getAllMetadata() public view returns(string[] memory) {
        return metadataURL;
    }
}
