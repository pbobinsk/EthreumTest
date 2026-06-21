// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockArbitrageDEX {
    IERC20 public token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    // Symulacja nieefektywnego rynku. Oddajemy 120% tego, co otrzymujemy.
    function swapAtInefficientRate(uint256 amountIn) external {
        // Pobieramy tokeny od pożyczkobiorcy (wymaga to wcześniejszego 'approve'!)
        require(token.transferFrom(msg.sender, address(this), amountIn), "Transfer do DEX nieudany");

        // Obliczamy 120% zwrotu
        uint256 amountOut = (amountIn * 120) / 100;

        require(token.balanceOf(address(this)) >= amountOut, "Brak plynnosci na DEX");
        token.transfer(msg.sender, amountOut);
    }
}