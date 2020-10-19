// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

import "buidler-deploy/solc_0.7/proxy/Proxied.sol";
import "@nomiclabs/buidler/console.sol";
//import "@stoll/openzeppelin-contracts-ethereum-package/contracts/Initializable.sol";
//import "openzeppelin-solidity/contracts/token/ERC1155/ERC1155.sol";
//import "@stoll/openzeppelin-contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./ERC1155MixedFungibleMintable.sol";

//import "openzeppelin-solidity/contracts/presets/ERC1155PresetMinterPauser.sol";

contract Creator is Proxied, ERC1155MixedFungibleMintable {
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

    //constructor(uint256 id) public ERC1155() {
    //postUpgrade(id); // the proxied modifier from `buidler-deploy` ensure postUpgrade effect can only be used once when the contract is deployed without proxy
    //}

    //uint256 public x;

    //ERC20 public membership;

    //function initialize() public initializer {
    //    membership = new ERC20("Test", "TST"); // This contract will not be upgradeable
    //}

    //function initialize(uint256 _x) public initializer {
    //    Proxied.initialize(); // Do not forget this call!
    //    ERC1155PresetMinterPauser.initialize(); // Do not forget this call!
    //    x = _x;
    //}

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
