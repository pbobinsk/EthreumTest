// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LowLevelToken {
    string public name = "Nasza Moneta";
    string public symbol = "NSM";
    
    // 1. Dodajemy informację o liczbie miejsc po przecinku (MetaMask tego szuka)
    uint8 public decimals = 0; 
    
    // 2. Zmieniamy nazwę z 'balances' na 'balanceOf'
    // Kompilator Solidity automatycznie stworzy funkcję: balanceOf(address)
    mapping(address => uint256) public balanceOf; 
    
    uint256 public totalSupply;
    address public owner;

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        balanceOf[msg.sender] = initialSupply;
        totalSupply = initialSupply;
    }

    function transfer(address to, uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Brak srodkow");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }
}