---
title: "Migracja ⬝ Przegląd"
---

# Przegląd

Niniejszy dokument opisuje proces zasilania bazy stagingowej danymi oraz zasady walidacji, które zostaną uruchomione przed migracją do bazy produkcyjnej.

Dane dostarczane przez zespół Intrum muszą zostać załadowane do bazy `dm_staging` w określonej kolejności. Po załadowaniu, zespół BAKK uruchomi zestaw skryptów walidacyjnych sprawdzających jakość i spójność danych. Wyniki walidacji będą przekazane zwrotnie — błędy **blokujące** muszą zostać poprawione przed migracją.
