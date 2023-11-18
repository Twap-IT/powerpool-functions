// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IPBTResolver {
    event targetPoolChanged(address indexed oldTargetPool, address indexed newTargetPool);
    event token1Changed(address indexed oldToken1, address indexed newToken1);
    event token2Changed(address indexed oldToken2, address indexed newToken2);
    event buyThresholdTargetChanged(uint256 indexed oldBuyThresholdTarget, uint256 indexed newBuyThresholdTarget);
    event sellThresholdTargetChanged(uint256 indexed oldSellThresholdTarget, uint256 indexed newSellThresholdTarget);
    event slippageToleranceChanged(uint256 indexed oldSlippageTolerance, uint256 indexed newSlippageTolerance);

    function changeTargetPool(address _newTargetPool) public {}

    function changeToken1(address _newToken1) public {}

    function changeToken2(address _newToken2) public {}

    function changeBuyThresholdTarget(uint256 _newBuyThresholdTarget) public {}

    function changeSellThresholdTarget(uint256 _newSellThresholdTarget) public {}

    function changeSlippageTolerance(uint256 _newSlippageTolerance) public {}

    function _computeTargetPoolPrice(address _targetPool) internal returns (uint256) {}

    function resolve() public returns (bool flag, bytes memory cdata) {}

    function swapExactInputSingle(bool _buyOrSell) external returns (uint256 amountOut) {}
}
