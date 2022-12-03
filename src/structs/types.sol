// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

contract TriggerTypes {
    enum PayoutType {
        FIXED,
        GASMULTIPLE
    }

    enum TransactionStatus {
        QUEUED,
        EXECUTED,
        CANCELLED
    }

    struct Action {
        address to;
        bytes data;
    }

    struct Condition {
        address to;
        bytes data;
        bytes output;
    }

    // Payout to the miner
    // pType fixed means the value to pay is value in WETH
    // pType gas multiple means, the value is multiple of gasPrice in WETH
    // tokenAddress fixed to WETH
    // from is fixed to user that added the transaction

    struct Payout {
        PayoutType pType;
        address tokenAddress;
        // Value 150 for gas multiple type is 1.5 times the prev block gasPrice
        uint256 value;
        address from;
    }
}
