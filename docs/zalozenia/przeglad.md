---
title: "Migracja ⬝ Przegląd"
---

# Przegląd

Niniejsza dokumentacja opisuje proces migracji danych historycznych Intrum z bazy stagingowej `dm_staging` do produkcyjnej bazy `dm_data_web` systemu DEBT Manager. Dokument stanowi wspólny punkt odniesienia dla zespołów BAKK (dostawca systemu) i Intrum (właściciel danych) na każdym etapie procesu — od zasilenia stagingu, przez walidacje, aż po formalny odbiór.

## Zakres procesu

Migracja obejmuje trzy główne etapy:

1. **Zasilenie stagingu** — zespół Intrum ładuje dane do bazy `dm_staging` zgodnie z kolejnością opisaną w sekcji _[Przygotowanie danych](../przygotowanie-danych/index.md)_.
2. **Walidacje przed migracją** — zespół BAKK uruchamia zestaw reguł walidacyjnych na stagingu; wynik (błędy blokujące, ostrzeżenia, informacje) jest przekazywany Intrum do korekty.
3. **Migracja do produkcji** — po usunięciu błędów blokujących dane są przenoszone do `dm_data_web` i generowany jest raport pomigracyjny stanowiący podstawę formalnego odbioru.

## Podział odpowiedzialności

| Zespół | Zakres odpowiedzialności |
|---|---|
| **Intrum** | Dostarczenie kompletnych i poprawnych danych w stagingu, korekta błędów blokujących, decyzja o akceptacji ostrzeżeń, formalny odbiór po migracji |
| **BAKK** | Projekt stagingu, implementacja i utrzymanie pipeline'u migracyjnego, uruchomienie walidacji i migracji, wygenerowanie raportu pomigracyjnego |

Szczegółowy opis klasyfikacji walidacji znajduje się na stronie _[Poziomy walidacji](poziomy-walidacji.md)_.
