---
title: "Migracja ⬝ Kolejność zasilania tabel"
---

# Kolejność zasilania tabel stagingowych

Staging jest ładowany falami — dziewięcioma iteracjami. W obrębie jednej iteracji tabele nie mają zależności między sobą i mogą być ładowane równolegle. Iteracje ładuje się po kolei: każda kolejna fala zakłada, że poprzednia jest już kompletna. Wartości FK zawsze wskazują na identyfikatory stagingowe (`dm_staging`), nie produkcyjne. Szczegółowy opis tabel i kolumn — w tym wymagane wartości i ograniczenia — opisują strony poszczególnych iteracji poniżej.

<div class="api-section" markdown>
<div class="api-section-title">Zasady ogólne</div>

<ol class="assumption-list">
  <li><strong>Wartości FK</strong> muszą odnosić się do identyfikatorów ze stagingu, nie z bazy produkcyjnej.</li>
  <li>Tabele w obrębie tej samej iteracji <strong>nie mają zależności między sobą</strong> i mogą być ładowane równolegle.</li>
  <li>Iteracje muszą być ładowane <strong>sekwencyjnie</strong> — każda kolejna fala zakłada kompletność poprzedniej.</li>
</ol>

</div>

---

<div class="api-section" markdown>

### Iteracja 1 — Tabele słownikowe i referencyjne

Iteracja 1 składa się z dwóch kroków:

<div class="role-card">
  <div class="role-header">
    <span class="role-owner role-it">BAKK</span>
    <span class="role-name">Krok 1A — jednorazowo, przed przekazaniem stagingu</span>
  </div>
  <p class="role-desc">Skopiowanie istniejących danych produkcyjnych do tabel słownikowych w stagingu.</p>
</div>

<div class="role-card">
  <div class="role-header">
    <span class="role-owner role-kontrahent">Intrum</span>
    <span class="role-name">Krok 1B — zasilenie słowników</span>
  </div>
  <p class="role-desc">Dodanie nowych wartości wymaganych przez dane źródłowe, używanie identyfikatorów ze stagingu w kolumnach FK kolejnych iteracji. Podczas migracji skrypty BAKK automatycznie uzupełnią bazę produkcyjną o nowe wartości.</p>
</div>

!!! note "Zasilanie per iteracja"
    Nie wszystkie słowniki muszą być zasilone przed pierwszą iteracją encji. Wystarczy zasilić tylko te słowniki, które są faktycznie wymagane przez tabele encji w danej iteracji. Przykład: przed Iteracją 2 (dłużnicy) konieczne jest zasilenie `dluznik_typ` oraz słowników atrybutów (`atrybut_dziedzina`, `atrybut_rodzaj`, `atrybut_typ`). Szczegółowe zależności per tabela opisuje sekcja Powiązania na stronie każdej iteracji.

</div>

---

## Fale dostawy danych

<div class="feature-grid">

<a class="feature-card" href="../struktura-stagingu/slowniki/">
  <span class="card-icon">❋</span>
  <span class="card-title">Iteracja 1 — Słowniki</span>
  <p class="card-desc">Tabele słownikowe i referencyjne — waluty, kursy, typy, dziedziny. Pierwsza fala, musi być załadowana przed wszystkim innym.</p>
</a>

<a class="feature-card" href="../struktura-stagingu/dluznicy/">
  <span class="card-icon">▦</span>
  <span class="card-title">Iteracja 2 — Dłużnicy</span>
  <p class="card-desc">Główni dłużnicy wraz z atrybutami identyfikującymi. Po słownikach.</p>
</a>

<a class="feature-card" href="../struktura-stagingu/kontakty/">
  <span class="card-icon">✉</span>
  <span class="card-title">Iteracja 3 — Kontakty</span>
  <p class="card-desc">Adresy, numery telefonu, adresy e-mail dłużników. Po dłużnikach.</p>
</a>

<a class="feature-card" href="../struktura-stagingu/sprawy/">
  <span class="card-icon">⎆</span>
  <span class="card-title">Iteracja 4 — Sprawy</span>
  <p class="card-desc">Sprawy i role w sprawach. Po dłużnikach.</p>
</a>

<a class="feature-card" href="../struktura-stagingu/akcje/">
  <span class="card-icon">▶</span>
  <span class="card-title">Iteracja 5 — Akcje</span>
  <p class="card-desc">Akcje prowadzone w sprawach i ich rezultaty. Po sprawach.</p>
</a>

<a class="feature-card" href="../struktura-stagingu/wierzytelnosci/">
  <span class="card-icon">€</span>
  <span class="card-title">Iteracja 6 — Wierzytelności</span>
  <p class="card-desc">Wierzytelności i ich atrybuty. Po sprawach.</p>
</a>

<a class="feature-card" href="../struktura-stagingu/role-wierzytelnosci-i-dokumenty/">
  <span class="card-icon">§</span>
  <span class="card-title">Iteracja 7 — Role wierzytelności i dokumenty</span>
  <p class="card-desc">Role wierzytelności oraz dokumenty finansowe. Po wierzytelnościach.</p>
</a>

<a class="feature-card" href="../struktura-stagingu/finanse/">
  <span class="card-icon">∑</span>
  <span class="card-title">Iteracja 8 — Finanse</span>
  <p class="card-desc">Księgowania, operacje i dekrety finansowe. Po dokumentach.</p>
</a>

<a class="feature-card" href="../struktura-stagingu/harmonogram/">
  <span class="card-icon">◷</span>
  <span class="card-title">Iteracja 9 — Harmonogram</span>
  <p class="card-desc">Harmonogramy spłat i zabezpieczenia wierzytelności. Po wierzytelnościach.</p>
</a>

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Podsumowanie kolejności</div>

```
Iteracja 1  → waluta, kurs_walut, kontrahent, umowa_kontrahent,
               adres_typ, dluznik_typ, dokument_typ, ksiegowanie_konto,
               ksiegowanie_typ, sprawa_rola_typ, sprawa_typ, telefon_typ,
               atrybut_dziedzina, atrybut_rodzaj, akcja_typ, rezultat_typ,
               atrybut_typ*, sprawa_etap*, zrodlo_pochodzenia_informacji,
               wlasciwosc_typ_walidacji, wlasciwosc_dziedzina, wlasciwosc_podtyp,
               wlasciwosc_typ*, wlasciwosc_typ_podtyp_dziedzina*          (* po spełnieniu zależności)
Iteracja 2  → dluznik, atrybut (att_atd_id=3), wlasciwosc (dziedzina=4), wlasciwosc_dluznik
Iteracja 3  → adres, mail, telefon, wlasciwosc (dziedzina=1,2,3), wlasciwosc_adres, wlasciwosc_email, wlasciwosc_telefon
Iteracja 4  → sprawa, sprawa_rola, atrybut (att_atd_id=4)
Iteracja 5  → akcja, rezultat
Iteracja 6  → wierzytelnosc, atrybut (att_atd_id=2)
Iteracja 7  → wierzytelnosc_rola, dokument, atrybut (att_atd_id=1)
Iteracja 8  → ksiegowanie, operacja, ksiegowanie_dekret       (dane finansowe)
Iteracja 9  → harmonogram                                     (ostatnia)
```

</div>
