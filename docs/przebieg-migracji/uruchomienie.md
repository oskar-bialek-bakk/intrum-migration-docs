---
title: "Migracja ⬝ Uruchomienie"
---

# Uruchomienie migracji

Po uzyskaniu raportu walidacji bez błędów blokujących zespół BAKK przystępuje do migracji danych ze stagingu do bazy produkcyjnej `dm_data_web`. Migracja wykonywana jest w ustalonym oknie czasowym i obejmuje wszystkie zasilone tabele stagingowe w kolejności wynikającej z zależności FK.

## Przebieg

1. **Snapshot przed migracją** — utworzenie kopii stanu tabel produkcyjnych (liczba rekordów, sumy kluczowych kolumn finansowych) jako referencji dla raportu pomigracyjnego.
2. **Wyłączenie indeksów niezgrupowanych** — NCI na kluczowych tabelach produkcyjnych są wyłączane przed masowymi INSERT-ami i odbudowywane globalnie po zakończeniu migracji.
3. **Migracja iteracyjna** — tabele ładowane są w dziewięciu iteracjach: od słowników (iteracja 1), przez dłużników i kontakty (iteracja 2–3), sprawy i akcje (iteracja 4–5), po wierzytelności, dokumenty, finanse i harmonogram (iteracja 6–9).
4. **Rebuild indeksów** — odbudowa NCI oraz aktualizacja statystyk na tabelach zmienionych w trakcie migracji.
5. **Raport pomigracyjny** — uruchomienie skryptu `99_post_report.sql` (szczegóły — _[Raport pomigracyjny](raport-pomigracyjny.md)_).

Po zakończeniu pipeline zespół BAKK przekazuje raport pomigracyjny oraz podsumowanie liczby zmigrowanych rekordów per tabela jako podstawę do formalnego odbioru przez Intrum.
