// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VictimDAOsafe {
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
    function withdraw() public {
        // 1. CHECKS (Sprawdzenia)
        // Sprawdzamy warunki wejściowe
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Brak srodkow w DAO");

        emit WithdrawalStarted(msg.sender, balance, address(this).balance);

        // 2. EFFECTS (Efekty)
        // Kluczowa zmiana: Aktualizujemy stan (zerujemy saldo) PRZED interakcją z zewnętrznym adresem.
        // Jeśli haker spróbuje wejść ponownie (reentrancy), jego saldo w kroku "CHECKS" będzie już równe 0.
        balances[msg.sender] = 0;

        // 3. INTERACTIONS (Interakcje)
        // Na samym końcu, gdy stan jest już bezpiecznie zapisany, wysyłamy Ether.
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer nieudany");

        emit WithdrawalFinished(msg.sender, address(this).balance);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}