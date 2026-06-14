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

# Iluzja prywatności, czyli jak czytać surowy dysk EVM.

### Koncepcja 
> *"W językach takich jak Java, C++ czy C#, jeśli oznaczycie zmienną jako `private`, obiekt jest chroniony. Inne klasy nie mają do niej dostępu. Kompilator pilnuje hermetyzacji.
> A jak to działa w blockchainie? Napiszemy teraz Sejf. Zamkniemy w nim testowe Ethery i zabezpieczymy je zmienną `private`. Przycisk odczytu zniknie z interfejsu. Ale czy na poziomie fizycznego dysku węzłów (Storage) cokolwiek jest prywatne? Za chwilę udowodnimy wam, że dla inżyniera niskopoziomowego słówko `private` to tylko sugestia."*

---

### Krok 1: Podatny kod (plik `Sejf.sol`)


---

### Krok 2: Wdrożenie Sejfu (Zasilenie z ukrytym hasłem)

1. Skompiluj `Sejf.sol`.
2. Przejdź do zakładki *Deploy*. Upewnij się, że masz **Injected Provider - MetaMask**.
3. **Ważne przygotowanie do Deployu:**
   * Obok przycisku Deploy rozwiń strzałkę w dół, aby zobaczyć pole na nasze hasło (`_haslo`).
   * EVM wymaga 32 bajtów (bytes32). Wpiszmy "haslo123" dopełnione zerami:
     `0x6861736c6f313233000000000000000000000000000000000000000000000000`
   * Ponad przyciskiem Deploy, w polu **VALUE**, wpisz np. `0.01` i zmień na **Ether**. (Chcemy, żeby Sejf od początku miał w sobie nagrodę dla hakera).
4. Kliknij **Transact** i potwierdź w MetaMasku. Czekamy 12 sekund na wykopanie bloku.

---

### Krok 3: Analiza iluzji (Co widać z zewnątrz?)

Kiedy kontrakt się wdroży, rozwiń go w lewym dolnym rogu. Zobaczysz tylko trzy przyciski:
*   `wlasciciel` (niebieski)
*   `sprawdzSaldo` (niebieski - pokaże 10000000000000000 Wei, czyli 0.01 ETH)
*   `wlamanie` (pomarańczowy)

> *"Gdzie jest przycisk do odczytania zmiennej `tajneHaslo`? Nie ma go! Kompilator usunął interfejs dostępu, bo użyliśmy słowa `private`. Normalny użytkownik nie ma szans zgadnąć ciągu 64 znaków hexadecymalnych. Sejf wydaje się bezpieczny."*

---

### Krok 4: HAKOWANIE – Czytamy surowy twardy dysk (Storage)!

Teraz wchodzimy na poziom sprzętowy. Ominiemy Remix, ominiemy język Solidity i wyślemy bezpośrednie zapytanie (RPC Call) do węzła Ethereum, aby odczytał surową pamięć z dysku twardego.

1. **Skopiuj adres** swojego wdrożonego Sejfu.
2. Na samym dole środowiska Remix masz ciemną konsolę (tam gdzie są logi transakcji). Na samym dole tej konsoli znajduje się pasek, w którym możesz wpisywać komendy (znak zachęty `>`). To jest konsola JavaScript z wbudowanym dostępem do sieci (biblioteka `web3`).
3. Wpisz w tę konsolę następującą komendę (podmieniając adres na ten skopiowany):

```javascript
await web3.eth.getStorageAt("WKLEJ_TUTAJ_ADRES_SEJFU", 1)
```

**Dlaczego wpisujemy "1"? :**
> *"EVM zapisuje zmienne globalne w tzw. Slotach Pamięci (każdy ma 32 bajty). Slot `0` to pierwsza zmienna w kodzie (`wlasciciel`). Nasze `tajneHaslo` to druga zmienna w kodzie, więc kompilator umieścił ją w Slocie nr `1`. Funkcja `getStorageAt` nakazuje węzłowi ominąć wszystkie zabezpieczenia języka C/Solidity i po prostu zrzucić na ekran fizyczną zawartość danego klastra pamięci."*

4. Wciśnij **Enter**.

### Krok 5: Wielki Finał
W konsoli Remix jako odpowiedź natychmiast wyświetli się ciąg:
`"0x6861736c6f313233000000000000000000000000000000000000000000000000"`

Właśnie odczytaliśmy "prywatne" hasło z twardego dysku blockchaina!
Teraz po prostu skopiuj ten ciąg znaków, wklej go do pomarańczowego przycisku **`wlamanie`** i go kliknij.
Podpisz transakcję w MetaMasku. 

Po wykopaniu bloku kliknij **`sprawdzSaldo`**. Wynik? `0`. Twój Sejf został opróżniony, a 0.01 ETH bezpiecznie wróciło do Twojego portfela!

---
---

**Composability (Kompozycyjność)**, nazywanej potocznie "Finansowymi Klockami Lego" (Money Legos). 

Skoro oba kontrakty (Kranik i Sejf) żyją w tej samej maszynie EVM, mogą ze sobą rozmawiać. Ale żeby Sejf pobrał pieniądze z Kranika, musimy rozwiązać **dwa problemy niskopoziomowe**.

### Problem 1: Kto jest nadawcą? (`msg.sender`)
Nasz Kranik ma wpisane: `msg.sender.call{value: ...}`. Wysyła pieniądze temu, kto pociągnął za wajchę. 
Nie możemy więc z naszego portfela (MetaMaska) powiedzieć Kranikowi: *"Przelej Sejfowi"*. **To Sejf musi sam zadzwonić do Kranika!** Dla Kranika to Sejf będzie wtedy `msg.sender`em.

### Problem 2: Tarcza ochronna Sejfu
Jeśli zmusimy Sejf, by zadzwonił do Kranika, Kranik wyśle mu Ether. Ale nasz obecny Sejf **nie ma funkcji `receive() external payable`**! EVM automatycznie odbije ten przelew (Opcode `REVERT`), a transakcja upadnie. 

---

### Rozwiązanie: Robimy z Sejfu autonomicznego bota!

Plik `Sejf.sol`.

---

### Jak przeprowadzić ten atak na żywo? (Scenariusz)

**Krok 1: Wdrażamy Sejf**
1. Skompiluj nowy `Sejf.sol`.
2. Wdróż go z pustym balansem początkowym (VALUE = 0), podając w konstruktorze nasze hasło:
   `0x6861736c6f313233000000000000000000000000000000000000000000000000`
3. Kliknij **Deploy** i podpisz w MetaMasku.

**Krok 2: Sprawdzamy początkowy stan**
1. W Remixie rozwiń wdrożony Sejf.
2. Kliknij `sprawdzSaldo`. **Wynik to 0.** Nasz Sejf jest pusty.

**Krok 3: Autonomiczna akcja maszyny (Sejf idzie do Kranu)**
1. Wklej skopiowany wcześniej **adres Kranika** w pole obok pomarańczowego przycisku **`napadNaKran`**.
2. Kliknij **`napadNaKran`**. MetaMask poprosi o podpis. (Zwróć uwagę, że płacisz tylko za Gas, nie wysyłasz żadnego swojego Etheru!).
3. Poczekaj na wykopanie bloku.

**Krok 4: Weryfikacja**
1. Kliknij ponownie **`sprawdzSaldo`** w Sejfie.
2. Wynik: **`50000000000000000`** (0.05 ETH w Wei). 
3. *Sukces!* Sejf skontaktował się z Kranem i wessał jego zasoby do siebie.
4. Teraz możesz użyć sztuczki z odczytem z twardego dysku (poprzedni warsztat), żeby zdobyć hasło i ukraść to 0.05 ETH z Sejfu do własnego MetaMaska!

---

