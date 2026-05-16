// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OverflowTest {
    
    // Dodawanie z włączonymi tarczami kompilatora (domyślne)
    function dodajBezpiecznie(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }

    // Dodawanie bez tarcz kompilatora (C-style)
    function dodajHakersko(uint256 a, uint256 b) public pure returns (uint256) {
        unchecked {
            return a + b;
        }
    }
}