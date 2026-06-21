Dwa scenariusze warsztatowe przeprowadzone na sieci testowej Sepolia. 

***

# Flash Loan & Arbitrage Simulation on Sepolia Testnet

Niniejsze repozytorium zawiera materiały dydaktyczne do przeprowadzenia symulacji pożyczek błyskawicznych (Flash Loans) oraz arbitrażu w środowisku wieloosobowym (3 niezależne role). Scenariusz pokazuje działanie atomowości transakcji w EVM oraz interakcji typu smart contract-to-smart contract bezpośrednio na sieci testowej Sepolia.

---

## 👥 Role i Konta (Aktorzy systemu)

Do przeprowadzenia pełnej symulacji wymagane są 3 osobne konta MetaMask podłączone do sieci Sepolia:

1.  **Konto 1: DEX Owner (Giełdziarz)** – Dostarcza płynność na giełdę o nieefektywnym kursie wymiany (oddaje 120% zdeponowanej kwoty).
2.  **Konto 2: Lender (Bankier)** – Właściciel puli pożyczkowej, udostępnia kapitał i pobiera 1% prowizji.
3.  **Konto 3: Borrower (Arbitrażysta)** – Haker/Trader, który bez własnego kapitału inicjuje transakcję, zarabia na błędzie wyceny i spłaca pożyczkę z zyskiem.

*Uwaga: Każde z trzech kont musi posiadać niewielką ilość Sepolia ETH na pokrycie opłat za gaz (gas fees).*

---

## 🛠️ Scenariusz A: Pożyczka błyskawiczna w natywnym ETH

Z powodu ograniczeń darmowych kraników (faucetów) na sieci Sepolia, w tym scenariuszu operujemy na mniejszych, przeskalowanych ułamkach ETH.

### 1. Przygotowanie i Wdrożenie (Deploy)
1.  **Giełdziarz (Konto 1)**:
    *   Wybiera w Remix środowisko `Injected Provider - MetaMask` (Konto 1).
    *   Wdraża kontrakt `EthMockDEX.sol`.
    *   Zasila kontrakt płynnością: ustawia **Value** na `0.2 Ether` i klika **Transact** w sekcji *Low level interaction* (puste calldata).
2.  **Bankier (Konto 2)**:
    *   Przełącza się w MetaMask na Konto 2.
    *   Wdraża kontrakt `EthFlashLender.sol`.
    *   Zasila pulę: ustawia **Value** na `0.5 Ether` i klika **Transact** w sekcji *Low level interaction* (puste calldata).
3.  **Arbitrażysta (Konto 3)**:
    *   Przełącza się w MetaMask na Konto 3.
    *   Wdraża kontrakt `EthFlashBorrower.sol`, podając w konstruktorze adresy kontraktów od Bankiera i Giełdziarza.
    *   *Ważne:* Saldo początkowe kontraktu pożyczkobiorcy wynosi **0 ETH**.

### 2. Wykonanie i Wyniki
1.  **Arbitrażysta (Konto 3)**:
    *   Upewnia się, że ma ustawione **Value** na `0 Ether` w Remixie.
    *   W swoim kontrakcie wywołuje funkcję `startFlashLoan`, podając wartość `0.1 * 10**18` (czyli pożyczamy **0.01 ETH**).
    *   Podpisuje transakcję w MetaMask.
    *   **Powtarzamy** raz jeszcze
2.  **Analiza salda po transakcji na Sepolia Etherscan**:
    *   `EthFlashLender` (Bank) posiada teraz **0.502 ETH** (0.5 ETH wkładu + 1% prowizji).
    *   `EthMockDEX` (Giełda) posiada teraz **0.16 ETH** (straciła 0.04 ETH zysku).
    *   `EthFlashBorrower` (Nasz kontrakt) posiada teraz **0.038 ETH** zysku, mimo startu z zerowym kapitałem.
    *   Konto 3 wywołuje funkcję `withdrawProfit()`, aby przelać zysk bezpośrednio na swój portfel.

---

## 🪙 Scenariusz B: Pożyczka błyskawiczna w tokenie ERC-20 (MTK)

W tym scenariuszu używamy własnego, ustandaryzowanego tokenu ERC-20. Ponieważ tokeny MTK są darmowe, możemy operować na pełnych, dużych liczbach.

### 1. Przygotowanie i Wdrożenie (Deploy)
1.  **Arbitrażysta/Twórca (Konto 3)**:
    *   Wdraża kontrakt tokenu `MojeTokeny.sol` (MTK), generując np. `1 000 000 MTK`.
2.  **Giełdziarz (Konto 1)**:
    *   Przełącza się na Konto 1 i wdraża `MockArbitrageDEX.sol`, wskazując adres kontraktu MTK.
    *   *Zasilenie:* Konto 3 przesyła na kontrakt giełdy **200 MTK** za pomocą funkcji `transfer`.
3.  **Bankier (Konto 2)**:
    *   Przełącza się na Konto 2 i wdraża `FlashLender.sol`, wskazując adres kontraktu MTK.
    *   *Zasilenie:* Konto 3 przesyła na kontrakt banku **500 MTK** za pomocą funkcji `transfer`.
4.  **Arbitrażysta (Konto 3)**:
    *   Wdraża `FlashBorrower.sol`, podając w konstruktorze adresy: MTK, banku i giełdy.
    *   *Ważne:* Saldo kontraktu `FlashBorrower` wynosi **0 MTK**.

### 2. Wykonanie i Wyniki
1.  **Arbitrażysta (Konto 3)**:
    *   Wywołuje `startFlashLoan` na swoim kontrakcie, pożyczając `100 * 10**18` (**100 MTK**).
    *   Podpisuje transakcję.
2.  **Analiza końcowa**:
    *   `FlashLender` posiada teraz **501 MTK** (+1 MTK zysku z prowizji).
    *   `MockArbitrageDEX` posiada teraz **180 MTK** (stracił 20 MTK zysku).
    *   `FlashBorrower` posiada **19 MTK** czystego zysku, który powstał w ramach tej samej transakcji i może zostać wypłacony funkcją `withdrawProfit()`.

---

