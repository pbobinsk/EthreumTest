// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Faucet {
    event Withdrawal(address indexed to, uint256 amount);
    event Deposit(address indexed from, uint256 amount);

    // Funkcja odbierająca wpłaty
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Funkcja wypłacająca
    function withdraw(uint256 withdraw_amount) public {
        require(withdraw_amount <= 0.1 ether, "Max 0.1 ETH");
        require(address(this).balance >= withdraw_amount, "Pusty kran!");

        (bool success, ) = msg.sender.call{value: withdraw_amount}("");
        require(success, "Blad przelewu!");

        emit Withdrawal(msg.sender, withdraw_amount);
    }

    // Sprawdzanie salda
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}