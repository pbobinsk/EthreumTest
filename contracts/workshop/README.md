# Warsztat EVM: Cykl życia Smart Kontraktu i przepływ środków (Ethereum)

Ten dokument opisuje pełny proces tworzenia, wdrażania i interakcji ze Smart Kontraktem (Kranikiem/Faucet) w publicznej sieci testowej Ethereum. Krok po kroku pokazujemy, jak wirtualna maszyna (EVM) przetwarza kod maszynowy i zarządza kryptowalutą na poziomie sprzętowym.

---

## KROK 1: Środowisko i zdobycie testowego Etheru (Sepolia)

1. **Instalacja portfela:** Zainstaluj rozszerzenie **MetaMask** w przeglądarce i utwórz portfel.
2. **Włączenie sieci testowych:** W ustawieniach MetaMaska włącz opcję *Pokaż sieci testowe* i przełącz się na sieć **Sepolia**.
3. **Kranik Proof of Work (PoW):**
   * Wejdź na stronę np. [sepolia-faucet.pk910.de](https://sepolia-faucet.pk910.de/).
   * Wklej swój adres z MetaMaska i rozpocznij "kopanie" (Start Mining).
   * *Kranik zmusza nasz procesor do liczenia haszy (Proof of Work), aby zapobiec atakom botów (Sybil Attack). Koszt prądu jest tu zabezpieczeniem antyspamowym.*
4. Odbierz wykopane środki (np. `0.26 Sepolia ETH`).

---

## KROK 2: Kod kontraktu (Remix IDE)

1. Wejdź na [remix.ethereum.org](https://remix.ethereum.org/).
2. W eksploratorze plików utwórz nowy plik `Faucet.sol`.
3. Wklej kod.

---

## KROK 3: Kompilacja i Wdrożenie (Deploy)

1. **Kompilacja do asemblera:** 
   * Przejdź do zakładki *Solidity Compiler* (ikona lupy) i kliknij **Compile Faucet.sol**.
   *  *To tu nasz kod obiektowy zamienia się w surowy ciąg instrukcji maszyny stosowej (Opcodes), takich jak `PUSH1`, `SSTORE`, `CALL`.*
2. **Połączenie z MetaMaskiem:** 
   * Przejdź do zakładki *Deploy & Run Transactions* (ikona Ethereum).
   * Zmień **Environment** na **`Injected Provider - MetaMask`**.
   * Wyraź zgodę w oknie MetaMaska na połączenie (Remix zobaczy Twój balans).
3. **Deploy (Wdrożenie):**
   * Kliknij pomarańczowy przycisk **Deploy**.
   * Wyskoczy MetaMask z prośbą o podpisanie transakcji kryptograficznie. Zatwierdź.
   * Poczekaj ok. 12 sekund na dodanie bloku. W konsoli Remixa pojawią się komunikaty o sukcesie i weryfikacji w eksploratorach (np. Sourcify, Blockscout).

---

## KROK 4: Interakcja (Przepływ Pieniądza)

### A) Wpłata środków na kontrakt (Zasilenie Banku)
1. W Remixie, w lewym dolnym rogu w sekcji *Deployed Contracts*, kliknij **ikonę kopiowania** obok adresu swojego kontraktu `Faucet`.
2. Otwórz MetaMaska, kliknij **Wyślij (Send)**.
3. Wklej skopiowany adres kontraktu, podaj kwotę **`0.05 ETH`** i zatwierdź transakcję.
4. *Dlaczego kontrakt nie odrzucił pieniędzy? Ponieważ użyliśmy funkcji `receive() external payable`. Bez modyfikatora `payable`, kompilator wrzuciłby opcode `CALLVALUE` wywołujący `REVERT` (odrzucenie przelewu).*

### B) Odczyt darmowy (Call)
1. W Remixie, rozwiń swój kontrakt i kliknij niebieski przycisk **`getBalance`**.
2. Wynik: `50000000000000000` (Zera wynikają z faktu, że EVM nie ma liczb zmiennoprzecinkowych. Zwraca wartość w najmniejszej jednostce: **Wei**. `1 ETH = 10^18 Wei`).
3. *To była operacja CALL. Kosztowała 0 Gasu, ponieważ węzeł odczytał dane bezpośrednio ze swojego dysku do RAM-u (`SLOAD`), bez modyfikowania globalnego stanu blockchaina.*

### C) Wypłata z użyciem kodu (Transact)
1. Chcemy wypłacić `0.01 ETH`. Musimy podać to w Wei.
2. W pole obok pomarańczowego przycisku **`withdraw`** wpisz: `10000000000000000` (jedynka i 16 zer).
3. Kliknij **withdraw** i zatwierdź koszt wykonania (Gas) w MetaMasku.
4. Po wkopaniu bloku (ok. 12 sekund), kliknij ponownie **`getBalance`**. Saldo kontraktu spadnie do `40000000000000000` (0.04 ETH).
5. Otwórz MetaMaska – ułamek ETH powrócił na Twoje konto!
6. *Pieniądze wróciły do nas dzięki instrukcji `msg.sender.call{value: ...}("")`. Wymusiło to na jądrze systemu (EVM) uaktualnienie tablicy sald na tysiącach komputerów, stąd musieliśmy zapłacić Transaction Fee (Opłatę Transakcyjną).*

---
---

`Sejf.sol`

hasło (private?)

```
await web3.eth.getStorageAt("0xf8f386Bdd10a740a8650a7a3F0C578Ad08Ea6b42", 1)
```
