// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

contract Dummy {
    event DummyCalled();

    function dummy() public returns (uint256) {
        emit DummyCalled();
        return 23;
    }
}
