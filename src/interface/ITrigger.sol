// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
import "../structs/types.sol";

abstract contract ITrigger {
    event TransactionAdded(bytes32 indexed txHash, address indexed user);
    event TransactionExecuted(bytes32 indexed txHash, address indexed executor);
    event TransactionCanceled(bytes32 indexed txHash, address indexed user);

    function addTransaction(
        TriggerTypes.Action calldata transaction,
        TriggerTypes.Condition calldata triggerCondition,
        TriggerTypes.Payout calldata payout
    ) public virtual returns (bool);

    function executeTransaction(bytes32 txHash) public virtual returns (bool);

    function checkTriggerCondition(
        bytes32 txHash
    ) public view virtual returns (bool);
}
