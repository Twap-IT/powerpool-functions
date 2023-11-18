// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract PBTResolver is Ownable {
    ISwapRouter public immutable swapRouter;

    address public targetPool;
    address public token1;
    address public token2;
    uint256 public buyThresholdTarget;
    uint256 public sellThresholdTarget;
    uint256 public slippageTolerance;
    uint256 public buyClipSize;
    uint256 public sellClipSize;

    constructor(
        address _targetPool,
        address _token1,
        address _token2,
        uint256 _buyThreshold,
        uint256 _sellThreshold,
        uint256 _slippageTolerance,
        uint256 _buyClipSize,
        uint256 _sellClipSize,
        address _swapRouter
    ) Ownable(msg.sender) {
        targetPool = _targetPool;
        token1 = _token1;
        token2 = _token2;
        buyThresholdTarget = _buyThreshold;
        sellThresholdTarget = _sellThreshold;
        slippageTolerance = _slippageTolerance;
        buyClipSize = _buyClipSize;
        sellClipSize = _sellClipSize;
        swapRouter = ISwapRouter(_swapRouter);
    }

    event targetPoolChanged(address indexed oldTargetPool, address indexed newTargetPool);
    event token1Changed(address indexed oldToken1, address indexed newToken1);
    event token2Changed(address indexed oldToken2, address indexed newToken2);
    event buyThresholdTargetChanged(uint256 indexed oldBuyThresholdTarget, uint256 indexed newBuyThresholdTarget);
    event sellThresholdTargetChanged(uint256 indexed oldSellThresholdTarget, uint256 indexed newSellThresholdTarget);
    event slippageToleranceChanged(uint256 indexed oldSlippageTolerance, uint256 indexed newSlippageTolerance);

    function changeTargetPool(address _newTargetPool) public onlyOwner {
        emit targetPoolChanged(targetPool, _newTargetPool);
        targetPool = _newTargetPool;
    }

    function changeToken1(address _newToken1) public onlyOwner {
        emit token1Changed(token1, _newToken1);
        token1 = _newToken1;
    }

    function changeToken2(address _newToken2) public onlyOwner {
        emit token2Changed(token2, _newToken2);
        token2 = _newToken2;
    }

    function changeBuyThresholdTarget(uint256 _newBuyThresholdTarget) public onlyOwner {
        emit buyThresholdTargetChanged(buyThresholdTarget, _newBuyThresholdTarget);
        buyThresholdTarget = _newBuyThresholdTarget;
    }

    function changeSellThresholdTarget(uint256 _newSellThresholdTarget) public onlyOwner {
        emit sellThresholdTargetChanged(sellThresholdTarget, _newSellThresholdTarget);
        sellThresholdTarget = _newSellThresholdTarget;
    }

    function changeSlippageTolerance(uint256 _newSlippageTolerance) public onlyOwner {
        emit slippageToleranceChanged(slippageTolerance, _newSlippageTolerance);
        slippageTolerance = _newSlippageTolerance;
    }

    function _computeTargetPoolPrice(address _targetPool) internal returns (uint256) {
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(targetPool).slot0();
        uint256 price = (uint256(sqrtPriceX96) * (uint256(sqrtPriceX96)) * (1e18)) >> (96 * 2);
        return price;
    }

    function resolve() public returns (bool flag, bytes memory cdata) {
        uint256 price = _computeTargetPoolPrice(targetPool);

        if (price <= buyThresholdTarget) {
            // case that we want to buy token2 with token1
            flag = true;
            cdata = abi.encodeWithSelector(this.swapExactInputSingle.selector, true);
        } else if (price >= sellThresholdTarget) {
            // case that we want to sell token2 for token1
            flag = true;
            cdata = abi.encodeWithSelector(this.swapExactInputSingle.selector, false);
        } else {
            flag = false;
        }
    }

    function swapExactInputSingle(bool _buyOrSell) external returns (uint256 amountOut) {
        ISwapRouter.ExactInputSingleParams memory params;
        address owner = owner();

        if (_buyOrSell) {
            // swap token 1 for token 2
            TransferHelper.safeTransferFrom(token1, owner, address(this), buyClipSize);
            TransferHelper.safeApprove(token1, address(swapRouter), buyClipSize);

            params = ISwapRouter.ExactInputSingleParams({
                tokenIn: token1,
                tokenOut: token2,
                fee: 3000,
                recipient: owner,
                deadline: block.timestamp,
                amountIn: buyClipSize,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        } else {
            // swap token 2 for token 1
            TransferHelper.safeTransferFrom(token2, owner, address(this), sellClipSize);
            TransferHelper.safeApprove(token2, address(swapRouter), sellClipSize);

            params = ISwapRouter.ExactInputSingleParams({
                tokenIn: token2,
                tokenOut: token1,
                fee: 3000,
                recipient: owner,
                deadline: block.timestamp,
                amountIn: sellClipSize,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        }

        amountOut = swapRouter.exactInputSingle(params);
    }
}
