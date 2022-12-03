// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Actions {
    address aave = 0x8dFf5E27EA6b7AC08EbFdf9eB090F32ee9a30fcf;

    function executeSwap(
        address tokenToSwap,
        uint256 amountToSwap,
        address receiver
    ) public returns (bool) {
        require(msg.sender == address(this), "UNAUTHORIZED");
        string memory connectorName = "UNISWAP-V3-SWAP-A";
        // bytes memory targetData =
        // Transfer amountToSwap from user to ID DSA
        //  Note the target asset balance here
        // Ask the DSA to swap
        // Swap complete
        // Note the target asset swap again
        // send the diff to the action owner
    }

    function makeDeposit(
        address tokenToDeposit,
        uint256 amountToDeposit,
        address behalfOf,
        address caller
    ) public returns (bool) {
        require(msg.sender == address(this), "UNAUTHORIZED");

        IERC20(tokenToDeposit).transferFrom(
            caller,
            address(this),
            amountToDeposit
        );

        bytes4 basicDeposit = bytes4(
            keccak256("deposit(address,uint256,address,uint16)")
        );
        bytes memory targetData = abi.encodeWithSelector(
            basicDeposit,
            tokenToDeposit,
            amountToDeposit,
            behalfOf,
            0
        );

        address(aave).call(targetData);

        return true;
        // Transfer amountToDeposit from user to ID DSA
        // Ask the DSA to deposit
        // That's it
    }

    function sendToken(
        address token,
        address sender,
        address receiver,
        uint256 amount
    ) public returns (bool) {
        return IERC20(token).transferFrom(sender, receiver, amount);
    }

    function approve(address tokenAddress) public {
        IERC20(tokenAddress).approve(aave, type(uint256).max);
    }
}
