pragma solidity ^0.8.0;

import "./PBTResolver.sol";
import "./interfaces/IPBTResolver.sol";
import "./interfaces/IAgent.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PBTResolverFactory is Ownable {
    // address of poweragent
    IAgent public agent;

    mapping(bytes32 => address) public PBTResolverJobOwners;

    event PBTResolverDeployed(address indexed resolverAddress, address indexed resolverOwner, bytes32 jobKey);

    constructor(address _agent) Ownable(msg.sender) {
        agent = IAgent(_agent);
    }

    // deploy a new PBTResolver and register it to the agent
    // @param _targetPool: the target univ3 pool address
    // @param _token1: the token1 address of the target pool
    // @param _token2: the token2 address of the target pool
    // @param _buyThreshold: the price in which you use token1 to purchase token 2
    // @param _sellThreshold: the price in which you use token2 to purchase token 1
    // @param _slippageTolerance: the slippage tolerance for the swap
    // @param _buyClipSize: the amount of token1 you want to use to buy token2
    // @param _sellClipSize: the amount of token2 you want to use to buy token1
    // @param _swapRouter: the swapRouter address
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
            address(resolver), resolver.swapExactInputSingle.selector, true, true, 50, 0, 1000, 1000 ether, 2, 0
        );

        IAgent.Resolver memory resolverParams =
            IAgent.Resolver(address(resolver), abi.encodeWithSelector(resolver.resolve.selector));

        (bytes32 jobKey,) = agent.registerJob(registerJobParams, resolverParams, "");

        PBTResolverJobOwners[jobKey] = msg.sender;

        // initiate the job transfer
        agent.initiateJobTransfer(jobKey, msg.sender);

        // @NOTE must call "acceptJobTransfer" on the agent
        // "0x071412e301c2087a4daa055cf4afa2683ce1e499" on gnosis
        // from the telegram bot user to initialize the job

        emit PBTResolverDeployed(address(resolver), msg.sender, jobKey);
    }
}
