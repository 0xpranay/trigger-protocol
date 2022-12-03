// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "solmate/test/utils/DSTestPlus.sol";
import "src/Trigger.sol";
import "src/utils/dummy.sol";
import "src/utils/WETH.sol";
import "./CheatCodes.sol";
// import "/Users/pranayreddy/Desktop/trigger1/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TriggerTypes} from "src/structs/types.sol";

contract TriggerTimestampTest is DSTestPlus {
    event TransactionAdded(bytes32 indexed txHash, address indexed user);
    event TransactionExecuted(bytes32 indexed txHash, address indexed executor);
    event TransactionCanceled(bytes32 indexed txHash, address indexed user);

    CheatCodes public cheats = CheatCodes(HEVM_ADDRESS);
    Trigger public trigger;
    Dummy public dummy;
    WETH public weth;

    function setUp() public {
        trigger = new Trigger(0xf0511f123164602042ab2bCF02111fA5D3Fe97CD);
        dummy = new Dummy();
        weth = new WETH();
    }

    function addTransaction() internal returns (bytes32) {
        TriggerTypes.Action memory transaction = TriggerTypes.Action(
            address(dummy),
            abi.encodeWithSignature("dummy()")
        );
        TriggerTypes.Condition memory condition = TriggerTypes.Condition(
            address(trigger),
            abi.encodeWithSignature("conditionIsGreaterTimestamp(uint256)", 35),
            abi.encode(true)
        );
        TriggerTypes.Payout memory payout = TriggerTypes.Payout(
            TriggerTypes.PayoutType.FIXED,
            address(weth),
            25,
            address(this)
        );

        bytes32 txHash = keccak256(abi.encode(transaction, trigger.nonce()));
        cheats.expectEmit(true, true, true, true);
        emit TransactionAdded(txHash, address(this));

        trigger.addTransaction(transaction, condition, payout);

        return txHash;
    }

    function testAddTransaction() public {
        addTransaction();
    }

    function testCheckCondition() public {
        bytes32 txHash = addTransaction();
        emit log_uint(block.timestamp);

        cheats.expectRevert("CONDITION_NOT_PASSED");
        trigger.checkTriggerCondition(txHash);

        cheats.warp(36);
        emit log_uint(block.timestamp);

        bool postPass = trigger.checkTriggerCondition(txHash);
        assertFalse(!postPass);
    }

    function testExecuteTransaction() public {
        bytes32 txHash = addTransaction();

        weth.mint(address(this), 1000 * 1e18);
        weth.approve(address(trigger), 25);
        cheats.warp(39);

        cheats.expectEmit(true, true, true, true);
        cheats.prank(address(12));
        emit TransactionExecuted(txHash, address(12));

        trigger.executeTransaction(txHash);
    }

    function testRemoveTransaction(bytes32 txHash) public {
        bytes32 txHash = addTransaction();

        cheats.warp(36);

        weth.mint(address(this), 1000 * 1e18);
        weth.approve(address(trigger), 25);

        trigger.cancelTransaction(txHash);

        cheats.expectRevert("TXN_NON_EXISTENT");
        trigger.executeTransaction(txHash);
    }
}

contract TriggerGasfeeTest is DSTestPlus {
    event TransactionAdded(bytes32 indexed txHash, address indexed user);
    event TransactionExecuted(bytes32 indexed txHash, address indexed executor);
    event TransactionCanceled(bytes32 indexed txHash, address indexed user);

    CheatCodes public cheats = CheatCodes(HEVM_ADDRESS);
    Trigger public trigger;
    Dummy public dummy;
    WETH public weth;

    function setUp() public {
        trigger = new Trigger(0xf0511f123164602042ab2bCF02111fA5D3Fe97CD);
        dummy = new Dummy();
        weth = new WETH();
    }

    function addTransaction() internal returns (bytes32) {
        TriggerTypes.Action memory transaction = TriggerTypes.Action(
            address(weth),
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                address(12),
                address(21),
                1000
            )
        );
        TriggerTypes.Condition memory condition = TriggerTypes.Condition(
            address(trigger),
            abi.encodeWithSignature("conditionIsLessGasFee(uint256)", 35 gwei),
            abi.encode(true)
        );
        TriggerTypes.Payout memory payout = TriggerTypes.Payout(
            TriggerTypes.PayoutType.GASMULTIPLE,
            address(weth),
            175,
            address(this)
        );

        bytes32 txHash = keccak256(abi.encode(transaction, trigger.nonce()));
        cheats.expectEmit(true, true, true, true);
        emit TransactionAdded(txHash, address(12));

        cheats.prank(address(12));
        trigger.addTransaction(transaction, condition, payout);

        return txHash;
    }

    function testAddTransaction() public {
        addTransaction();
    }

    function testCheckCondition() public {
        bytes32 txHash = addTransaction();

        cheats.fee(40 gwei);
        emit log_uint(block.basefee);

        cheats.expectRevert("CONDITION_NOT_PASSED");
        trigger.checkTriggerCondition(txHash);

        cheats.fee(30 gwei);

        bool postPass = trigger.checkTriggerCondition(txHash);
        assertFalse(!postPass);
    }

    function testExecuteTransaction() public {
        cheats.prank(address(12));
        weth.approve(address(trigger), 25 * 1e18);
        weth.mint(address(12), 1000 * 1e18);
        cheats.fee(34 gwei);

        emit log_uint(block.basefee);

        bytes32 txHash = addTransaction();

        cheats.warp(39);

        uint256 prevGas = gasleft();

        cheats.prank(address(34));
        trigger.executeTransaction(txHash);
        emit log_uint(prevGas - gasleft());
    }
}

contract IntegrationTest is DSTestPlus {
    event TransactionAdded(bytes32 indexed txHash, address indexed user);
    event TransactionExecuted(bytes32 indexed txHash, address indexed executor);
    event TransactionCanceled(bytes32 indexed txHash, address indexed user);

    CheatCodes public cheats = CheatCodes(HEVM_ADDRESS);
    Trigger public trigger;
    Dummy public dummy;
    WETH public weth;

    function setUp() public {
        trigger = new Trigger(0xf0511f123164602042ab2bCF02111fA5D3Fe97CD);
        dummy = new Dummy();
        weth = new WETH();
    }

    function testAaveConnection() public returns (bool) {
        bytes4 func = bytes4(keccak256("getWMatic()"));
        bytes memory data = abi.encodeWithSelector(func);

        // Get some WMATIC
        address(0xEbF09eD32FFdaF2ee46A5B019eec576f11f06538).call(data);

        // Approve trigger to pull WMATIC
        IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270).approve(
            address(trigger),
            10000
        );

        // Approve AAVE to pull from Trigger
        trigger.approve(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);

        // trigger.makeDeposit(
        //     0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270,
        //     1000,
        //     address(this),
        //     address(this)
        // );

        emit log_uint(block.basefee);

        TriggerTypes.Action memory transaction = TriggerTypes.Action(
            address(trigger),
            abi.encodeWithSignature(
                "makeDeposit(address,uint256,address,address)",
                0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270,
                1000,
                address(this),
                address(this)
            )
        );
        TriggerTypes.Condition memory condition = TriggerTypes.Condition(
            address(trigger),
            abi.encodeWithSignature(
                "conditionIsLessPrice(address,uint256)",
                0x45dDa9cb7c25131DF268515131f647d726f50608,
                780000000
            ),
            abi.encode(true)
        );
        TriggerTypes.Payout memory payout = TriggerTypes.Payout(
            TriggerTypes.PayoutType.GASMULTIPLE,
            address(weth),
            0,
            address(this)
        );

        bytes32 txHash = keccak256(abi.encode(transaction, trigger.nonce()));
        trigger.addTransaction(transaction, condition, payout);

        trigger.executeTransaction(txHash);

        // return txHash;

        uint256 aTokenBalance = IERC20(
            0x8dF3aad3a84da6b69A4DA8aeC3eA40d9091B2Ac4
        ).balanceOf(address(this));

        emit log_uint(aTokenBalance);

        assertEq(aTokenBalance, 1000);
    }
}
