// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface IUniswapV3PoolState {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );
}

interface ILendingPool {
    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );
}

contract Conditions {
    address public aaveLendingPool = 0x8dFf5E27EA6b7AC08EbFdf9eB090F32ee9a30fcf;

    // Some default conditions
    function conditionIsGreaterTimestamp(uint256 timestamp)
        public
        view
        returns (bool)
    {
        return block.timestamp > timestamp;
    }

    function conditionIsLessGasFee(uint256 gasFee) public view returns (bool) {
        return block.basefee < gasFee;
    }

    // Returns if the token0 price of a pool is <= desired price
    // Returns how much 1 token0 is worth in token1
    // Target price must be decimal diff aware
    /// @notice hardcoded for WETH-USDC Pool
    /// @notice returns how much 1 usdc can buy in WETH
    /// @notice targetPrice is desired price * (10 ** 12)

    // If target price is 1 ETH = 1282 USDC
    // Then the target price needed is 1 USDC = 0.00078
    // Target price that needs to be passed is (0.00078 * (10 ** 12))
    function conditionIsLessPrice(address poolAddress, uint256 targetPrice)
        public
        view
        returns (bool)
    {
        IUniswapV3PoolState pool = IUniswapV3PoolState(poolAddress);
        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        uint256 rootPrice = (sqrtPriceX96 / (2**96));
        uint256 token0Price = rootPrice * rootPrice;

        return token0Price <= targetPrice;
    }

    function conditionIsLessHealthFactor(
        address userAddress,
        uint256 targetHealthFactor
    ) public view returns (bool) {
        ILendingPool pool = ILendingPool(aaveLendingPool);
        (, , , , , uint256 hf) = pool.getUserAccountData(userAddress);

        return hf <= targetHealthFactor;
    }
}
