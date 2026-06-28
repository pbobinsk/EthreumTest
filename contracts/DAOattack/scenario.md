### Scenariusz Pokazu na Sepolii (3 Konta)

#### Konta:
*   **Konto 1** – Ofiara 1 (Inwestor DAO)
*   **Konto 2** – Ofiara 2 (Inwestor DAO)
*   **Konto 3** – Haker (Właściciel kontraktu Atakującego)

---

### Faza 1: Tworzenie i finansowanie DAO (Inwestorzy budują pulę)

1.  **Wdrożenie kontraktu przez Ofiarę 1 (Konto A):**
    *   W MetaMask przełącz się na **Konto A**.
    *   Wdróż kontrakt `VictimDAO.sol`. (Zatwierdź transakcję w MetaMask, poczekaj na zapisanie bloku na Sepolii).
2.  **Wpłata od Ofiary 1 (Konto A):**
    *   W polu **Value** wpisz **`0.2` Ether**.
    *   Kliknij pomarańczowy przycisk **`deposit`** w `VictimDAO`. Zatwierdź transakcję.
3.  **Wpłata od Ofiary 2 (Konto B):**
    *   Przełącz się w MetaMask na **Konto B**.
    *   Upewnij się, że pole *Value* ma nadal **`0.2` Ether**.
    *   Kliknij przycisk **`deposit`** w `VictimDAO`. Zatwierdź transakcję.
4.  **Weryfikacja (Stan przed atakiem):**
    *   Kliknij niebieski przycisk **`getContractBalance`** na kontrakcie `VictimDAO`.
    *   **Wynik:** Powinieneś zobaczyć dokładnie **`400000000000000000` Wei (0.4 ETH)**. Pula DAO została sfinansowana przez uczciwych inwestorów.

0xC812887C584D1405b9c6878a14968635576ffD12


---

### Faza 2: Przygotowanie i przeprowadzenie ataku (Haker działa)

1.  **Wdrożenie bota przez Hakera (Konto C):**
    *   Przełącz się w MetaMask na **Konto C**.
    *   Skopiuj adres kontraktu `VictimDAO`.
    *   Wdróż kontrakt `Attacker.sol`, wklejając skopiowany adres w pole konstruktora. Zatwierdź w MetaMask.

0x81800e9C0F4406E6c20d2C7d49bB8dFb99B4a87b

2.  **Inicjacja ataku (Konto C):**
    *   Skonfiguruj transakcję: ustaw u góry **Value** na dokładnie **`0.1` Ether** (to jest kapitał początkowy niezbędny, by haker mógł wywołać procedurę wypłaty).
    *   W sekcji kontraktu `Attacker` kliknij pomarańczowy przycisk **`attack`**. Zatwierdź transakcję w MetaMask.
    *   *Uwaga: Ponieważ ta transakcja wykonuje pętlę reentrancy (aż 5 odrębnych wejść i transferów w ramach jednego wywołania), transakcja zużyje nieco więcej gazu niż zwykle. Limit gazu powinien dostosować się automatycznie w MetaMasku.*

---

### Faza 3: Analiza strat i konsumpcja łupu

Po potwierdzeniu transakcji na sieci Sepolia przeanalizujcie wyniki:

1.  **Sprawdzenie salda ofiary:**
    *   Kliknij `getContractBalance` w `VictimDAO`.
    *   **Wynik: `0`**. Całe 0.4 ETH zniknęło z puli inwestorów.
2.  **Sprawdzenie salda hakera:**
    *   Kliknij `getContractBalance` w `Attacker`.
    *   **Wynik: `500000000000000000` (0.5 ETH)**. Haker odzyskał swój wpłacony wkład (0.1 ETH) i wyprowadził całe 0.4 ETH należące do inwestorów (Konta A i B).
3.  **Wypłata środków:**
    *   Będąc nadal na **Koncie C**, kliknij funkcję **`withdrawFunds`** na kontrakcie `Attacker`.
    *   Skradzione 0.5 ETH ląduje bezpośrednio na Twoim koncie MetaMask.

---

### Analiza na Sepolia Etherscan


1.  Skopiuj hash transakcji wywołania funkcji `attack` i wklej go na stronie **[sepolia.etherscan.io](https://sepolia.etherscan.io/)**.
2.  Przejdź do zakładki **Internal Transactions** (Transakcje Wewnętrzne).
3.  Zobacz logi w `VictimDAO`

## Zabezpieczenie

VictimDAOsafe

0x7E2eFbF882cAc91ce714b117Ff9916Ca29B612d4

Attacker na ten kontrakt

0xa73544928Dbac4758003975c7DF2ef0Fe7f5dbB4

VictimDAOsafe1 - contract VictimDAOsafe  is ReentrancyGuard {

0x05c95dCc27A4f3255BCF308B8db64190aC63DAA1

Attacker na ten kontrakt

0x117a0BD96B9d458ED6284032CDE6A7E60BF995d0