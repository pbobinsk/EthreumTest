// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EthMockDEX {
    // Pozwala na zasilenie giełdy początkowym ETH na wypłatę zysków
    receive() external payable {}

    // Przyjmuje ETH w transakcji i odsyła 120% tej kwoty nadawcy
    function swapAtInefficientRate() external payable {
        uint256 amountIn = msg.value;
        require(amountIn > 0, "Musisz przeslac ETH do wymiany");

        uint256 amountOut = (amountIn * 120) / 100;
        require(address(this).balance >= amountOut, "Brak plynnosci na DEX");

        // Odsyłamy 120% z powrotem do pożyczkobiorcy
        (bool success, ) = msg.sender.call{value: amountOut}("");
        require(success, "Transfer zysku nieudany");
    }
}