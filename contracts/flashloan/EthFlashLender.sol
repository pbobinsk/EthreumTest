// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEthFlashBorrower {
    function executeOperation(uint256 fee) external payable returns (bool);
}

contract EthFlashLender {
    uint256 public feePercent = 1; // 1% prowizji

    event FlashLoanSuccessful(address indexed borrower, uint256 amount, uint256 fee);

    // Pozwala na wpłacanie ETH do puli banku (np. z konta w Remix)
    receive() external payable {}

    function flashLoan(address borrower, uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Za malo ETH w puli");

        uint256 fee = (amount * feePercent) / 100;

        // 1. Przekazujemy ETH (value: amount) i wywołujemy executeOperation u pożyczkobiorcy
        require(
            IEthFlashBorrower(borrower).executeOperation{value: amount}(fee),
            "Operacja nieudana"
        );

        // 2. Sprawdzamy czy pożyczka wróciła z prowizją
        uint256 balanceAfter = address(this).balance;
        require(balanceAfter >= balanceBefore + fee, "Pozyczka nie zostala splacona z prowizja");

        emit FlashLoanSuccessful(borrower, amount, fee);
    }
}