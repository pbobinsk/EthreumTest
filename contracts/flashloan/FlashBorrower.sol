// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLender {
    function flashLoan(address borrower, uint256 amount) external;
}

interface IMockDEX {
    function swapAtInefficientRate(uint256 amountIn) external;
}

contract FlashBorrower {
    IERC20 public token;
    address public lender;
    address public dex; // Adres naszej giełdy z błędem ceny
    address public owner;

    event ArbitrageExecuted(uint256 borrowed, uint256 returnedFromDEX, uint256 netProfit);

    constructor(address _token, address _lender, address _dex) {
        token = IERC20(_token);
        lender = _lender;
        dex = _dex;
        owner = msg.sender;
    }

    // Wywoływane przez Lender'a (Bank) w trakcie pożyczki
    function executeOperation(uint256 amount, uint256 fee) external returns (bool) {
        require(msg.sender == lender, "Tylko Lender");

        // KROK 1: Zezwalamy DEX-owi na pobranie pożyczonych tokenów (WYKORZYSTUJEMY APPROVE!)
        token.approve(dex, amount);

        // KROK 2: Wykonujemy "zyskowny swap" na giełdzie
        IMockDEX(dex).swapAtInefficientRate(amount);

        // KROK 3: Po wymianie powinniśmy mieć 120% kwoty. Spłatę robimy z zysku!
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalToRepay = amount + fee;

        require(currentBalance >= totalToRepay, "Zysk za maly na splate pozyczki");

        // KROK 4: Oddajemy pożyczkę + prowizję do Lendera
        token.transfer(lender, totalToRepay);

        // KROK 5: Obliczamy czysty zysk, który zostaje na tym kontrakcie
        uint256 netProfit = token.balanceOf(address(this));
        emit ArbitrageExecuted(amount, amount * 120 / 100, netProfit);

        return true;
    }

    function startFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Tylko owner");
        IFlashLender(lender).flashLoan(address(this), amount);
    }

    // Deweloper/Właściciel wypłaca zarobiony łup z kontraktu na swój portfel
    function withdrawProfit() external {
        require(msg.sender == owner, "Tylko owner");
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner, balance);
    }
}