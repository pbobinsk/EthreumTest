// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VictimDAO {
    mapping(address => uint256) public balances;

    // Definiujemy zdarzenia dla ofiary
    event Deposit(address indexed user, uint256 amount);
    event WithdrawalStarted(address indexed user, uint256 amount, uint256 daoBalanceBefore);
    event WithdrawalFinished(address indexed user, uint256 daoBalanceAfter);

    function deposit() public payable {
        require(msg.value > 0, "Musisz wplacic wiecej niz 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Brak srodkow w DAO");

        // Logujemy rozpoczęcie wypłaty (przed wysłaniem ETH!)
        emit WithdrawalStarted(msg.sender, balance, address(this).balance);

        // Interakcja: Wysyłamy środki i oddajemy kontrolę odbiorcy
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer nieudany");

        // Efekt: Aktualizacja stanu po transakcji
        balances[msg.sender] = 0;

        // Logujemy pomyślne zakończenie funkcji
        emit WithdrawalFinished(msg.sender, address(this).balance);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}