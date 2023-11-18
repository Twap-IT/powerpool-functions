pragma solidity ^0.8.0;

import "./PBTResolver.sol";

contract PBTResolverFactory {
    event PBTResolverDeployed(address indexed resolverAddress, address indexed resolverOwner);

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
        emit PBTResolverDeployed(address(resolver), msg.sender);
    }
}
