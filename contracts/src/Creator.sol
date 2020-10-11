// SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

import "buidler-deploy/solc_0.7/proxy/Proxied.sol";
import "@nomiclabs/buidler/console.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155PresetMinterPauser.sol";
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

contract Creator is ERC1155PresetMinterPauser, ISuperApp {

    /// @dev Collateral fee to subscribe, will stream back over a month (hardcoded to $5)
    uint256 constant private _COLLATERAL_FEE = 1e18;
    /// @dev Minimum flow rate to subscribe (hardcoded to $5 / mo)
    int96 constant private _MINIMUM_FLOW_RATE = int96(uint256(5e18) / uint256(3600 * 24 * 30));

    string constant private _ERR_STR_NO_TICKET = "CreatonSuperApp: need to stream to become supporter";
    string constant private _ERR_STR_LOW_FLOW_RATE = "CreatonSuperApp: flow rate too low";

    ISuperfluid private _host; // host
    IConstantFlowAgreementV1 private _cfa; // the stored constant flow agreement class address
    ISuperToken private _acceptedToken; // accepted token

    EnumerableSet.AddressSet private _supportersSet;
    using EnumerableSet for EnumerableSet.AddressSet;


    // -----------------------------------------
    // Events
    // -----------------------------------------

    // -----------------------------------------
    // Storage
    // -----------------------------------------

    /// @dev Streamers (that are a)
    mapping (address => uint) public streamers;

    // -----------------------------------------
    // Constructor
    // -----------------------------------------

    // function postUpgrade(uint256 id) public proxied {}

    constructor() public ERC1155PresetMinterPauser() {
        _mint(msg.sender, "{'name': 'test', 'description': 'testdesc', 'content': 'testurl'}", 1, ""); //1 means NFT.
        ISuperfluid host,
        IConstantFlowAgreementV1 cfa,
        ISuperToken acceptedToken) {
        assert(address(host) != address(0));
        assert(address(cfa) != address(0));
        assert(address(acceptedToken) != address(0));

        _host = host;
        _cfa = cfa;
        _acceptedToken = acceptedToken;

        uint256 configWord =
            SuperAppDefinitions.TYPE_APP_FINAL;

        _host.registerApp(configWord);
    }

    // -----------------------------------------
    // External Functions
    // -----------------------------------------

    /// @dev Take collateral fee from the user and add them acceptable streamers
    function participate(bytes calldata ctx) external {
        // msg sender is encoded in the Context
        (,,address sender,,) = _host.decodeCtx(ctx);
        _acceptedToken.transferFrom(sender, address(this), _COLLATERAL_FEE);
        streamers[sender]++;
    }

    /// @dev Support the creator
    function _support(
        bytes calldata ctx,
        address agreementClass,
        bytes32 agreementId,
        bytes calldata cbdata
    )
        private
        returns (bytes memory newCtx)
    {
        (address streamer) = abi.decode(cbdata, (address));

        (,int96 flowRate,,) = IConstantFlowAgreementV1(agreementClass).getFlowByID(_acceptedToken, agreementId);
        require(flowRate >= _MINIMUM_FLOW_RATE, _ERR_STR_LOW_FLOW_RATE);

        //make streamer a supporter
        _supportersSet.add(streamer);

        // remove from streamers
        streamers[streamer]--; 

        return _streamCollateral(player, ctx);
    }

    function _streamCollateral(
        address player,
        bytes calldata ctx
    )
        private
        returns (bytes memory newCtx)
    {
        (newCtx, ) = _host.callAgreementWithContext(
            _cfa,
            abi.encodeWithSelector(
                _cfa.createFlow.selector,
                _acceptedToken,
                _winner,
                _cfa.getNetFlow(_acceptedToken, address(this)),
                new bytes(0)
            ),
            newCtx
        );
    }

    
    /**************************************************************************
     * SuperApp callbacks
     *************************************************************************/

    function beforeAgreementCreated(
        ISuperToken superToken,
        bytes calldata ctx,
        address agreementClass,
        bytes32 /*agreementId*/
    )
        external view override
        onlyHost
        onlyExpected(superToken, agreementClass)
        returns (bytes memory cbdata)
    {
        cbdata = _beforePlay(ctx);
    }

    function afterAgreementCreated(
        ISuperToken /* superToken */,
        bytes calldata ctx,
        address agreementClass,
        bytes32 agreementId,
        bytes calldata cbdata
    )
        external override
        onlyHost
        returns (bytes memory newCtx)
    {
        return _play(ctx, agreementClass, agreementId, cbdata);
    }

        function _isSameToken(ISuperToken superToken) private view returns (bool) {
        return address(superToken) == address(_acceptedToken);
    }

    function _isCFAv1(address agreementClass) private pure returns (bool) {
        return ISuperAgreement(agreementClass).agreementType()
            == keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1");
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
