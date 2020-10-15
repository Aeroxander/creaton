// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

import "buidler-deploy/solc_0.7/proxy/Proxied.sol";
import "@nomiclabs/buidler/console.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

import "@openzeppelin/contracts/token/presets/ERC1155PresetMinterPauser.sol";

import {
    IConstantFlowAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

contract Creator is Proxied, ERC1155PresetMinterPauser, Ownable {
    // -----------------------------------------
    // Events
    // -----------------------------------------

    // -----------------------------------------
    // Storage
    // -----------------------------------------
    //getters are automatically made for public vars
    string public creatorTitle;
    int96 public subscriptionPrice;

    string creatorTitle;
    uint256 subscriptionPrice;
    uint256 projectDuration;

    // -----------------------------------------
    // Constructor
    // -----------------------------------------

    function init(string memory _creatorTitle, int96 _subscriptionPrice) public {
        creatorTitle = _creatorTitle;
        subscriptionPrice = _subscriptionPrice;
    }

    //TODO: Do this on init, not sure if we want to make this updateable
    function setPrice(int96 _subscriptionPrice) public onlyOwner {
        subscriptionPrice = _subscriptionPrice;
        //set price to CreatonSuperApp.sol with setMembershipPrice, the price, this address will be detected automatically for safety.
        //TODO: creatonsuperappaddress.call or something
    }

    //Creator only NFT minting feature already added through ERC1155PresetMinterPauser
}
