
# Scenariusz: Wielopoziomowe transfery ERC-721 (PBoNFT)

Scenariusz demonstruje dwa podstawowe sposoby przesyłania aktywów NFT w standardzie ERC-721: 

**transfer bezpośredni (P2P)** oraz 
**transfer za pośrednictwem autoryzowanego adresu (Approve + transferFrom)**.

---

## Aktorzy (Konta Sepolia)

*   **Konto A (Wykładowca / Admin / Spender):** Twórca kolekcji, posiada prawa do wybicia (mintowania) tokenów oraz występuje w roli autoryzowanego pośrednika.
*   **Konto B (Student 1 / Pierwotny właściciel):** Odbiorca pierwszych tokenów, aktualny dysponent majątku.
*   **Konto C (Student 2 / Odbiorca końcowy):** Adres docelowy, który na końcu gromadzi oba tokeny.

---

## Przebieg symulacji

### Krok 1: Wdrożenie i Emisja (Mint)
*   **Kto wykonuje:** Konto A 
*   **Akcja:** Wywołuje funkcję `mint(Konto B)` dwukrotnie.
*   **Efekt na blockchainie:** 
    *   Wybity zostaje **Token #0** przypisany do adresu Konta B.
    *   Wybity zostaje **Token #1** przypisany do adresu Konta B.
*   **Stan posiadania (balances):**
    *   `balanceOf(Konto B)` = `2` (posiada Token #0 i Token #1)
    *   `balanceOf(Konto C)` = `0`

---

### Krok 2: Transfer bezpośredni (Peer-to-Peer)
*   **Kto wykonuje:** Konto B.
*   **Akcja:** Wywołuje funkcję `safeTransferFrom(Konto B, Konto C, 0, "")`.
*   **Efekt na blockchainie:** 
    *   Konto B przesyła **Token #0** bezpośrednio do Konta C.
    *   Ponieważ Konto B jest właścicielem Tokenu #0, transakcja nie wymagała żadnych wcześniejszych uprawnień.
*   **Stan posiadania (balances):**
    *   `balanceOf(Konto B)` = `1` (posiada Token #1)
    *   `balanceOf(Konto C)` = `1` (posiada Token #0)

---

### Krok 3: Autoryzacja pośrednika (Approve)
*   **Kto wykonuje:** Konto B – nadal na tym samym koncie.
*   **Akcja:** Wywołuje funkcję `approve(Konto A, 1)`.
*   **Efekt na blockchainie:** 
    *   Konto B oficjalnie udziela uprawnień Kontu A do rozporządzania **Tokenem #1**.
    *   Konto B wciąż pozostaje fizycznym właścicielem tego tokenu, ale Konto A ma już „zielone światło” na jego transfer.

---

### Krok 4: Transfer przez uprawnionego pośrednika (transferFrom)
*   **Kto wykonuje:** Konto A.
*   **Akcja:** Wywołuje funkcję `transferFrom(Konto B, Konto C, 1)`.
*   **Efekt na blockchainie:** 
    *   Konto A inicjuje transfer **Tokenu #1** z adresu Konta B na adres Konta C.
    *   Transakcja przechodzi pomyślnie i jest opłacana za gaz przez Konto A, ponieważ Konto B wcześniej udzieliło wymaganej zgody w kroku 3.

---

## Stan Końcowy (Final State)

Po zakończeniu wszystkich czterech kroków, stan bazy danych smart kontraktu na sieci Sepolia prezentuje się następująco:

| Konto | Saldo (`balanceOf`) | Posiadane Tokeny | Rola / Status |
| :--- | :--- | :--- | :--- |
| **Konto A** | **`0`** | Brak | Twórca/Wdrożeniowiec. Nie posiada tokenów, ale zachowuje prawo do bicia nowych oraz do pobierania 5% tantiem (Royalty) przy ewentualnej sprzedaży wtórnej. |
| **Konto B** | **`0`** | Brak | Pierwotny właściciel, który pomyślnie zbył swoje aktywa. |
| **Konto C** | **`2`** | **Token #0**, **Token #1** | Odbiorca docelowy. Posiada pełną i wyłączną własność obu tokenów w kolekcji. |

---

## 💡 Kluczowe wnioski edukacyjne dla studentów

1.  **Dwa sposoby transferu:** Krok 2 pokazuje prosty, bezpośredni transfer właścicielski. Krok 3 i 4 demonstrują architekturę, na której opierają się wszystkie rynki NFT (np. OpenSea) – użytkownik nie oddaje swoich tokenów giełdzie, a jedynie udziela jej uprawnienia (`approve`), aby ta dokonała bezpiecznej wymiany w momencie zakupu [1.1.2, 1.2.9].
2.  **Suwerenność własności:** Twórca kontraktu (Konto A), pomimo uprawnień deweloperskich (`admin`), nie mógłby dotknąć ani przesłać Tokenu #1 w kroku 4, gdyby właściciel (Konto B) nie wywołał wcześniej funkcji `approve` [1.1.2].