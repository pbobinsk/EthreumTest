// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. Definiujemy Interfejs: "Mówimy" Sejfowi, jak wygląda funkcja w Kraniku
interface IKranik {
    function withdraw(uint256 withdraw_amount) external;
}

contract Sejf {
    address public wlasciciel;
    bytes32 private tajneHaslo;

    // 2. NOWOŚĆ: Pozwalamy Sejfowi przyjmować przelewy (np. z Kranika!)
    receive() external payable {}

    constructor(bytes32 _haslo) payable {
        wlasciciel = msg.sender;
        tajneHaslo = _haslo;
    }

    // 3. NOWOŚĆ: Funkcja zlecająca Sejfowi napad na Kranik
    function napadNaKran(address adresKranu) public {
        // Tworzymy "uchwyt" do Kranika
        IKranik kran = IKranik(adresKranu);
        
        // Sejf sam z siebie dzwoni do Kranika i prosi o 0.05 ETH.
        // Wewnątrz Kranika, 'msg.sender' to będzie adres NASZEGO SEJFU!
        kran.withdraw(0.015 ether);
    }

    function wlamanie(bytes32 podaneHaslo) public {
        require(podaneHaslo == tajneHaslo, "Zle haslo!");
        uint256 calyMajatek = address(this).balance;
        (bool sukces, ) = msg.sender.call{value: calyMajatek}("");
        require(sukces, "Przelew nie udany");
    }

    function sprawdzSaldo() public view returns (uint256) {
        return address(this).balance;
    }
}