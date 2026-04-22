---
title: "Migracja ⬝ Walidacje"
---

# Walidacje przed migracją

Po załadowaniu danych do stagingu, zespół BAKK uruchomi poniższe walidacje. Wyniki są zapisywane w tabeli `dm_staging.log.validation_result` i mogą być odpytywane w dowolnym momencie.

<div class="api-section" markdown>
<div class="api-section-title">Zapytanie diagnostyczne</div>

```sql
SELECT
    check_name      AS [Kod],
    severity        AS [Poziom],
    affected_count  AS [Liczba rekordów],
    sample_ids      AS [Przykładowe ID],
    detail          AS [Opis]
FROM dm_staging.log.validation_result
WHERE run_id = <run_id>
  AND affected_count > 0
ORDER BY
    CASE severity WHEN 'BLOCKING' THEN 1 WHEN 'WARNING' THEN 2 ELSE 3 END,
    check_name;
```

Wszystkie błędy **blokujące** muszą zostać poprawione przed migracją.

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Kategorie walidacji</div>

<div class="kategoria-grid">

<a class="kategoria-card kategoria-ref" href="#kat-ref">
  <div class="kategoria-header">
    <span class="kategoria-code">REF</span>
    <span class="kategoria-meta">Spójność referencyjna</span>
  </div>
  <p class="kategoria-desc">Wszystkie blokujące. Sprawdzają czy wartości w kolumnach FK wskazują na istniejące rekordy.</p>
</a>

<a class="kategoria-card kategoria-tech" href="#kat-tech">
  <div class="kategoria-header">
    <span class="kategoria-code">TECH</span>
    <span class="kategoria-meta">Walidacje techniczne</span>
  </div>
  <p class="kategoria-desc">Mieszane poziomy. Sprawdzają wymagane kolumny NOT NULL i podstawowe reguły techniczne.</p>
</a>

<a class="kategoria-card kategoria-fmt" href="#kat-fmt">
  <div class="kategoria-header">
    <span class="kategoria-code">FMT</span>
    <span class="kategoria-meta">Walidacje formatów</span>
  </div>
  <p class="kategoria-desc">Głównie ostrzeżenia. Sprawdzają zgodność zapisu z oczekiwanym formatem (PESEL, NIP, e-mail, telefon, daty).</p>
</a>

<a class="kategoria-card kategoria-biz" href="#kat-biz">
  <div class="kategoria-header">
    <span class="kategoria-code">BIZ</span>
    <span class="kategoria-meta">Reguły biznesowe</span>
  </div>
  <p class="kategoria-desc">Mieszane poziomy. Sprawdzają zgodność danych z regułami domeny (sprawy bez dłużnika, niezbilansowane księgowania, akcje bez rezultatu).</p>
</a>

</div>

</div>

---

<div class="api-section" markdown>

### REF — Spójność referencyjna (wszystkie BLOKUJĄCE) {#kat-ref}

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_01</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każdy dłużnik w <code>sprawa_rola</code> musi istnieć w <code>dluznik</code>. Tabela: <code>sprawa_rola</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_02</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każda sprawa w <code>sprawa_rola</code> musi istnieć w <code>sprawa</code>. Tabela: <code>sprawa_rola</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_03</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każdy typ roli w <code>sprawa_rola</code> musi istnieć w <code>sprawa_rola_typ</code>. Tabela: <code>sprawa_rola</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_04</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każda wierzytelność w <code>wierzytelnosc_rola</code> musi istnieć w <code>wierzytelnosc</code>. Tabela: <code>wierzytelnosc_rola</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_05</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każda sprawa w <code>wierzytelnosc_rola</code> musi istnieć w <code>sprawa</code>. Tabela: <code>wierzytelnosc_rola</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_06</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Jeśli <code>wi_uko_id</code> jest wypełnione, musi istnieć w <code>umowa_kontrahent</code>. Tabela: <code>wierzytelnosc</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_07</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każdy dokument musi być powiązany z istniejącą wierzytelnością. Tabela: <code>dokument</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_08</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ dokumentu musi istnieć w <code>dokument_typ</code>. Tabela: <code>dokument</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_09</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każdy adres musi być powiązany z istniejącym dłużnikiem. Tabela: <code>adres</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_10</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ adresu musi istnieć w <code>adres_typ</code>. Tabela: <code>adres</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_11</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każdy telefon musi być powiązany z istniejącym dłużnikiem. Tabela: <code>telefon</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_12</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ telefonu musi istnieć w <code>telefon_typ</code>. Tabela: <code>telefon</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_13</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każdy adres e-mail musi być powiązany z istniejącym dłużnikiem. Tabela: <code>mail</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_14</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każda akcja musi być powiązana z istniejącą sprawą. Tabela: <code>akcja</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_15</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ atrybutu musi istnieć w <code>atrybut_typ</code>. Tabela: <code>atrybut</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_16</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Jeśli <code>atrybut_typ.att_atd_id=1</code> (dokument), <code>at_ob_id</code> musi istnieć w <code>dokument</code>. Tabela: <code>atrybut</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_17</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Jeśli <code>atrybut_typ.att_atd_id=2</code> (wierzytelność), <code>at_ob_id</code> musi istnieć w <code>wierzytelnosc</code>. Tabela: <code>atrybut</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_18</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Jeśli <code>atrybut_typ.att_atd_id=3</code> (dłużnik), <code>at_ob_id</code> musi istnieć w <code>dluznik</code>. Tabela: <code>atrybut</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_19</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Jeśli <code>atrybut_typ.att_atd_id=4</code> (sprawa), <code>at_ob_id</code> musi istnieć w <code>sprawa</code>. Tabela: <code>atrybut</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_20</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każdy dekret musi być powiązany z istniejącym księgowaniem. Tabela: <code>ksiegowanie_dekret</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_21</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Konto księgowe musi istnieć w <code>ksiegowanie_konto</code>. Tabela: <code>ksiegowanie_dekret</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_22</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Jeśli <code>ksd_do_id</code> jest wypełnione, musi istnieć w <code>dokument</code>. Tabela: <code>ksiegowanie_dekret</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_23</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Jeśli <code>oper_do_id</code> jest wypełnione, musi istnieć w <code>dokument</code>. Tabela: <code>operacja</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_24</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ sprawy musi istnieć w <code>sprawa_typ</code>. Tabela: <code>sprawa</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_25</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ sprawy w <code>sprawa_etap</code> musi istnieć w <code>sprawa_typ</code>. Tabela: <code>sprawa_etap</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_26</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ dłużnika musi istnieć w <code>dluznik_typ</code>. Tabela: <code>dluznik</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_27</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Jeśli <code>oper_waluta</code> jest wypełnione, musi odpowiadać kodowi waluty w <code>waluta</code>. Tabela: <code>operacja</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_28</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Dziedzina atrybutu musi istnieć w <code>atrybut_dziedzina</code>. Tabela: <code>atrybut</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_29</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ księgowania musi istnieć w <code>ksiegowanie_typ</code>. Tabela: <code>ksiegowanie</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_30</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Wartość <code>dl_plec</code> musi odpowiadać kodowi w tabeli mapowania płci. Tabela: <code>dluznik</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_31</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Etap sprawy musi istnieć w <code>sprawa_etap</code>. Tabela: <code>sprawa</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_32</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ akcji musi istnieć w <code>akcja_typ</code>. Tabela: <code>akcja</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_33</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każdy rezultat musi być powiązany z istniejącą akcją (<code>re_ak_id → akcja</code>). Tabela: <code>rezultat</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_34</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Typ rezultatu musi istnieć w <code>rezultat_typ</code> (<code>re_ret_id → rezultat_typ</code>). Tabela: <code>rezultat</code></p>
</div>

<div class="walidacja-card walidacja-ref">
<div class="walidacja-header">
  <span class="walidacja-code">REF_35</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Subkonto konta księgowego musi istnieć w <code>ksiegowanie_konto_subkonto</code> (<code>ksd_ksksub_id → ksiegowanie_konto_subkonto</code>). Tabela: <code>ksiegowanie_dekret</code></p>
</div>

</div>

---

<div class="api-section" markdown>

### TECH — Walidacje techniczne {#kat-tech}

<div class="walidacja-card walidacja-tech">
<div class="walidacja-header">
  <span class="walidacja-code">TECH_01</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Dłużnik ma pustą kolumnę <code>dl_plec</code> — płeć nie zostanie przeniesiona do bazy produkcyjnej (pole opcjonalne).</p>
</div>

<div class="walidacja-card walidacja-tech">
<div class="walidacja-header">
  <span class="walidacja-code">TECH_03</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Sprawa ma pustą kolumnę <code>sp_numer_rachunku</code> — numer rachunku jest wymagany, rekord nie może zostać zmigrowany.</p>
</div>

<div class="walidacja-card walidacja-tech">
<div class="walidacja-header">
  <span class="walidacja-code">TECH_04</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Wierzytelność ma pustą kolumnę <code>wi_uko_id</code> — powiązanie z umową kontrahenta jest wymagane.</p>
</div>

<div class="walidacja-card walidacja-tech">
<div class="walidacja-header">
  <span class="walidacja-code">TECH_05</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Dokument ma pustą kolumnę <code>do_wi_id</code> — powiązanie z wierzytelnością jest wymagane.</p>
</div>

<div class="walidacja-card walidacja-tech">
<div class="walidacja-header">
  <span class="walidacja-code">TECH_06</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Akcja ma pustą kolumnę <code>ak_sp_id</code> — powiązanie ze sprawą jest wymagane.</p>
</div>

<div class="walidacja-card walidacja-tech">
<div class="walidacja-header">
  <span class="walidacja-code">TECH_07</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Atrybut ma pustą kolumnę <code>at_ob_id</code> — brak wskazania encji docelowej, rekord nie może zostać zmigrowany.</p>
</div>

<div class="walidacja-card walidacja-tech">
<div class="walidacja-header">
  <span class="walidacja-code">TECH_08</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Atrybut ma pustą wartość (<code>at_wartosc = ''</code>) — wartość może być pusta w bazie produkcyjnej, wymaga weryfikacji.</p>
</div>

<div class="walidacja-card walidacja-tech">
<div class="walidacja-header">
  <span class="walidacja-code">TECH_09</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Dekret księgowania ma pustą kolumnę <code>ksd_ks_id</code> — powiązanie z nagłówkiem księgowania jest wymagane.</p>
</div>

<div class="walidacja-card walidacja-tech">
<div class="walidacja-header">
  <span class="walidacja-code">TECH_10</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Operacja finansowa ma kwotę większą od zera, ale pustą walutę (<code>oper_waluta</code>) — waluta zostanie ustawiona jako NULL na produkcji.</p>
</div>

</div>

---

<div class="api-section" markdown>

### FMT — Walidacje formatów {#kat-fmt}

Zakres i progi poszczególnych sprawdzeń mogą zostać dostosowane do specyficznych wymagań Intrum podczas warsztatów analitycznych.

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_01</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">PESEL musi składać się z dokładnie 11 cyfr. Tabela: <code>dluznik</code></p>
</div>

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_02</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">NIP musi składać się z 10 cyfr (myślniki są ignorowane). Tabela: <code>dluznik</code></p>
</div>

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_03</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">REGON musi składać się z 9 lub 14 cyfr. Tabela: <code>dluznik</code></p>
</div>

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_04</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Kod pocztowy musi być w formacie XX-XXX. Tabela: <code>adres</code></p>
</div>

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_05</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Adres e-mail musi zawierać znak <code>@</code> i domenę. Tabela: <code>mail</code></p>
</div>

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_06</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Numer telefonu musi zawierać co najmniej 9 cyfr (po usunięciu spacji, myślników i znaku +). Tabela: <code>telefon</code></p>
</div>

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_07</span>
  <span class="walidacja-sev sev-info">Informacja</span>
</div>
<p class="walidacja-desc">Numer telefonu nie zaczyna się od <code>+</code> — brak kodu kraju. Tabela: <code>telefon</code></p>
</div>

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_08</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Data wymagalności dokumentu (<code>do_data_wymagalnosci</code>) nie może być wcześniejsza niż data wystawienia (<code>do_data_wystawienia</code>). Tabela: <code>dokument</code></p>
</div>

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_11</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Data zakończenia akcji (<code>ak_data_zakonczenia</code>) nie może być w przyszłości. Tabela: <code>akcja</code></p>
</div>

<div class="walidacja-card walidacja-fmt">
<div class="walidacja-header">
  <span class="walidacja-code">FMT_12</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Data umowy wierzytelności (<code>wi_data_umowy</code>) nie może być w przyszłości. Tabela: <code>wierzytelnosc</code></p>
</div>

</div>

---

<div class="api-section" markdown>

### BIZ — Reguły biznesowe {#kat-biz}

<div class="walidacja-card walidacja-biz" id="biz_01">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_01</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Każda sprawa musi mieć co najmniej jeden rekord w <code>sprawa_rola</code> — sprawa bez przypisanego dłużnika jest nieprawidłowa.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_02a">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_02a</span>
  <span class="walidacja-sev sev-info">Informacja</span>
</div>
<p class="walidacja-desc">Sprawa bez powiązanej wierzytelności — dozwolone, ale taka sprawa nie może mieć powiązanych dokumentów ani księgowań.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_02b">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_02b</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Sprawa bez wierzytelności ma powiązane dokumenty lub dekrety księgowania — niedozwolone, dane muszą zostać poprawione.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_03">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_03</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Dłużnik nie jest powiązany z żadną sprawą — możliwy błąd zasilania danych.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_04">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_04</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Wierzytelność nie ma żadnego powiązanego dokumentu — sytuacja podejrzana, wymaga weryfikacji.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_05">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_05</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Księgowanie nie ma żadnego dekretu — zapis księgowy bez linii szczegółowych jest nieprawidłowy.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_06">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_06</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Suma kwot dekretów na jednym księgowaniu nie wynosi zero — naruszenie zasady podwójnego zapisu.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_07">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_07</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Sprawa nie ma żadnej akcji — przypadek bez historii działań jest nietypowy.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_08">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_08</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Akcja nie ma żadnego rezultatu — każda akcja musi mieć co najmniej jeden rezultat.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_09">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_09</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Dłużnik ma nadmierną liczbę numerów telefonu — próg konfigurowalny w <code>dm_staging.configuration.threshold_config</code> (klucz: <code>max_phones_per_dluznik</code>).</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_10">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_10</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Dłużnik ma nadmierną liczbę adresów — próg konfigurowalny w <code>dm_staging.configuration.threshold_config</code> (klucz: <code>max_adresy_per_dluznik</code>).</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_11">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_11</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Sprawa ma nadmierną liczbę akcji — próg konfigurowalny w <code>dm_staging.configuration.threshold_config</code> (klucz: <code>max_akcje_per_sprawa</code>).</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_12">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_12</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Wierzytelność ma nadmierną liczbę dokumentów — próg konfigurowalny w <code>dm_staging.configuration.threshold_config</code> (klucz: <code>max_dokumenty_per_wierzytelnosc</code>).</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_13">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_13</span>
  <span class="walidacja-sev sev-info">Informacja</span>
</div>
<p class="walidacja-desc">Dłużnik nie ma żadnego identyfikatora (brak PESEL, NIP, numeru dowodu i paszportu) — rekord zostanie zmigrowany, ale niska jakość danych.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_14">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_14</span>
  <span class="walidacja-sev sev-info">Informacja</span>
</div>
<p class="walidacja-desc">Wierzytelność nie ma żadnych powiązanych księgowań — wierzytelność nigdy nie trafiła do księgowości.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_15">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_15</span>
  <span class="walidacja-sev sev-warn">Ostrzeżenie</span>
</div>
<p class="walidacja-desc">Harmonogram spłat powiązany z nieistniejącą wierzytelnością — rekord osierocony.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_16">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_16</span>
  <span class="walidacja-sev sev-block">Blokujące</span>
</div>
<p class="walidacja-desc">Dokument nie ma daty wymagalności na podstawowym dekrecie księgowania — każdy dokument musi mieć datę wymagalności.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_17">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_17</span>
  <span class="walidacja-sev sev-info">Informacja</span>
</div>
<p class="walidacja-desc">Księgowanie ma datę księgowania z przyszłości — data księgowania nie może być przyszła.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_18">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_18</span>
  <span class="walidacja-sev sev-info">Informacja</span>
</div>
<p class="walidacja-desc">Księgowanie ma datę operacji z przyszłości — data operacji nie może być przyszła.</p>
</div>

<div class="walidacja-card walidacja-biz" id="biz_19">
<div class="walidacja-header">
  <span class="walidacja-code">BIZ_19</span>
  <span class="walidacja-sev sev-info">Informacja</span>
</div>
<p class="walidacja-desc">Wierzytelność ma datę umowy z przyszłości — data zawarcia umowy nie może być przyszła.</p>
</div>

</div>
