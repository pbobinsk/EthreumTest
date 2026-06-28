// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract VictimDAOsafe  is ReentrancyGuard {
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event WithdrawalStarted(address indexed user, uint256 amount, uint256 daoBalanceBefore);
    event WithdrawalFinished(address indexed user, uint256 daoBalanceAfter);

    function deposit() public payable {
        require(msg.value > 0, "Musisz wplacic wiecej niz 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // ZABEZPIECZONA FUNKCJA WYPŁATY
    // Dodajemy modyfikator "nonReentrant"
    function withdraw() public nonReentrant {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Brak srodkow w DAO");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer nieudany");

        balances[msg.sender] = 0;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}