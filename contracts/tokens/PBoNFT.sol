// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract PBoNFT is ERC721, ERC2981 {
    uint256 public nextTokenId;
    address public admin;

    // Definiujemy nazwę kolekcji i symbol
    constructor() ERC721("Kolekcja Wykladowcy", "KWNFT") {
        admin = msg.sender;
        
        // USTAWIANIE TANTIEM (ERC-2981):
        // Jako odbiorcę ustawiamy twórcę kontraktu (admina).
        // Jako prowizję podajemy 500 punktów bazowych (basis points).
        // Mianownik wynosi domyślnie 10000, więc 500 / 10000 = 0.05 (czyli równe 5%).
        _setDefaultRoyalty(msg.sender, 500);
    }

    // Funkcja do bicia (mintowania) nowego unikalnego NFT
    function mint(address to) external {
        require(msg.sender == admin, "Tylko admin moze bic NFT");
        _safeMint(to, nextTokenId);
        nextTokenId++;
    }

    // Nadpisujemy supportsInterface, ponieważ występuje w obu dziedziczonych kontraktach.
    // Dzięki temu giełdy (np. OpenSea) wiedzą, że ten kontrakt wspiera zarówno ERC-721, jak i ERC-2981.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}