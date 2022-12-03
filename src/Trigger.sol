// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "@opengsn/contracts/src/ERC2771Recipient.sol";
import "./structs/types.sol";
import "./interface/ITrigger.sol";
import "./TriggerLogic.sol";

contract Trigger is ITrigger, TriggerLogic, ERC2771Recipient {
    constructor(address _trustedForwarder) {
        _setTrustedForwarder(_trustedForwarder);
    }

    function addTransaction(
        TriggerTypes.Action calldata transaction,
        TriggerTypes.Condition calldata triggerCondition,
        TriggerTypes.Payout calldata payout
    ) public override returns (bool) {
        bytes32 txHash = keccak256(abi.encode(transaction, nonce));

        transactions[txHash] = transaction;
        triggerConditions[txHash] = triggerCondition;
        transactionPayouts[txHash] = payout;
        transactionPayouts[txHash].from = _msgSender();

        transactionStatus[txHash] = TriggerTypes.TransactionStatus.QUEUED;
        transactionOwner[txHash] = _msgSender();

        nonce++;

        emit TransactionAdded(txHash, _msgSender());

        return true;
    }

    // view, doesn't depend on meta txns
    function checkTriggerCondition(bytes32 txHash)
        public
        view
        override
        returns (bool)
    {
        checkTransactionExists(txHash);
        TriggerTypes.Condition memory condition = triggerConditions[txHash];
        checkCondition(condition);
        return true;
    }

    // Is not a meta transaction
    function executeTransaction(bytes32 txHash) public override returns (bool) {
        uint256 initGas = gasleft();
        checkTransactionExists(txHash);
        TriggerTypes.Action memory transaction = transactions[txHash];
        TriggerTypes.Condition memory condition = triggerConditions[txHash];
        TriggerTypes.Payout memory payout = transactionPayouts[txHash];

        // Check condition
        checkCondition(condition);
        // Execute transaction
        executeAction(transaction);
        // Send payout
        sendPayout(payout, _msgSender(), initGas - gasleft() + 30_000); // Add 30_000 for sendPayout function

        emit TransactionExecuted(txHash, _msgSender());

        delete transactions[txHash];

        return true;
    }

    function cancelTransaction(bytes32 txHash) public returns (bool) {
        require(_msgSender() == transactionOwner[txHash], "UNAUTHORIZED");
        checkTransactionExists(txHash);
        delete transactions[txHash];

        emit TransactionCanceled(txHash, _msgSender());
        return true;
    }
}
