// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
import "./structs/types.sol";
import "./Conditions.sol";
import "./Actions.sol";

contract TriggerLogic is Conditions, Actions {
    uint256 public nonce;
    mapping(bytes32 => TriggerTypes.Action) public transactions;
    mapping(bytes32 => address) public transactionOwner;
    mapping(bytes32 => TriggerTypes.Condition) public triggerConditions;
    mapping(bytes32 => TriggerTypes.Payout) public transactionPayouts;
    mapping(bytes32 => TriggerTypes.TransactionStatus) public transactionStatus;

    function checkCondition(TriggerTypes.Condition memory condition)
        internal
        view
        returns (bool)
    {
        (bool success, bytes memory output) = address(condition.to).staticcall(
            condition.data
        );

        require(success, "CONDITION_CALL_FAILED");
        require(
            keccak256(output) == keccak256(condition.output),
            "CONDITION_NOT_PASSED"
        );

        return true;
    }

    function executeAction(TriggerTypes.Action memory action)
        internal
        returns (bool)
    {
        (bool success, ) = address(action.to).call(action.data);
        require(success, "TRANSACTION_FAILED");

        return true;
    }

    function calculatePayout(
        TriggerTypes.Payout memory payout,
        uint256 expectedGas
    ) public view returns (uint256) {
        if (payout.pType == TriggerTypes.PayoutType.GASMULTIPLE) {
            uint256 premiumGas = (block.basefee * payout.value) / 100;
            uint256 payoutValue = (premiumGas * expectedGas);
            return payoutValue;
        }
        return payout.value;
    }

    function sendPayout(
        TriggerTypes.Payout memory payout,
        address benefactor,
        uint256 gasUsed
    ) internal returns (bool) {
        uint256 payoutValue = calculatePayout(payout, gasUsed);

        bool success = IERC20(payout.tokenAddress).transferFrom(
            payout.from,
            benefactor,
            payoutValue
        );

        require(success, "PAYOUT_FAILED");
        return true;
    }

    function checkTransactionExists(bytes32 txHash) public view {
        require(transactions[txHash].to != address(0), "TXN_NON_EXISTENT");
    }
}
