---
title: "Migracja ⬝ Korekta danych po walidacji"
---

# Korekta danych po walidacji

Po uruchomieniu walidacji zespół BAKK przekazuje raport w formie wyniku zapytania SQL (szczegóły zapytania — _[Walidacje przed migracją](walidacje.md)_). Raport zawiera dla każdego wykrytego naruszenia: kod reguły, poziom wagi, przykładowe identyfikatory rekordów oraz opis odchylenia.

<div class="api-section" markdown>
<div class="api-section-title">Przykładowy raport błędów blokujących</div>

Każdy rekord raportu to jeden naruszający identyfikator — kody reguł powtarzają się tyle razy, ile rekordów narusza daną regułę.

| Kod | Poziom | ID rekordu | Opis |
|---|---|---|---|
| BIZ_08 | BLOCKING | 201 | Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden |
| BIZ_08 | BLOCKING | 202 | Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden |
| BIZ_08 | BLOCKING | 203 | Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden |
| BIZ_08 | BLOCKING | 204 | Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden |
| BIZ_08 | BLOCKING | 205 | Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden |
| REF_14 | BLOCKING | 310 | `akcja.ak_sp_id` wskazuje na nieistniejącą sprawę |
| REF_14 | BLOCKING | 311 | `akcja.ak_sp_id` wskazuje na nieistniejącą sprawę |
| TECH_03 | BLOCKING | 88 | `sprawa.sp_numer_rachunku` ma wartość NULL — pole wymagane |

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Procedura korekty</div>

!!! danger "Błędy blokujące"
    Wymagają korekty w danych źródłowych i ponownego załadowania do stagingu. **Migracja nie może się rozpocząć, dopóki w raporcie pozostaje choć jeden błąd blokujący.**

!!! warning "Ostrzeżenia"
    Można zdecydować o korekcie w stagingu lub pisemnej akceptacji odchylenia przed migracją. Decyzja należy do zespołu Intrum.

!!! info "Informacje"
    Nie wymagają żadnej akcji — służą wyłącznie zwiększeniu świadomości o stanie danych.

Po każdej rundzie korekt walidacje uruchamiane są ponownie. Cykl powtarzany jest aż do uzyskania raportu bez błędów blokujących — dopiero wtedy możliwe jest przejście do etapu _[Uruchomienie migracji](../przebieg-migracji/uruchomienie.md)_.

</div>
