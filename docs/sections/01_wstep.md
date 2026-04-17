## 1. Wstęp

Niniejszy dokument opisuje proces zasilania bazy stagingowej danymi oraz zasady walidacji, które zostaną uruchomione przed migracją do bazy produkcyjnej.

Dane dostarczane przez zespół Intrum muszą zostać załadowane do bazy `dm_staging` w określonej kolejności. Po załadowaniu, zespół BAKK uruchomi zestaw skryptów walidacyjnych sprawdzających jakość i spójność danych. Wyniki walidacji będą przekazane zwrotnie — błędy **blokujące** muszą zostać poprawione przed migracją.

### Poziomy ważności walidacji

| Poziom | Opis |
|---|---|
| **BLOKUJĄCE** | Dane nie mogą zostać zmigrowane — wymagana korekta przed uruchomieniem migracji |
| **OSTRZEŻENIE** | Dane zostaną zmigrowane, ale wymagają weryfikacji — mogą wskazywać na problemy jakościowe |
| **INFORMACJA** | Dane zostaną zmigrowane — komunikat wyłącznie informacyjny, brak wymaganej akcji |
