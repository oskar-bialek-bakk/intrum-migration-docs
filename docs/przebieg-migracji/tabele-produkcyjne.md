---
title: "Migracja ⬝ Tabele produkcyjne zasilane migracją"
---

# Tabele produkcyjne zasilane migracją

Zestawienie wszystkich tabel na bazie produkcyjnej (schemat `dm_data_web`), do których migracja wprowadza dane. Każdą tabelę można prześledzić wstecz do iteracji (fali ładowania), która ją zasila — link w drugiej kolumnie prowadzi do opisu tabeli na stronie odpowiedniej iteracji. Tabele słownikowe i referencyjne zebrano w [osobnym zestawieniu na dole strony](#tabele-slownikowe). Kolejność ładowania i zależności między falami opisuje [Kolejność zasilania tabel](../przygotowanie-danych/kolejnosc-zasilania-tabel.md).

## Lista tabel

<table class="report-table">
  <thead>
    <tr>
      <th>Tabela produkcyjna</th>
      <th>Zasilana w iteracji</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>dm_data_web.adres</code></td>
      <td><a href="../../struktura-stagingu/kontakty/#dboadres">Iteracja 3 — Kontakty</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.akcja</code></td>
      <td><a href="../../struktura-stagingu/akcje/#dboakcja">Iteracja 5 — Akcje</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.atrybut_dluznik</code></td>
      <td><a href="../../struktura-stagingu/dluznicy/">Iteracja 2 — Dłużnicy</a> <span class="prod-note">(struktura: <a href="../../struktura-stagingu/tabele-generyczne/#dboatrybut">tabele generyczne</a>)</span></td>
    </tr>
    <tr>
      <td><code>dm_data_web.atrybut_dokument</code></td>
      <td><a href="../../struktura-stagingu/role-wierzytelnosci-i-dokumenty/">Iteracja 7 — Dokumenty</a> <span class="prod-note">(struktura: <a href="../../struktura-stagingu/tabele-generyczne/#dboatrybut">tabele generyczne</a>)</span></td>
    </tr>
    <tr>
      <td><code>dm_data_web.atrybut_sprawa</code></td>
      <td><a href="../../struktura-stagingu/sprawy/">Iteracja 4 — Sprawy</a> <span class="prod-note">(struktura: <a href="../../struktura-stagingu/tabele-generyczne/#dboatrybut">tabele generyczne</a>)</span></td>
    </tr>
    <tr>
      <td><code>dm_data_web.atrybut_wartosc</code></td>
      <td><a href="../../struktura-stagingu/tabele-generyczne/#dboatrybut">Iteracje 2, 4, 6, 7 — tabele generyczne</a> <span class="prod-note">(wartości atrybutów wszystkich dziedzin)</span></td>
    </tr>
    <tr>
      <td><code>dm_data_web.atrybut_wierzytelnosc</code></td>
      <td><a href="../../struktura-stagingu/wierzytelnosci/">Iteracja 6 — Wierzytelności</a> <span class="prod-note">(struktura: <a href="../../struktura-stagingu/tabele-generyczne/#dboatrybut">tabele generyczne</a>)</span></td>
    </tr>
    <tr>
      <td><code>dm_data_web.dluznik</code></td>
      <td><a href="../../struktura-stagingu/dluznicy/#dbodluznik">Iteracja 2 — Dłużnicy</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.dokument</code></td>
      <td><a href="../../struktura-stagingu/role-wierzytelnosci-i-dokumenty/#dbodokument">Iteracja 7 — Dokumenty</a><br><a href="../../struktura-stagingu/harmonogram/">Iteracja 9 — Harmonogram</a> <span class="prod-note">(harmonogramy spłat zapisywane jako dokumenty)</span></td>
    </tr>
    <tr>
      <td><code>dm_data_web.ksiegowanie</code></td>
      <td><a href="../../struktura-stagingu/finanse/#dboksiegowanie">Iteracja 8 — Finanse</a><br><a href="../../struktura-stagingu/harmonogram/">Iteracja 9 — Harmonogram</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.ksiegowanie_dekret</code></td>
      <td><a href="../../struktura-stagingu/finanse/#dboksiegowanie_dekret">Iteracja 8 — Finanse</a><br><a href="../../struktura-stagingu/harmonogram/">Iteracja 9 — Harmonogram</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.mail</code></td>
      <td><a href="../../struktura-stagingu/kontakty/#dbomail">Iteracja 3 — Kontakty</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.operator</code></td>
      <td><a href="../../struktura-stagingu/sprawy/">Iteracja 4 — Sprawy</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.rachunek_bankowy</code></td>
      <td><a href="../../struktura-stagingu/sprawy/">Iteracja 4 — Sprawy</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.rezultat</code></td>
      <td><a href="../../struktura-stagingu/akcje/#dborezultat">Iteracja 5 — Akcje</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.sprawa</code></td>
      <td><a href="../../struktura-stagingu/sprawy/#dbosprawa">Iteracja 4 — Sprawy</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.sprawa_rola</code></td>
      <td><a href="../../struktura-stagingu/sprawy/#dbosprawa_rola">Iteracja 4 — Sprawy</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.telefon</code></td>
      <td><a href="../../struktura-stagingu/kontakty/#dbotelefon">Iteracja 3 — Kontakty</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.wierzytelnosc</code></td>
      <td><a href="../../struktura-stagingu/wierzytelnosci/#dbowierzytelnosc">Iteracja 6 — Wierzytelności</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.wierzytelnosc_rola</code></td>
      <td><a href="../../struktura-stagingu/wierzytelnosci/#dbowierzytelnosc_rola">Iteracja 6 — Wierzytelności</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.wlasciwosc</code></td>
      <td><a href="../../struktura-stagingu/tabele-generyczne/#dbowlasciwosc">Iteracje 2, 3 — tabele generyczne</a> <span class="prod-note">(właściwości dłużnika i kanałów kontaktowych)</span></td>
    </tr>
  </tbody>
</table>

## Tabele słownikowe {#tabele-slownikowe}

Tabele słownikowe i referencyjne — typy, dziedziny, kursy, kontrahenci. W większości kopiowane 1:1 z istniejącej produkcji i ładowane w [Iteracji 1 — Słowniki](../struktura-stagingu/slowniki.md) przed jakimikolwiek danymi transakcyjnymi.

<table class="report-table">
  <thead>
    <tr>
      <th>Tabela produkcyjna</th>
      <th>Zasilana w iteracji</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>dm_data_web.adres_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dboadres_typ">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.akcja_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dboakcja_typ">Iteracja 1 — Słowniki</a><br><a href="../../struktura-stagingu/akcje/">Iteracja 5 — Akcje</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.akcja_typ_rezultat_typ</code></td>
      <td><a href="../../struktura-stagingu/akcje/">Iteracja 5 — Akcje</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.atrybut_dziedzina</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dboatrybut_dziedzina">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.atrybut_rodzaj</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dboatrybut_rodzaj">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.atrybut_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dboatrybut_typ">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.dluznik_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbodluznik_typ">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.dokument_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbodokument_typ">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.kontrahent</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbokontrahent">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.kraj</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbokraj">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.ksiegowanie_konto</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dboksiegowanie_konto">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.ksiegowanie_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dboksiegowanie_typ">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.kurs_walut</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbokurs_walut">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.rezultat_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dborezultat_typ">Iteracja 1 — Słowniki</a><br><a href="../../struktura-stagingu/akcje/">Iteracja 5 — Akcje</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.sprawa_etap_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbosprawa_etap">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.sprawa_rola_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbosprawa_rola_typ">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.sprawa_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbosprawa_typ">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.telefon_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbotelefon_typ">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.umowa_kontrahent</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dboumowa_kontrahent">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.waluta</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbowaluta">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.wlasciwosc_dziedzina</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbowlasciwosc_dziedzina">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.wlasciwosc_podtyp</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbowlasciwosc_podtyp">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.wlasciwosc_typ</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbowlasciwosc_typ">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.wlasciwosc_typ_podtyp_dziedzina</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbowlasciwosc_typ_podtyp_dziedzina">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.wlasciwosc_typ_walidacji</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbowlasciwosc_typ_walidacji">Iteracja 1 — Słowniki</a></td>
    </tr>
    <tr>
      <td><code>dm_data_web.zrodlo_pochodzenia_informacji</code></td>
      <td><a href="../../struktura-stagingu/slowniki/#dbozrodlo_pochodzenia_informacji">Iteracja 1 — Słowniki</a></td>
    </tr>
  </tbody>
</table>
