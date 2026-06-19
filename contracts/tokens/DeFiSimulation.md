Świetna wiadomość! Gratulacje – pomyślna weryfikacja kodu na Etherscanie to duży kamień milowy. To, że portfel nadal nie pokazuje ikony, nie ma już znaczenia, ponieważ **masz teraz pełne, profesjonalne środowisko deweloperskie bezpośrednio w przeglądarce**. 

Dla studentów interakcja z kontraktem przez Etherscan jest niesamowicie pouczająca, ponieważ zmusza ich do myślenia o tym, co jest darmowym odczytem, a co płatnym zapisem na blockchainie.

Oto propozycja kolejnego, bardzo interaktywnego kroku warsztatów: **„Symulacja transakcji DeFi (Approve & TransferFrom) przy użyciu Etherscana”**.

---

### Część 1: Teoria – Czym różni się „Read” od „Write” na Etherscanie?

Przed przystąpieniem do klikania, warto wyjaśnić studentom fundamentalną różnicę architektoniczną w EVM:

| Cecha | Read Contract (Odczyt) | Write Contract (Zapis) |
| :--- | :--- | :--- |
| **Co robi?** | Odpytuje lokalny węzeł o aktualny stan blockchaina (funkcje `view` i `pure`). | Modyfikuje stan blockchaina (zmienia wartości w storage kontraktu). |
| **Koszt (Gas)** | **0 (całkowicie darmowe)**. | **Płatne** (wymaga opłaty w Sepolia ETH za gaz). |
| **Interakcja** | Nie wymaga logowania portfelem ani podpisywania transakcji. | Wymaga podłączenia portfela i podpisania transakcji w MetaMasku. |

---

### Część 2: Co dokładnie możemy robić w obu zakładkach?

#### Zakładka „Read Contract” (Bezpieczne i darmowe odpytywanie)
Tutaj studenci mogą badać stan kontraktu bez obaw, że cokolwiek zepsują lub stracą środki:
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

Zaproponuj studentom przeprowadzenie symulacji, w której **Konto A** (Ty) daje upoważnienie **Kontu B** (np. studentowi), a ten „pobiera” od Ciebie opłatę za usługę. 

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

### Dlaczego to jest idealny krok warsztatu?
Studenci często mają problem ze zrozumieniem, dlaczego giełdy DEX (jak Uniswap) wymagają najpierw transakcji **Approve**, a dopiero potem robią właściwy **Swap**. Dzięki temu pokazowi na żywo na Etherscanie zobaczą "bebechy" tego procesu bez pisania ani jednej linijki dodatkowego kodu front-endowego. Wszystko dzieje się na surowym protokole ERC-20.