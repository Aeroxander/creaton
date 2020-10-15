// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

import "buidler-deploy/solc_0.7/proxy/Proxied.sol";
import "@nomiclabs/buidler/console.sol";
import "./Creator.sol";

contract CreatonFactory is Proxied {
    // -----------------------------------------
    // Events
    // -----------------------------------------

    event CreatorDeployed(address indexed user, Creator creatorContract);

    // -----------------------------------------
    // Storage
    // -----------------------------------------

    // TODO: change this to a mapping: creator's address => contract address
    //use EnumerableSet?
    //Also do we even need this? The membership address is already mapped in the SuperApp contract
    //We do want the creator to be the owner of their Membership ERC-1155's, but Openzeppelin has a solution with the Initialize library
    //EnumerableSet.AddressSet private _creatorAddressSet;
    //using EnumerableSet for EnumerableSet.AddressSet;
    Creator[] creatorContracts;

    // -----------------------------------------
    // Constructor
    // -----------------------------------------

    constructor() {}

    // -----------------------------------------
    // External Functions
    // -----------------------------------------

    function deployCreator(string calldata creatorTitle, int96 subscriptionPrice) external {
        Creator _creatorContract = new Creator();
        _creatorContract.init(creatorTitle, subscriptionPrice);
        creatorContracts.push(_creatorContract);

        emit CreatorDeployed(msg.sender, _creatorContract);
    }

    function test() public {}
}
