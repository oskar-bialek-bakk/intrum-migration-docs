---
title: "Migracja ⬝ Korekta danych po walidacji"
---

# Korekta danych po walidacji

Po uruchomieniu walidacji zespół BAKK przekaże raport w formie wyniku zapytania SQL (patrz sekcja 3). Raport zawiera:
- identyfikatory rekordów z błędami
- kod i opis walidacji
- liczbę rekordów objętych błędem

Przykładowy raport z błędami blokującymi do korekty:

| Kod | Poziom | Liczba rekordów | Przykładowe ID | Opis |
|---|---|---|---|---|
| BIZ_08 | BLOCKING | 5 | 201, 202, 203, 204, 205 | Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden |
| REF_14 | BLOCKING | 2 | 310, 311 | `akcja.ak_sp_id` wskazuje na nieistniejącą sprawę |
| TECH_03 | BLOCKING | 1 | 88 | `sprawa.sp_numer_rachunku` ma wartość NULL — pole wymagane |

**Błędy blokujące** — wymagają korekty w danych źródłowych i ponownego załadowania do stagingu przed migracją.

**Ostrzeżenia** — można poprawić przed migracją lub pisemnie potwierdzić akceptację odchyleń.

**Informacje** — nie wymagają akcji.

Po każdej poprawce walidacje zostaną uruchomione ponownie aż do uzyskania braku błędów blokujących.
