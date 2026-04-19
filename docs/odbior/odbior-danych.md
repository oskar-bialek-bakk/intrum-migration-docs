---
title: "Migracja ⬝ Odbiór danych"
parent: "Migracja danych stagingowych DEBT Manager"
---

# Odbiór procesu migracji

Na podstawie raportu pomigracyjnego oraz podsumowania liczby zmigrowanych rekordów zespół Intrum dokonuje **formalnego odbioru** procesu migracji. Odbiór potwierdza, że dane zostały przeniesione poprawnie i kompletnie, a odchylenia zidentyfikowane w raporcie zostały uznane za akceptowalne.

## Kryteria odbioru

Odbiór jest możliwy, gdy wszystkie wskaźniki COUNT oraz SUM w raporcie pomigracyjnym mają status **PASS**, a wskazane odchylenia ANOMALY zostały wyjaśnione i zaakceptowane przez zespół Intrum. Rozbieżności, które nie mogą zostać zaakceptowane, wymagają decyzji o wycofaniu migracji.

## Rollback

W przypadku stwierdzenia istotnych rozbieżności lub błędów uniemożliwiających prawidłowe funkcjonowanie systemu, Intrum może podjąć decyzję o **wycofaniu zmian** (rollback) z bazy produkcyjnej. Decyzja musi zostać przekazana zespołowi BAKK niezwłocznie po zakończeniu analizy raportu pomigracyjnego — przed rozpoczęciem operacyjnego użytkowania systemu.

!!! info "Uszczegółowienie"
    Pełne kryteria odbioru oraz formalna procedura rollbacku zostaną uzgodnione w trakcie warsztatów odbiorczych i uzupełnione w kolejnych wersjach dokumentacji.
