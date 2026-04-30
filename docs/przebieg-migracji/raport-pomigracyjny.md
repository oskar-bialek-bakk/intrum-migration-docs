---
title: "Migracja ⬝ Raport pomigracyjny"
---

# Raport pomigracyjny

Po zakończeniu migracji zespół BAKK uruchamia skrypt `99_post_report.sql`, który przeprowadza automatyczną weryfikację jakości danych bezpośrednio na bazie produkcyjnej `dm_data_web`. Wyniki zapisywane są w tabeli `dm_staging.log.postmigration_check` i obejmują łącznie 43 wskaźniki KPI podzielone na trzy kategorie.

Raport jest przekazywany zespołowi Intrum jako podstawa formalnego odbioru. Warunek zaliczenia dla wskaźników COUNT: liczba rekordów w produkcji równa się sumie stanu sprzed migracji (snapshot) i liczby rekordów zasilonych w stagingu. Dla etapu 1, gdzie baza produkcyjna była pusta przed migracją, snapshot = 0, więc wymagana liczba produkcyjna = liczba stagingowa.

<div class="api-section" markdown>
<div class="api-section-title">Kategorie KPI</div>

<div class="kategoria-grid">

<a class="kategoria-card kategoria-count" href="#kat-count">
  <div class="kategoria-header">
    <span class="kategoria-code">COUNT</span>
    <span class="kategoria-meta">25 KPI</span>
  </div>
  <p class="kategoria-desc">Uzgodnienie liczebności — czy liczba rekordów w każdej tabeli produkcyjnej odpowiada oczekiwanej (snapshot + staging) oraz liczebność tabel prod-only.</p>
</a>

<a class="kategoria-card kategoria-sum" href="#kat-sum">
  <div class="kategoria-header">
    <span class="kategoria-code">SUM</span>
    <span class="kategoria-meta">4 KPI</span>
  </div>
  <p class="kategoria-desc">Uzgodnienie finansowe — czy sumy kwot kluczowych kolumn finansowych (operacje, dekrety, kapitał, odsetki) zgadzają się ze stagingiem.</p>
</a>

<a class="kategoria-card kategoria-anomaly" href="#kat-anomaly">
  <div class="kategoria-header">
    <span class="kategoria-code">ANOMALY</span>
    <span class="kategoria-meta">14 KPI</span>
  </div>
  <p class="kategoria-desc">Jakość danych — rekordy osierocone, naruszenia zasady podwójnego zapisu, brakujące identyfikatory, duplikaty <code>ext_id</code> i inne odchylenia.</p>
</a>

</div>

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Zapytanie diagnostyczne</div>

Raport dostępny jest w formie wyniku zapytania SQL:

```sql
SELECT
    kpi_name            AS [KPI],
    kpi_type            AS [Typ],
    expected_value      AS [Oczekiwana (staging)],
    actual_value        AS [Rzeczywista (prod)],
    delta               AS [Delta],
    CASE WHEN pass = 1 THEN 'PASS'
         WHEN kpi_type = 'ANOMALY' THEN 'WARN'
         ELSE 'FAIL' END AS [Status],
    ISNULL(note, '')    AS [Uwaga]
FROM dm_staging.log.postmigration_check
WHERE run_id = <run_id>
ORDER BY check_id;
```

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Przykładowy wynik</div>

Scenariusz testowy etapu 0: N = 250 000 spraw.

<div class="kpi-summary-strip">
  <div class="kpi-summary-tile kpi-summary-total">
    <span class="kpi-summary-num">21</span>
    <span class="kpi-summary-label">Wskaźniki</span>
  </div>
  <div class="kpi-summary-tile kpi-summary-pass">
    <span class="kpi-summary-num">15</span>
    <span class="kpi-summary-label">PASS</span>
  </div>
  <div class="kpi-summary-tile kpi-summary-fail">
    <span class="kpi-summary-num">4</span>
    <span class="kpi-summary-label">FAIL</span>
  </div>
  <div class="kpi-summary-tile kpi-summary-warn">
    <span class="kpi-summary-num">2</span>
    <span class="kpi-summary-label">WARN</span>
  </div>
</div>

<div class="report-dashboard">
<table class="report-table">
  <thead>
    <tr>
      <th class="col-kpi">KPI</th>
      <th class="col-typ">Typ</th>
      <th class="col-num">Oczekiwana (staging)</th>
      <th class="col-num">Rzeczywista (prod)</th>
      <th class="col-num">Delta</th>
      <th class="col-status">Status</th>
      <th class="col-uwaga">Uwaga</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>KPI_CNT_01 dluznik</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_02 sprawa</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_03 wierzytelnosc</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_04 sprawa_rola</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_06 adres</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_07 telefon</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">250 000</td>
      <td class="num">250 000</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr class="row-alert">
      <td><code>KPI_CNT_09 akcja</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">500 000</td>
      <td class="num">498 312</td>
      <td class="num delta-neg">-1 688</td>
      <td><span class="status-pill status-fail">FAIL</span></td>
      <td><span class="kpi-note">Część rekordów akcji odrzucona z powodu brakującego <code>ak_akt_id</code> — wymaga korekty w danych źródłowych</span></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_10 dokument</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">≥ 250 000</td>
      <td class="num">500 000</td>
      <td class="num delta-pos">250 000</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td><span class="kpi-note">Iteracja 9 generuje dodatkowe rekordy dokumentów z harmonogramów</span></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_11 ksiegowanie</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">≥ 250 000</td>
      <td class="num">750 000</td>
      <td class="num delta-pos">500 000</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td><span class="kpi-note">Iteracja 8 i iteracja 9 generują dodatkowe rekordy z operacji i harmonogramów</span></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_12 ksiegowanie_dekret</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">≥ 500 000</td>
      <td class="num">1 750 000</td>
      <td class="num delta-pos">1 250 000</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td><span class="kpi-note">Operacje i harmonogramy generują dodatkowe dekrety</span></td>
    </tr>
    <tr>
      <td><code>KPI_CNT_13 błędy migracji</code></td>
      <td><span class="kpi-typ-badge kpi-typ-count">COUNT</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr class="row-alert">
      <td><code>KPI_SUM_01 suma ksd_kwota</code></td>
      <td><span class="kpi-typ-badge kpi-typ-sum">SUM</span></td>
      <td class="num">0,00</td>
      <td class="num">1 125 000 000,00</td>
      <td class="num delta-pos">1 125 000 000,00</td>
      <td><span class="status-pill status-fail">FAIL</span></td>
      <td><span class="kpi-note"><code>ksd_kwota</code> nie zasilona w stagingu — znany brak w danych testowych</span></td>
    </tr>
    <tr>
      <td><code>KPI_SUM_02 kwota operacji vs ksd_wn</code></td>
      <td><span class="kpi-typ-badge kpi-typ-sum">SUM</span></td>
      <td class="num">375 000 000,00</td>
      <td class="num">375 000 000,00</td>
      <td class="num">0,00</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr class="row-alert">
      <td><code>KPI_SUM_03 kapitał PLN</code></td>
      <td><span class="kpi-typ-badge kpi-typ-sum">SUM</span></td>
      <td class="num">300 000 000,00</td>
      <td class="num">375 000 000,00</td>
      <td class="num delta-pos">75 000 000,00</td>
      <td><span class="status-pill status-fail">FAIL</span></td>
      <td><span class="kpi-note">Identyfikatory kont kapitałowych (<code>ksk_id</code>) do potwierdzenia z zespołem deweloperskim</span></td>
    </tr>
    <tr class="row-alert">
      <td><code>KPI_SUM_04 odsetki PLN</code></td>
      <td><span class="kpi-typ-badge kpi-typ-sum">SUM</span></td>
      <td class="num">75 000 000,00</td>
      <td class="num">0,00</td>
      <td class="num delta-neg">75 000 000,00</td>
      <td><span class="status-pill status-fail">FAIL</span></td>
      <td><span class="kpi-note">Identyfikatory kont odsetkowych (<code>ksk_id</code>) do potwierdzenia z zespołem deweloperskim</span></td>
    </tr>
    <tr>
      <td><code>KPI_ANO_01 wi bez dokumentu</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_ANO_02 ks bez dekretu</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr class="row-warn">
      <td><code>KPI_ANO_06 dluznik bez identyfikatora</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">43</td>
      <td class="num delta-pos">43</td>
      <td><span class="status-pill status-warn">WARN</span></td>
      <td><span class="kpi-note">43 dłużników bez PESEL, NIP, dowodu ani paszportu — wymaga weryfikacji jakości danych</span></td>
    </tr>
    <tr class="row-warn">
      <td><code>KPI_ANO_07 niezbilansowane dekrety</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">250 000</td>
      <td class="num delta-pos">250 000</td>
      <td><span class="status-pill status-warn">WARN</span></td>
      <td><span class="kpi-note">Dekrety generowane przez harmonogramy — zachowanie oczekiwane</span></td>
    </tr>
    <tr>
      <td><code>KPI_ANO_08 ext_id NULL</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
    <tr>
      <td><code>KPI_ANO_09 ext_id duplikaty</code></td>
      <td><span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span></td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td class="num">0</td>
      <td><span class="status-pill status-pass">PASS</span></td>
      <td></td>
    </tr>
  </tbody>
</table>
</div>

</div>

---

<div class="api-section" markdown>

### COUNT — Uzgodnienie liczebności {#kat-count}

Porównanie liczby rekordów w bazie produkcyjnej z oczekiwaną wartością. Tryby porównania: **EXACT** (prod = snapshot + staging), **GTE** (prod ≥ snapshot + staging — tabele z dodatkowymi rekordami generowanymi przez pipeline), **INFO** (tabele prod-only — wskaźnik informacyjny, zawsze PASS).

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_01</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>dluznik</code> w prod = snapshot + staging.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_02</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>sprawa</code> w prod = snapshot + staging.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_03</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>wierzytelnosc</code> w prod = snapshot + staging.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_04</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>sprawa_rola</code> w prod = snapshot + staging.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_05</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>wierzytelnosc_rola</code> w prod = snapshot + staging.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_06</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>adres</code> w prod = snapshot + staging.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_07</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>telefon</code> w prod = snapshot + staging.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_08</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>mail</code> w prod = snapshot + staging.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_09</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>akcja</code> w prod = snapshot + staging.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_10</span>
  <span class="kpi-typ-badge kpi-typ-count">GTE</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>dokument</code> w prod ≥ snapshot + staging — iteracja 9 (harmonogramy) generuje dodatkowe rekordy dokumentów.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_11</span>
  <span class="kpi-typ-badge kpi-typ-count">GTE</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>ksiegowanie</code> w prod ≥ snapshot + staging — iteracja 8 (operacje) i iteracja 9 (harmonogramy) generują dodatkowe rekordy.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_12</span>
  <span class="kpi-typ-badge kpi-typ-count">GTE</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>ksiegowanie_dekret</code> w prod ≥ snapshot + staging — operacje i harmonogramy generują dodatkowe dekrety.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_13</span>
  <span class="kpi-typ-badge kpi-typ-count">EXACT</span>
</div>
<p class="kpi-card-desc">Liczba rekordów w <code>log.migration_error</code> dla bieżącego <code>run_id</code> = 0 — żaden rekord nie powinien zostać odrzucony podczas migracji.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_14</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>rachunek_bankowy</code> — tabela prod-only, generowana z <code>sprawa</code> w iteracji 4. Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_15</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>operator</code> — tabela prod-only, generowana z <code>sprawa</code> w iteracji 4. Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_16</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>atrybut_wartosc</code> — tabela prod-only, kompozyt z wielu źródeł stagingowych. Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_17</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>atrybut_dluznik</code> — tabela złączeniowa prod-only (iteracja 2). Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_18</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>atrybut_sprawa</code> — tabela złączeniowa prod-only (iteracja 4). Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_19</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>atrybut_wierzytelnosc</code> — tabela złączeniowa prod-only (iteracja 6). Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_20</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>atrybut_dokument</code> — tabela złączeniowa prod-only (iteracja 7). Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_21</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>wlasciwosc</code> — tabela prod-only, generowana przez procedurę domeny <code>wlasciwosc</code>. Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_22</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>wlasciwosc_dluznik</code> — tabela złączeniowa prod-only (iteracja 2, domena <code>wlasciwosc</code>). Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_23</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>wlasciwosc_adres</code> — tabela złączeniowa prod-only (iteracja 3, domena <code>wlasciwosc</code>). Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_24</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>wlasciwosc_email</code> — tabela złączeniowa prod-only (iteracja 3, domena <code>wlasciwosc</code>). Wskaźnik informacyjny.</p>
</div>

<div class="kpi-card kpi-card-count">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_CNT_25</span>
  <span class="kpi-typ-badge kpi-typ-count">INFO</span>
</div>
<p class="kpi-card-desc">Liczba rekordów <code>wlasciwosc_telefon</code> — tabela złączeniowa prod-only (iteracja 3, domena <code>wlasciwosc</code>). Wskaźnik informacyjny.</p>
</div>

</div>

---

<div class="api-section" markdown>

### SUM — Uzgodnienie finansowe {#kat-sum}

Porównanie sum kwot kluczowych kolumn finansowych ze stagingiem. Każdy wskaźnik ma zdefiniowaną tolerancję (0,01 PLN lub proporcjonalną) — przekroczenie tolerancji oznacza FAIL i wymaga wyjaśnienia.

<div class="kpi-card kpi-card-sum">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_SUM_01</span>
  <span class="kpi-typ-badge kpi-typ-sum">SUM</span>
</div>
<p class="kpi-card-desc"><code>SUM(ABS(ksd_kwota))</code> ze stagingu vs <code>SUM(ksd_kwota_wn + ksd_kwota_ma)</code> z prod (tylko rekordy ze stagingu, identyfikowane przez numeryczne <code>ksd_ext_id</code>). Tolerancja 0,01 PLN.</p>
</div>

<div class="kpi-card kpi-card-sum">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_SUM_02</span>
  <span class="kpi-typ-badge kpi-typ-sum">SUM</span>
</div>
<p class="kpi-card-desc"><code>SUM(oper_kwota_w_pln)</code> ze stagingu vs <code>SUM(ksd_kwota_wn_bazowa)</code> z prod (wszystkie dekrety). Tolerancja proporcjonalna 0,001% (min. 0,01 PLN) — różnice wynikają z zaokrągleń kursowych.</p>
</div>

<div class="kpi-card kpi-card-sum">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_SUM_03</span>
  <span class="kpi-typ-badge kpi-typ-sum">SUM</span>
</div>
<p class="kpi-card-desc">Kapitał PLN — <code>SUM(oper_kwota_kapitalu_w_pln)</code> ze stagingu vs <code>SUM(wn_bazowa - ma_bazowa)</code> dla <code>ksk_id = 2</code> (Kapitał) na prod. Tolerancja 0,01 PLN.</p>
</div>

<div class="kpi-card kpi-card-sum">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_SUM_04</span>
  <span class="kpi-typ-badge kpi-typ-sum">SUM</span>
</div>
<p class="kpi-card-desc">Odsetki PLN — <code>SUM(oper_kwota_odsetek_w_pln)</code> ze stagingu vs <code>SUM(wn_bazowa - ma_bazowa)</code> dla <code>ksk_id IN (5, 6, 8)</code> (karne, umowne, ustawowe) na prod. Tolerancja 0,01 PLN.</p>
</div>

</div>

---

<div class="api-section" markdown>

### ANOMALY — Jakość danych {#kat-anomaly}

Sprawdzenia jakości danych po migracji bezpośrednio na bazie produkcyjnej. Niezerowy wynik nie blokuje formalnego odbioru, ale jest oznaczany jako WARN i wymaga weryfikacji.

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_01</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Wierzytelność na prod bez żadnego powiązanego dokumentu — oczekiwane 0.</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_02</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Księgowanie na prod bez żadnego dekretu — oczekiwane 0.</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_03</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Dłużnik na prod bez żadnego rekordu w <code>sprawa_rola</code> — oczekiwane 0.</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_04</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Sprawa na prod bez żadnego rekordu w <code>wierzytelnosc_rola</code> — oczekiwane 0.</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_05a</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Dłużnik z liczbą telefonów przekraczającą próg — konfigurowalne w <code>configuration.threshold_config</code> (klucz: <code>max_phones_per_dluznik</code>, domyślnie 10).</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_05b</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Dłużnik z liczbą adresów przekraczającą próg — konfigurowalne w <code>configuration.threshold_config</code> (klucz: <code>max_adresy_per_dluznik</code>, domyślnie 10).</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_05c</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Sprawa z liczbą akcji przekraczającą próg — konfigurowalne w <code>configuration.threshold_config</code> (klucz: <code>max_akcje_per_sprawa</code>, domyślnie 200).</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_05d</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Wierzytelność z liczbą dokumentów przekraczającą próg — konfigurowalne w <code>configuration.threshold_config</code> (klucz: <code>max_dokumenty_per_wierzytelnosc</code>, domyślnie 50).</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_06</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Dłużnik na prod bez żadnego identyfikatora (PESEL, NIP, numer dowodu, numer paszportu) — porównanie z poziomem bazowym ze stagingu (<a href="../przygotowanie-danych/walidacje.md#biz_13">BIZ_13</a>).</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_07</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Niezbilansowane dekrety na prod — księgowania, dla których <code>ABS(SUM(ksd_kwota_wn) - SUM(ksd_kwota_ma)) &gt; 0,01 PLN</code>. Naruszenie zasady podwójnego zapisu.</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_08</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Nowe rekordy na prod z <code>ext_id IS NULL</code> wprowadzone przez bieżący <code>run_id</code> (różnica current − snapshot). Rekordy istniejące przed migracją są wyłączone — oczekiwane 0.</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_09</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Duplikaty <code>ext_id</code> w tabelach encyjnych na prod (<code>dluznik</code>, <code>sprawa</code>, <code>wierzytelnosc</code>, <code>adres</code>, <code>telefon</code>, <code>mail</code>, <code>dokument</code>, <code>ksiegowanie_dekret</code>) — oczekiwane 0.</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_10</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Wierzytelność na prod nie powiązana z żadną sprawą przez <code>wierzytelnosc_rola</code> — oczekiwane 0.</p>
</div>

<div class="kpi-card kpi-card-anomaly">
<div class="kpi-card-header">
  <span class="kpi-card-code">KPI_ANO_11</span>
  <span class="kpi-typ-badge kpi-typ-anomaly">ANOMALY</span>
</div>
<p class="kpi-card-desc">Dłużnik z formalnie poprawnym 11-cyfrowym PESEL (przeszedł <a href="../przygotowanie-danych/walidacje.md#kat-fmt">FMT_01</a>), ale z pustym <code>dl_data_urodzenia</code> — wskazuje na nietypowe kodowanie wieku/miesiąca lub niepoprawną datę kalendarzową (np. 1900-02-29).</p>
</div>

</div>
