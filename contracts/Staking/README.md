# Warsztat DeFi: Mini-Pula Stakingowa (Yield Farming)

Staking to jeden z najważniejszych filarów zdecentralizowanych finansów (DeFi). 
To ćwiczenie pozwoli zrozumieć, jak algorytmicznie naliczać odsetki na blockchainie w sposób bezpieczny i ekstremalnie tani pod kątem zużycia gazu.

---

## 1. Co to jest Staking i Yield Farming?

*   **Staking (Lokowanie):** To odpowiednik tradycyjnej lokaty bankowej. Użytkownik blokuje (deponuje) swoje tokeny (np. `MTK`) w smart kontrakcie na określony czas.
*   **Yield Farming (Uprawa plonów):** To proces, w którym za zablokowanie swoich tokenów użytkownik jest stale nagradzany nowymi tokenami (generuje odsetki, czyli tzw. "plon"). 

---

## 2. Problem matematyczny w EVM: Jak naliczać odsetki bez pętli?

W tradycyjnym programowaniu (np. w C++ czy Javie) najprostszym sposobem na naliczenie odsetek dla tysiąca użytkowników byłoby uruchomienie pętli `for`, 
która co sekundę przechodzi przez każde konto i dodaje do niego nagrodę.

**Dlaczego nie wolno robić tego w Solidity?**
Wykonanie pętli kosztuje gaz. Gdyby nasza pula miała 10 000 użytkowników, 
uruchomienie pętli `for` przekroczyłoby maksymalny limit gazu dla pojedynczego bloku (Block Gas Limit). 
Kontrakt zostałby permanentnie zablokowany, a środki użytkowników uwięzione.

### Rozwiązanie: Wzorzec "Compounding on Action" (Zliczanie przy akcji)
Nasz kontrakt rozwiązuje ten problem matematycznie, zachowując złożoność obliczeniową na poziomie **$O(1)$** (stały koszt gazu):
1. Nie naliczamy nagród wszystkim użytkownikom co sekundę.
2. Zamiast tego, dla każdego użytkownika zapisujemy zmienną `lastUpdateTime` (kiedy ostatnio wchodził w interakcję z pulą).
3. Gdy użytkownik wykonuje jakąkolwiek akcję (`stake`, `withdraw`, `claimReward`), kontrakt:
   * Oblicza, ile sekund minęło od jego ostatniej interakcji: DeltaT = block.timestamp - lastUpdateTime.
   * Nalicza nagrodę proporcjonalną do zablokowanych tokenów i czasu: Nagroda = Saldo razy DeltaT razy Stawka.
   * Dodaje tę kwotę do jego globalnego salda nagród.
   * Aktualizuje `lastUpdateTime` na obecny czas bloku.

Dzięki temu obliczenia wykonywane są **tylko dla jednego, konkretnego użytkownika** i tylko wtedy, gdy sam wywoła transakcję.

---

## 3. Parametry ekonomiczne kontraktu

*   **`rewardRate`**: Stawka nagrody. W naszym kontrakcie wynosi ona `1e13` ($10^{13}$). 
    *   Oznacza to, że za każdy zablokowany 1 pełen token `MTK` ($10^{18}$ wei) użytkownik otrzymuje **`10 000` wei nagrody na sekundę**.
    *   W warunkach prezentacji na żywo pozwala to na bardzo szybkie i efektowne zbieranie plonów (nagrody rosną "w oczach" na frontendzie).

---

## 4. Instrukcja wdrożenia na Sepolii

1.  Wdróż swój token **`MojeTokeny.sol`** (`MTK`).
2.  Wdróż kontrakt **`StakingPool.sol`**, podając w konstruktorze adres tokenu `MTK` w obu polach (nasz token będzie jednocześnie tokenem blokowanym, jak i tokenem nagrody).
3.  **Zasilenie puli nagród:** Prześlij na adres kontraktu `StakingPool` np. **500 MTK** ze swojego portfela. Kontrakt musi mieć fizyczne tokeny w swoim sejfie, aby mieć z czego wypłacać nagrody użytkownikom!

---
---

# Stakowanie natywnego **ETH** w celu „uprawiania” (farmowania) własnego tokenu **`MTK`** jako nagrody.
To w świecie DeFi bardzo częsty, wręcz klasyczny schemat. 

**Korzyści**, które uproszczą pracę z frontendem i utrwalą wiedzę:

1.  **Znakomity UX (tylko 1 transakcja):** Ponieważ stakujemy natywny Ether, **nie potrzebujemy wywołania `approve`** . 
Nie musimy pytać o zgodę na transfer. Użytkownik klika na frontendzie "Stake", wpisuje kwotę ETH, wyskakuje tylko jedno okienko MetaMask i gotowe [1.1.2]!
2.  **Powtórka z natywnego ETH:** Ponownie wykorzystujemy modyfikator `payable`, zmienną `msg.value` oraz bezpieczny przelew Etheru za pomocą `.call` [1.2.7].

## Kod kontraktu: `EthStakingPool.sol`

### Jak to przetestować przed zrobieniem frontendu?

1.  Wdróż token `MojeTokeny.sol` (`MTK`).
2.  Wdróż `EthStakingPool.sol`, podając adres swojego tokenu `MTK` w konstruktorze.
3.  **Zasil pulę nagrodami:** Przejdź do kontraktu `MojeTokeny.sol` i przelej za pomocą `transfer` np. **500 MTK** na adres kontraktu `EthStakingPool`.
4.  **Zablokuj (Stake) ETH:**
    *   W Remixie wybierz kontrakt `EthStakingPool.sol`.
    *   U góry w polu **Value** wpisz np. `5` **Ether**.
    *   Kliknij pomarańczowy przycisk **`stake`** (zauważ, że funkcja nie przyjmuje żadnych argumentów w nawiasie, pobiera ETH bezpośrednio z transakcji przez `msg.value`!) [1.2.7].
5.  Poczekaj chwilę, wywołaj funkcję `earned(Twój_Adres)` i obserwuj, jak z sekundy na sekundę kontrakt nalicza Ci darmowe tokeny `MTK` w nagrodę za to, że powierzyłeś mu swoje ETH!

---
---


# Staking tylko ETH !!!.

## Problem - Skąd biorą się odsetki?

Gdy stakujemy i zarabiamy w tokenach ERC-20, sprawa jest prosta: kontrakt może „dodrukować” dowolną liczbę tokenów za pomocą funkcji `_mint`. 

W przypadku **natywnego ETH** sprawa wygląda inaczej:
*   **ETH nie da się dodrukować wewnątrz smart kontraktu**. 
Całkowita podaż ETH jest kontrolowana przez protokół sieci (Consensus Layer).
*   Oznacza to, że aby kontrakt mógł wypłacić komuś odsetki w ETH, **ktoś musi najpierw te rezerwy odsetkowe fizycznie do kontraktu wpłacić**.
*   W pokazie to **Konto A** zasili kontrakt początkową pulą ETH na odsetki (np. wpłaci 10 ETH jako „rezerwy bankowe”). 
Będziemy stakować ETH i wyciągać odsetki właśnie z tej puli.

---

### Zaleta techniczna: Całkowity brak zewnętrznych tokenów!

Ten kontrakt jest **niezwykle czysty**. 
Nie importujemy w nim **żadnych bibliotek ERC-20**. 
Nie wdrażamy żadnego innego kontraktu. 
Cały warsztat opiera się wyłącznie na natywnych mechanizmach Solidity.

## Kod kontraktu `EthOnlyStakingPool.sol`

---

### Jak skonfigurować ten pokaz na Sepolii w 3 konta:

Zamiast skomplikowanych transferów tokenów, robimy czysty pokaz na ETH:

1.  **Wdrożenie:** (Konto A) wdraża kontrakt `EthOnlyStakingPool.sol`.
2.  **Zasilenie odsetkowe (Konto A):**
    *   **Value** np. **`0.3 ETH`**.
    *   Fnkcja **`fundRewardPool`**.
    *   *Stan:* Kontrakt ma 0.3 ETH rezerw na nagrody. `totalStaked` wynosi `0`.
3.  **Stakowanie przez (Konto B):**
    *   **Value** na **`0.1 ETH`** .
    *   funkcja **`stake`** (MetaMask pyta o jedną, prostą transakcję wysłania 0.1 ETH).
    *   *Stan:* `totalStaked` rośnie do 0.1 ETH. Całkowite saldo kontraktu to 0.4 ETH (0.3 rezerw + 0.1 depozytu).
4.  **Zarabianie:** odświeżamy funkcję `earned` i widzimy jak odsetki w ETH rosną z każdą sekundą.
5.  **Claim:** Klikamy **`claimReward`**, a kontrakt wypłaca nam odsetki bezpośrednio z rezerw, które przygotowało Konto A w Kroku 2.

---