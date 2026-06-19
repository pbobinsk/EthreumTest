---

### Część 1: Teoria – Czym różni się „Read” od „Write” na Etherscanie?

| Cecha | Read Contract (Odczyt) | Write Contract (Zapis) |
| :--- | :--- | :--- |
| **Co robi?** | Odpytuje lokalny węzeł o aktualny stan blockchaina (funkcje `view` i `pure`). | Modyfikuje stan blockchaina (zmienia wartości w storage kontraktu). |
| **Koszt (Gas)** | **0 (całkowicie darmowe)**. | **Płatne** (wymaga opłaty w Sepolia ETH za gaz). |
| **Interakcja** | Nie wymaga logowania portfelem ani podpisywania transakcji. | Wymaga podłączenia portfela i podpisania transakcji w MetaMasku. |

---

### Część 2: Co dokładnie możemy robić w obu zakładkach?

#### Zakładka „Read Contract” (Bezpieczne i darmowe odpytywanie)
Możemy badać stan kontraktu bez obaw, że cokolwiek zepsujemy lub stracimy środki:
1.  **`name` / `symbol` / `decimals` / `totalSupply`** – podstawowe metadane naszego tokenu.
2.  **`balanceOf(address)`** – studenci mogą wkleić Twój adres, swój adres lub dowolny inny i sprawdzić aktualne saldo (pokaże się wartość z 18 zerami na końcu, np. `99999999999999999975`).
3.  **`allowance(owner, spender)`** – sprawdzenie, jaki limit wydatków właściciel (`owner`) przydzielił danemu pośrednikowi (`spender`). Na początku pokaże oczywiście `0`.

#### Zakładka „Write Contract” (Interakcja i zmiana stanu)
Aby tu działać, należy najpierw kliknąć czerwony przycisk **"Connect to Web3"** tuż pod zakładkami i połączyć MetaMask. Przycisk zmieni kolor na zielony.
1.  **`transfer(to, value)`** – bezpośrednie przesłanie tokenów z połączonego portfela do odbiorcy (`to`).
2.  **`approve(spender, value)`** – autoryzowanie innego adresu (`spender`) do zarządzania naszymi tokenami.
3.  **`transferFrom(from, to, value)`** – pobranie tokenów z konta `from` i przesłanie ich do `to` przez uprawnionego wcześniej pośrednika.

---

### Część 3: Praktyczny Scenariusz Pokazu – „Gra pozorów (DeFi)”

Symulacja, w której **Konto A** daje upoważnienie **Kontu B**, a ton „pobiera” od A  za usługę. 

*Wskazówka: Zawsze pamiętajcie, aby kwoty wpisywać z 18 zerami na końcu (np. 10 tokenów to `10000000000000000000`).*

#### Krok 1: Sprawdzenie stanu początkowego (Read)
1. Wchodzicie w **Read Contract** -> funkcja **`allowance`**.
2. Wpisujesz swój adres (`owner`) oraz adres studenta (`spender`). 
3. Klikacie *Query*. Wynik: **`0`**.

#### Krok 2: Udzielenie uprawnień (Write - jako Właściciel)
1. Łączysz swoje **Konto A** z Etherscanem (*Connect to Web3*).
2. Rozwijasz funkcję **`approve`**.
3. Jako `spender` wklejasz adres studenta (**Konto B**).
4. Jako `value` wpisujesz np. `50000000000000000000` (50 tokenów).
5. Klikasz **Write**, zatwierdzasz transakcję w MetaMask i czekasz kilka sekund na potwierdzenie bloku.

#### Krok 3: Weryfikacja (Read - dowolny student)
1. Wracacie do zakładki **Read Contract** -> **`allowance`**.
2. Ponownie klikacie *Query*.
3. **Wynik:** Na ekranie pojawia się wartość `50000000000000000000`. Blockchain zapisał uprawnienie!

#### Krok 4: Pobranie środków przez Pośrednika (Write - jako Student)
Teraz student przejmuje inicjatywę. Pokazujemy, jak działa silnik np. giełdy Uniswap.
1. Na komputerze studenta (lub po przełączeniu konta w MetaMask na Twoim komputerze) student wchodzi na tę samą stronę Etherscana.
2. Klika *Connect to Web3* i łączy swoje **Konto B**.
3. Rozwija funkcję **`transferFrom`** i wpisuje:
   * `from`: Twój adres (Konto A)
   * `to`: Swój adres (Konto B) – lub jakikolwiek inny adres docelowy
   * `value`: `20000000000000000000` (pobiera 20 z 50 dozwolonych tokenów).
4. Student klika **Write** i podpisuje transakcję. **Zwróć uwagę studentów, że to student (Konto B) płaci za gaz w Sepolia ETH, mimo że tokeny pobierane są od Ciebie!**

#### Krok 5: Finał (Read)
W zakładce **Read Contract**:
1. Sprawdzacie **`balanceOf`** dla Twojego konta (ubyło 20 tokenów).
2. Sprawdzacie **`balanceOf`** dla konta studenta (przybyło 20 tokenów).
3. Sprawdzacie **`allowance`** – limit zmniejszył się automatycznie z 50 do 30 tokenów.

---

### To samo z Etherscana w Remix?

W panelu **Deployed Contracts** w Remixie przyciski mają kolory, które reprezentują dokładnie to samo rozróżnienie:

*   **Niebieskie przyciski** (np. `balanceOf`, `allowance`, `symbol`, `decimals`) = **Read Contract**.  
    Są darmowe, nie wymagają podpisywania transakcji w MetaMasku. Wynik wyświetla się natychmiast po kliknięciu tuż pod przyciskiem.
*   **Pomarańczowe przyciski** (np. `transfer`, `approve`, `transferFrom`) = **Write Contract**.  
    Zmieniają stan blockchaina, więc ich kliknięcie wywoła okienko MetaMask z prośbą o podpisanie transakcji i zapłacenie za gaz.

---

### Scenariusz w Remix (Krok po kroku na Sepolii)

Scenariusz wygląda identycznie, tylko zamiast kart Etherscana używasz panelu Remix:

1.  **Konto A (Właściciel) daje uprawnienia:**
    *   W MetaMasku masz wybrane **Konto A**.
    *   W sekcji kontraktu w Remixie znajdujesz pomarańczowy przycisk **`approve`**.
    *   Rozwijasz go, wpisujesz adres Konta B w pole `spender` oraz kwotę z 18 zerami w pole `amount`. Klikasz przycisk `transact` i podpisujesz w MetaMask.
2.  **Weryfikacja limitu (Każdy):**
    *   W Remixie klikasz niebieski przycisk **`allowance`**, wpisując adres Konta A i Konta B. Wynik pojawia się natychmiast pod przyciskiem bez udziału MetaMaska.
3.  **Konto B (Pośrednik) pobiera środki:**
    *   **Przełączasz konto w MetaMasku na Konto B**.
    *   W Remixie upewniasz się, że w polu *ACCOUNT* widnieje adres Konta B.
    *   Rozwijasz pomarańczowy przycisk **`transferFrom`**.
    *   Wpisujesz: `from` (Konto A), `to` (Konto B), `amount` (kwota).
    *   Klikasz `transact` i podpisujesz transakcję jako Konto B (płacąc jego gazem).

