// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEthFlashLender {
    function flashLoan(address borrower, uint256 amount) external;
}

interface IEthMockDEX {
    function swapAtInefficientRate() external payable;
}

contract EthFlashBorrower {
    address public lender;
    address public dex;
    address public owner;

    event ArbitrageExecuted(uint256 borrowed, uint256 returnedFromDEX, uint256 profit);

    constructor(address _lender, address _dex) {
        lender = _lender;
        dex = _dex;
        owner = msg.sender;
    }

    // Bez tego kontrakt nie mógłby przyjąć zwrotu ETH z DEX ani od Lendera
    receive() external payable {}

    // Wywoływane przez bank
    function executeOperation(uint256 fee) external payable returns (bool) {
        require(msg.sender == lender, "Tylko Lender");
        uint256 amountBorrowed = msg.value;

        // 1. Przesyłamy całe pożyczone ETH na DEX (używamy {value: ...})
        IEthMockDEX(dex).swapAtInefficientRate{value: amountBorrowed}();

        // 2. Sprawdzamy nasz stan posiadania po udanym swapie (powinno być 120%)
        uint256 currentBalance = address(this).balance;
        uint256 totalToRepay = amountBorrowed + fee;

        require(currentBalance >= totalToRepay, "Za maly zysk na splate");

        // 3. Odsyłamy pożyczkę + prowizję do banku
        (bool success, ) = lender.call{value: totalToRepay}("");
        require(success, "Splata pozyczki nieudana");

        uint256 netProfit = address(this).balance;
        emit ArbitrageExecuted(amountBorrowed, amountBorrowed * 120 / 100, netProfit);

        return true;
    }

    function startFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Tylko owner");
        IEthFlashLender(lender).flashLoan(address(this), amount);
    }

    // // Wypłata zysków w ETH dla dewelopera
    // function withdrawProfit() external {
    //     require(msg.sender == owner, "Tylko owner");
    //     payable(owner).transfer(address(this).balance);
    // }

// Wypłata zysków w ETH dla dewelopera
function withdrawProfit() external {
    require(msg.sender == owner, "Tylko owner");
    
    // Zastępujemy .transfer() bezpieczniejszym niskopoziomowym .call
    // Zwróć uwagę, że przy .call zmienna 'owner' nie musi być nawet rzutowana na 'payable'!
    (bool success, ) = owner.call{value: address(this).balance}("");
    require(success, "Wyplata nieudana");
}

}