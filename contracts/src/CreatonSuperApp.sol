// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

import "buidler-deploy/solc_0.7/proxy/Proxied.sol";
import "@nomiclabs/buidler/console.sol";

import {
    ISuperfluid,
    ISuperToken,
    ISuperAgreement,
    ISuperApp,
    SuperAppDefinitions
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import {
    IConstantFlowAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";


contract Creator is ISuperApp {
    /// @dev Collateral fee to subscribe, will stream back over a month (hardcoded to $5)
    //uint256 private constant _COLLATERAL_FEE = 5e18;
    /// @dev Minimum flow rate to subscribe (hardcoded to $5 / mo)
    //has to be dynamic //int96 private _MINIMUM_FLOW_RATE = int96(uint256(5e18) / uint256(2592000)); //amount / seconds in a month 3600 * 24 * 30

    string private constant _ERR_STR_NO_STREAMER = "CreatonSuperApp: need to stream to become supporter";
    string private constant _ERR_STR_LOW_FLOW_RATE = "CreatonSuperApp: flow rate too low";
    string private constant _ERR_STR_UNFINISHED_SUPPORT = "CreatonSuperApp: support the membership you payed collateral for first";

    ISuperfluid private _host; // host
    IConstantFlowAgreementV1 private _cfa; // the stored constant flow agreement class address
    ISuperToken private _acceptedToken; // accepted token

    EnumerableSet.AddressSet private _supportersSet;
    EnumerableSet.AddressSet private _streamersSet; //streamers are who started streaming but didnt join as supporter yet
    EnumerableSet.AddressSet private _membershipSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    // -----------------------------------------
    // Events
    // -----------------------------------------

    // -----------------------------------------
    // Storage
    // -----------------------------------------

    /// @dev Streamers (that are a)
    mapping(address => uint256) public streamers;

    // -----------------------------------------
    // Constructor
    // -----------------------------------------

    function init(
        string memory _creatorTitle,
        int96 _subscriptionPrice
    ) public proxied {
        creatorTitle = _creatorTitle;
        subscriptionPrice = _subscriptionPrice;
    }

    // function postUpgrade(uint256 id) public proxied {}

    constructor(
        ISuperfluid host,
        IConstantFlowAgreementV1 cfa,
        ISuperToken acceptedToken) {
        assert(address(host) != address(0));
        assert(address(cfa) != address(0));
        assert(address(acceptedToken) != address(0));

        _host = host;
        _cfa = cfa;
        _acceptedToken = acceptedToken;

        uint256 configWord = SuperAppDefinitions.TYPE_APP_FINAL;

        _host.registerApp(configWord);
    }

    // -----------------------------------------
    // External Functions
    // -----------------------------------------

    /// @dev Take collateral fee from the potential supporter and add them acceptable streamers
    function collateral(bytes calldata ctx) external {
        // msg sender is encoded in the Context
        (,,address sender,,address membership) = _host.decodeCtx(ctx);

        int96 collateralFee = _membershipSet.get(membership);
        _acceptedToken.transferFrom(sender, membership, collateralFee);
        streamersSet.add(sender, membership)
    }

    /// @dev Check requirements before letting the streamer become a supporter
    function _beforeSupport(bytes calldata ctx) private view returns (bytes memory cbdata) {
        (, , address sender, , ) = _host.decodeCtx(ctx);
        address collateralMembership = _streamersSet.get(sender); //membership the streamer has payed collateral for
        //require(streamers[sender] > 0, _ERR_STR_NO_STREAMER);
        
        //check if streamer is going to support the membership they payed collateral for
        require(membership == collateralMembership, _ERR_STR_UNFINISHED_SUPPORT);
        cbdata = abi.encode(sender);
    }

    /// @dev Support the creator
    function _support(
        bytes calldata ctx,
        address agreementClass,
        bytes32 agreementId,
        bytes calldata cbdata
    ) private returns (bytes memory newCtx) {
        (address streamer, address membership) = abi.decode(cbdata, (address, address));
        (, int96 flowRate, , ) = IConstantFlowAgreementV1(agreementClass).getFlowByID(_acceptedToken, agreementId);
        int96 subscriptionPrice = _membershipSet.get(streamer);
        int96 private minimumFlowRate = int96(uint256(subscriptionPrice + 'e18') / uint256(2592000)); //not sure if '+ e18' works like that
        require(flowRate >= minimumFlowRate, _ERR_STR_LOW_FLOW_RATE);

        _streamersSet.remove(streamer);
        //make streamer a supporter
        _supportersSet.add(streamer); //not doing anything with this for now, delete it if not needed

        return _streamCollateral(streamer, ctx);
    }

    function _streamCollateral(address streamer, bytes calldata ctx) private returns (bytes memory newCtx) {
        address membership = _streamersSet.get(streamer);
        (newCtx, ) = _host.callAgreementWithContext(
            _cfa,
            abi.encodeWithSelector(
                _cfa.createFlow.selector,
                _acceptedToken,
                streamer,
                _cfa.getNetFlow(_acceptedToken, membership),
                new bytes(0)
            ),
            newCtx
        );
    }

    /**************************************************************************
     * Setters
     *************************************************************************/

    //let new ERC-1155 membership tiers add their price to the list
    function setMembershipPrice(int96 price) public {
        _membershipSet.add(msg.sender, _price)
    }

    /**************************************************************************
     * SuperApp callbacks
     *************************************************************************/

    function beforeAgreementCreated(
        ISuperToken superToken,
        bytes calldata ctx,
        address agreementClass,
        bytes32 /*agreementId*/
    ) external override view onlyHost onlyExpected(superToken, agreementClass) returns (bytes memory cbdata) {
        cbdata = _beforeSupport(ctx);
    }

    function afterAgreementCreated(
        ISuperToken, /* superToken */
        bytes calldata ctx,
        address agreementClass,
        bytes32 agreementId,
        bytes calldata cbdata
    ) external override onlyHost returns (bytes memory newCtx) {
        return _support(ctx, agreementClass, agreementId, cbdata);
    }

    function _isSameToken(ISuperToken superToken) private view returns (bool) {
        return address(superToken) == address(_acceptedToken);
    }

    function _isCFAv1(address agreementClass) private pure returns (bool) {
        return
            ISuperAgreement(agreementClass).agreementType() ==
            keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1");
    }

    modifier onlyHost() {
        require(msg.sender == address(_host), "CreatonSuperApp: support only one host");
        _;
    }

    modifier onlyExpected(ISuperToken superToken, address agreementClass) {
        require(_isSameToken(superToken), "CreatonSuperApp: not accepted token");
        require(_isCFAv1(agreementClass), "CreatonSuperApp: only CFAv1 supported");
        _;
    }
}
