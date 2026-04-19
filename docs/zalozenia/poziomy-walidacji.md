---
title: "Migracja ⬝ Poziomy walidacji"
---

# Poziomy walidacji

Walidacje wykonywane na danych stagingowych są klasyfikowane według trzech poziomów ważności. Poziom określa wpływ wykrytego odchylenia na proces migracji oraz zakres wymaganej reakcji zespołu Intrum przed uruchomieniem przeniesienia danych do produkcji.

!!! danger "Błędy BLOKUJĄCE"
    Dane z naruszeniem reguły blokującej **nie mogą zostać zmigrowane**. Migracja zostaje wstrzymana, a wskazane rekordy wymagają korekty w źródle i ponownego załadowania do stagingu. Typowe przypadki: brak wymaganego pola (`sprawa.sp_numer_rachunku`), nieistniejące FK (`sprawa_rola → dluznik`), naruszenie zasady podwójnego zapisu w dekretach księgowania.

!!! warning "Ostrzeżenia"
    Dane zostaną zmigrowane, ale **wymagają weryfikacji** przed formalnym odbiorem. Zespół Intrum może zdecydować o poprawie danych w stagingu lub pisemnej akceptacji odchylenia. Typowe przypadki: nieprawidłowy format PESEL / NIP, podejrzanie duża liczba adresów na dłużniku, brak powiązanych dokumentów dla wierzytelności.

!!! info "Informacje"
    Komunikaty czysto informacyjne — **nie wymagają żadnej akcji**. Służą zwiększeniu świadomości zespołu Intrum o stanie danych przed migracją. Typowe przypadki: numer telefonu bez kodu kraju, dłużnik bez żadnego identyfikatora.

Pełna lista reguł walidacyjnych wraz z poziomami wagi opisana jest na stronie _[Walidacje przed migracją](../przygotowanie-danych/walidacje.md)_.
