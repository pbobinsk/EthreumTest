// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashBorrower {
    function executeOperation(uint256 amount, uint256 fee) external returns (bool);
}

contract FlashLender {
    IERC20 public token;
    uint256 public feePercent = 1;

    // 1. Definiujemy zdarzenie. Słowo 'indexed' pozwala na późniejsze łatwe filtrowanie po adresie pożyczkobiorcy.
    event FlashLoanSuccessful(address indexed borrower, uint256 amount, uint256 fee);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function flashLoan(address borrower, uint256 amount) external {
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= amount, "Za malo srodkow w puli");

        uint256 fee = (amount * feePercent) / 100;

        token.transfer(borrower, amount);

        require(
            IFlashBorrower(borrower).executeOperation(amount, fee),
            "Operacja pozyczkobiorcy nie powiodla sie"
        );

        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter >= balanceBefore + fee, "Pozyczka nie zostala oddana z prowizja");

        // 2. Emitujemy zdarzenie po udanym zakończeniu całej operacji
        emit FlashLoanSuccessful(borrower, amount, fee);
    }
}