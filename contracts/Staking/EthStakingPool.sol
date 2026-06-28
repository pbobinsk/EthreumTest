// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EthStakingPool is ReentrancyGuard {
    IERC20 public rewardToken; // Token nagrody (nasz MTK)

    // Stawka nagrody: 1 zablokowany Ether (10^18 wei) generuje 10^13 wei tokenu MTK na sekundę.
    uint256 public rewardRate = 1e13; 

    mapping(address => uint256) public stakingBalance; // Ile ETH dany adres zablokował
    mapping(address => uint256) public lastUpdateTime;  // Kiedy ostatnio naliczono nagrody dla adresu
    mapping(address => uint256) public rewards;         // Zgromadzone nagrody w tokenach MTK

    uint256 public totalStaked; // Łączna suma ETH zablokowana w puli przez wszystkich

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    modifier updateReward(address account) {
        rewards[account] = earned(account);
        lastUpdateTime[account] = block.timestamp;
        _;
    }

    // Oblicza wygenerowaną nagrodę w MTK na podstawie zablokowanego ETH i czasu
    function earned(address account) public view returns (uint256) {
        if (stakingBalance[account] == 0) {
            return rewards[account];
        }
        
        uint256 timeElapsed = block.timestamp - lastUpdateTime[account];
        
        // Obliczenia: Saldo ETH * Czas * Stawka / 10^18
        uint256 pendingReward = (stakingBalance[account] * timeElapsed * rewardRate) / 1e18;
        return rewards[account] + pendingReward;
    }

    // Deponowanie ETH w puli (Funkcja oznaczona jako PAYABLE)
    function stake() external payable nonReentrant updateReward(msg.sender) {
        require(msg.value > 0, "Kwota musi byc wieksza niz 0 ETH");
        
        stakingBalance[msg.sender] += msg.value;
        totalStaked += msg.value;
        
        emit Staked(msg.sender, msg.value);
    }

    // Wycofanie zablokowanego ETH z puli
    function withdraw(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Kwota musi byc wieksza niz 0");
        require(stakingBalance[msg.sender] >= amount, "Za malo zablokowanych srodkow");

        stakingBalance[msg.sender] -= amount;
        totalStaked -= amount;
        
        // Zwracamy zablokowany Ether użytkownikowi przy użyciu bezpiecznego .call
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer zwrotny ETH nieudany");
        
        emit Withdrawn(msg.sender, amount);
    }

    // Wypłata zgromadzonych nagród w tokenach MTK
    function claimReward() external nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            
            // Wypłacamy tokeny MTK (pula musi mieć je w swoim sejfie!)
            require(rewardToken.transfer(msg.sender, reward), "Wyplata nagrody nieudana");
            
            emit RewardPaid(msg.sender, reward);
        }
    }
}