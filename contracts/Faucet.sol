// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Faucet {
    
    // 1. Magiczna funkcja odbierająca wpłaty. 
    // Słówko 'payable' wyłącza sprzętową blokadę EVM.
    receive() external payable {}

    // 2. Wypłaca równe 1 ETH każdemu, kto zawoła tę funkcję
    function withdrawOneEther() public {
        // Zabezpieczenie: czy w kranie jest wystarczająco dużo wody?
        require(address(this).balance >= 1 ether, "Brak srodkow w kranie!");
        
        // Niskopoziomowy transfer środków do osoby wywołującej
        //payable(msg.sender).transfer(1 ether);
    
        // NOWA, NISKOPOZIOMOWA METODA TRANSFERU:
        // Używamy opcode'u CALL. Zwraca on dwie wartości:
        // 1. success (bool) - czy się udało
        // 2. data (bytes) - ewentualne dane zwrotne (tu ignorujemy, stąd puste miejsce po przecinku)
        (bool success, ) = msg.sender.call{value: 1 ether}("");
        
        // Musimy ręcznie sprawdzić, czy przelew się udał!
        require(success, "Blad transferu!");
    }


    // 3. Sprawdza, ile kontrakt ma pieniędzy (w Wei)
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}