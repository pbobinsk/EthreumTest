// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importujemy standardowy kontrakt ERC-20 z biblioteki OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PBoToken is ERC20 {
    // W konstruktorze definiujemy nazwę tokenu ("Moje Tokeny") oraz symbol ("MTK")
    constructor(uint256 initialSupply) ERC20("Token PBo", "PBO") {
        
        // Funkcja _mint tworzy tokeny i przypisuje je do nadawcy (twórcy kontraktu).
        // Standardowy ERC-20 od OpenZeppelin ma domyślnie ustawione 18 decimals.
        // Mnożymy wpisaną liczbę przez 10^18, aby użytkownik w Remix mógł wpisać 
        // po prostu "1000", a kontrakt stworzył dokładnie 1000 pełnych tokenów.
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}