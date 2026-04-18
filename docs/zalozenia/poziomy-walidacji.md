---
title: "Migracja ⬝ Poziomy walidacji"
---

# Poziomy walidacji

Walidacje wykonywane na danych stagingowych mają trzy poziomy ważności. Tylko błędy **blokujące** uniemożliwiają migrację do produkcji.

| Poziom | Opis |
|---|---|
| **BLOKUJĄCE** | Dane nie mogą zostać zmigrowane — wymagana korekta przed uruchomieniem migracji |
| **OSTRZEŻENIE** | Dane zostaną zmigrowane, ale wymagają weryfikacji — mogą wskazywać na problemy jakościowe |
| **INFORMACJA** | Dane zostaną zmigrowane — komunikat wyłącznie informacyjny, brak wymaganej akcji |
