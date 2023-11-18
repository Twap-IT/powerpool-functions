pragma solidity ^0.8.0;

import "./PBTResolver.sol";
import "./interfaces/IPBTResolver.sol";
import "./interfaces/IAgent.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PBTResolverFactory is Ownable {
    IAgent public agent;

    mapping(bytes32 => address) public PBTResolverJobOwners;

    event PBTResolverDeployed(address indexed resolverAddress, address indexed resolverOwner, bytes32 jobKey);

    constructor(address _agent) Ownable(msg.sender) {
        agent = IAgent(_agent);
    }

    function deployPBTResolver(
        address _targetPool,
        address _token1,
        address _token2,
        uint256 _buyThreshold,
        uint256 _sellThreshold,
        uint256 _slippageTolerance,
        uint256 _buyClipSize,
        uint256 _sellClipSize,
        address _swapRouter
    ) public {
        PBTResolver resolver = new PBTResolver(
            _targetPool,
            _token1,
            _token2,
            _buyThreshold,
            _sellThreshold,
            _slippageTolerance,
            _buyClipSize,
            _sellClipSize,
            _swapRouter
        );

        resolver.transferOwnership(msg.sender);

        IAgent.RegisterJobParams memory registerJobParams = IAgent.RegisterJobParams(
            address(resolver),
            resolver.swapExactInputSingle.selector,
            true,
            true,
            50,
            0,
            1000,
            1000 ether,
            2,
            0
        );

        IAgent.Resolver memory resolverParams = IAgent.Resolver(address(resolver), abi.encodeWithSelector(resolver.resolve.selector));

        (bytes32 jobKey,) = agent.registerJob(registerJobParams, resolverParams, "");

        PBTResolverJobOwners[jobKey] = msg.sender;

        // initiate the job transfer
        agent.initiateJobTransfer(jobKey, msg.sender);

        // delegateCall from msg.sender to accept the jobTransfers
        (bool success, bytes memory data) =
            address(agent).delegatecall(abi.encodeWithSignature("acceptJobTransfer(bytes32)", jobKey));

        emit PBTResolverDeployed(address(resolver), msg.sender, jobKey);
    }
}
