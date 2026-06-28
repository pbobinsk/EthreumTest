// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract StakingPool is ReentrancyGuard {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    // Stawka nagrody: 1 zablokowany token MTK (10^18 wei) generuje 10^13 wei nagrody na sekundę.
    // Pozwala to na szybki przyrost nagród dla celów pokazowych na frontendzie.
    uint256 public rewardRate = 1e13; 

    // Baza danych puli
    mapping(address => uint256) public stakingBalance; // Ile tokenów dany adres zablokował
    mapping(address => uint256) public lastUpdateTime;  // Kiedy ostatnio naliczono nagrody dla adresu
    mapping(address => uint256) public rewards;         // Zgromadzone, gotowe do wypłaty nagrody

    uint256 public totalStaked; // Łączna suma tokenów zablokowanych w puli przez wszystkich

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    // Modyfikator, który aktualizuje stan nagród użytkownika PRZED wykonaniem jakiejkolwiek akcji
    modifier updateReward(address account) {
        rewards[account] = earned(account);
        lastUpdateTime[account] = block.timestamp;
        _;
    }

    // Funkcja typu VIEW - oblicza aktualnie należną nagrodę (zapisaną + naliczaną na bieżąco)
    // Będzie stale odpytywana przez nasz Web3 Frontend
    function earned(address account) public view returns (uint256) {
        if (stakingBalance[account] == 0) {
            return rewards[account];
        }
        
        uint256 timeElapsed = block.timestamp - lastUpdateTime[account];
        
        // Matematyka: Saldo * Czas * Stawka / 10^18 (aby zniwelować skalę wei)
        uint256 pendingReward = (stakingBalance[account] * timeElapsed * rewardRate) / 1e18;
        return rewards[account] + pendingReward;
    }

    // Deponowanie (blokowanie) tokenów w puli
    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Kwota musi byc wieksza niz 0");
        
        stakingBalance[msg.sender] += amount;
        totalStaked += amount;
        
        // Pobieramy tokeny od użytkownika do kontraktu
        // (UWAGA: Wymaga wcześniejszego wywołania 'approve' na kontrakcie tokenu przez użytkownika!)
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer do puli nieudany");
        
        emit Staked(msg.sender, amount);
    }

    // Wycofanie zablokowanych tokenów z puli
    function withdraw(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Kwota musi byc wieksza niz 0");
        require(stakingBalance[msg.sender] >= amount, "Za malo zablokowanych srodkow");

        stakingBalance[msg.sender] -= amount;
        totalStaked -= amount;
        
        // Zwracamy zablokowane tokeny użytkownikowi
        require(stakingToken.transfer(msg.sender, amount), "Transfer zwrotny nieudany");
        
        emit Withdrawn(msg.sender, amount);
    }

    // Wypłata samych zgromadzonych nagród (bez wycofywania zablokowanego kapitału)
    function claimReward() external nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            
            // Wypłacamy nagrodę z puli nagród kontraktu
            require(rewardToken.transfer(msg.sender, reward), "Wyplata nagrody nieudana");
            
            emit RewardPaid(msg.sender, reward);
        }
    }
}