---
title: "Migracja ⬝ Korekta danych po walidacji"
---

# Korekta danych po walidacji

Po uruchomieniu walidacji zespół BAKK przekazuje raport w formie wyniku zapytania SQL (szczegóły zapytania — _[Walidacje przed migracją](walidacje.md)_). Raport zawiera dla każdego wykrytego naruszenia: kod reguły, poziom wagi, liczbę objętych rekordów, przykładowe identyfikatory oraz opis odchylenia.

Przykładowy fragment raportu z błędami blokującymi:

| Kod | Poziom | Liczba rekordów | Przykładowe ID | Opis |
|---|---|---|---|---|
| BIZ_08 | BLOCKING | 5 | 201, 202, 203, 204, 205 | Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden |
| REF_14 | BLOCKING | 2 | 310, 311 | `akcja.ak_sp_id` wskazuje na nieistniejącą sprawę |
| TECH_03 | BLOCKING | 1 | 88 | `sprawa.sp_numer_rachunku` ma wartość NULL — pole wymagane |

## Procedura korekty

!!! danger "Błędy blokujące"
    Wymagają korekty w danych źródłowych i ponownego załadowania do stagingu. **Migracja nie może się rozpocząć, dopóki w raporcie pozostaje choć jeden błąd blokujący.**

!!! warning "Ostrzeżenia"
    Można zdecydować o korekcie w stagingu lub pisemnej akceptacji odchylenia przed migracją. Decyzja należy do zespołu Intrum.

!!! info "Informacje"
    Nie wymagają żadnej akcji — służą wyłącznie zwiększeniu świadomości o stanie danych.

Po każdej rundzie korekt walidacje uruchamiane są ponownie. Cykl powtarzany jest aż do uzyskania raportu bez błędów blokujących — dopiero wtedy możliwe jest przejście do etapu _[Uruchomienie migracji](../przebieg-migracji/uruchomienie.md)_.
