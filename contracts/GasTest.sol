// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasTest {
    // Pamięć trwała - twardy dysk blockchaina
    uint256 public dysk_twardy;

    // Funkcja 1: Zapis na dysk
    function zapiszNaDysku() public {
        dysk_twardy = 5;
    }

    // Funkcja 2: Zapis do ulotnego RAMu
    function zapiszWRAMie() public pure returns (uint256) {
        uint256 ram = 5;
        return ram;
    }
}