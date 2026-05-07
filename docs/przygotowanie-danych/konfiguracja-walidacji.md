---
title: "Migracja ⬝ Konfiguracja walidacji"
---

# Konfiguracja walidacji i KPI

Każde uruchomienie migracji odczytuje plik konfiguracyjny w formacie JSON, który steruje tym, które walidacje (REF/TECH/FMT/STR/BIZ) i wskaźniki KPI (COUNT/SUM/ANOMALY) są aktywne dla danego klienta. Domyślnie wszystkie walidacje i KPI są włączone — wyłączenie konkretnych pozycji odbywa się przez edycję pliku w repozytorium dokumentacji.

Lista dostępnych walidacji opisana jest w sekcji _[Walidacje przed migracją](walidacje.md)_, a wskaźniki KPI — w _[Raport pomigracyjny](../przebieg-migracji/raport-pomigracyjny.md)_.

<div class="api-section" markdown>
<div class="api-section-title">Lokalizacja pliku konfiguracyjnego</div>

Plik znajduje się w repozytorium `intrum-migration-docs` pod ścieżką:

```
config/check_toggles.json
```

Pipeline migracji pobiera ten plik na początku każdego uruchomienia i stosuje znalezione w nim wyłączenia.

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Procedura edycji</div>

<ol class="assumption-list">
  <li><strong>Pull request</strong> — klient otwiera PR na repozytorium <code>intrum-migration-docs</code> ze zmianą w pliku <code>config/check_toggles.json</code>.</li>
  <li><strong>Przegląd i merge</strong> — zespół BAKK weryfikuje zmianę i merguje PR.</li>
  <li><strong>Kolejne uruchomienie</strong> — najbliższe uruchomienie pipeline'u migracyjnego automatycznie uwzględnia nową konfigurację (plik pobierany jest w trakcie wykonywania).</li>
</ol>

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Format pliku JSON</div>

Plik to obiekt JSON, w którym kluczami są krótkie identyfikatory walidacji/KPI (np. `REF_01`, `KPI_SUM_02`), a wartościami obiekty z polem `enabled` i opcjonalnym polem `reason`.

```json
{
  "FMT_07": { "enabled": false, "reason": "Migracja_Walidacje_Formatow_Stage1_20260429.xlsx" },
  "FMT_08": { "enabled": false, "reason": "Migracja_Walidacje_Formatow_Stage1_20260429.xlsx" },
  "FMT_11": { "enabled": false, "reason": "Migracja_Walidacje_Formatow_Stage1_20260429.xlsx" },
  "KPI_SUM_02": { "enabled": false, "reason": "Akceptowane zaokrąglenia kursowe FX powyżej tolerancji 0,001%" }
}
```

<ol class="assumption-list">
  <li><strong>Domyślnie wszystko włączone</strong> — pusty obiekt <code>{}</code> oznacza, że wszystkie walidacje i KPI są aktywne.</li>
  <li><strong>Wpisuje się tylko wyłączenia</strong> — brak klucza w pliku jest równoważny z <code>enabled: true</code>.</li>
  <li><strong>Klucze to krótkie identyfikatory</strong> — np. <code>REF_01</code>, a nie pełna nazwa <code>REF_01_sprawa_rola_dluznik</code>. Identyfikatory są stabilne między wersjami; pełne nazwy mogą się zmienić.</li>
  <li><strong>Nieznany klucz</strong> — pipeline emituje ostrzeżenie i pomija wpis (sytuacja typowa po przemianowaniu walidacji w nowej wersji).</li>
</ol>

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Pole <code>reason</code></div>

Część walidacji wymaga uzasadnienia w polu `reason` — w innym przypadku pipeline odmówi uruchomienia.

<div class="kategoria-grid">

<a class="kategoria-card kategoria-ref">
  <div class="kategoria-header">
    <span class="kategoria-code">BLOCKING</span>
    <span class="kategoria-meta">Walidacje</span>
  </div>
  <p class="kategoria-desc">Walidacje blokujące (REF, większość STR i BIZ) — wyłączenie wymaga niepustego <code>reason</code>, ponieważ chronią przed naruszeniem integralności danych, które normalnie wstrzymałoby migrację.</p>
</a>

<a class="kategoria-card kategoria-sum">
  <div class="kategoria-header">
    <span class="kategoria-code">CRITICAL</span>
    <span class="kategoria-meta">KPI</span>
  </div>
  <p class="kategoria-desc">Wskaźniki KPI_CNT i KPI_SUM — wyłączenie wymaga niepustego <code>reason</code>, ponieważ potwierdzają zgodność liczebności i sum finansowych po migracji.</p>
</a>

<a class="kategoria-card kategoria-fmt">
  <div class="kategoria-header">
    <span class="kategoria-code">INFO/WARNING</span>
    <span class="kategoria-meta">Pozostałe</span>
  </div>
  <p class="kategoria-desc">Walidacje informacyjne i ostrzegawcze (KPI_ANO, część FMT i STR) — pole <code>reason</code> nie jest wymagane, ale zaleca się jego uzupełnianie dla przejrzystości audytu.</p>
</a>

</div>

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Pominięte walidacje w raportach</div>

Wyłączone walidacje **nie są ukrywane** — są wyraźnie oznaczone w raportach, dzięki czemu audyt zawsze pozwala odpowiedzieć na pytanie *"czy ta walidacja została faktycznie wykonana, czy została celowo pominięta"*.

<ol class="assumption-list">
  <li><strong>Tabela <code>log.validation_result</code></strong> — wiersze pominiętych walidacji mają <code>affected_count IS NULL</code>, a kolumna <code>detail</code> zaczyna się od <code>'SKIPPED: &lt;reason&gt;'</code>.</li>
  <li><strong>Tabela <code>log.postmigration_check</code></strong> — wiersze pominiętych KPI mają <code>pass IS NULL</code>, a kolumna <code>note</code> zaczyna się od <code>'SKIPPED: &lt;reason&gt;'</code>.</li>
  <li><strong>Raport pomigracyjny</strong> — kursor wypisuje status <code>SKIP</code> obok wartości <code>PASS</code> i <code>FAIL</code>.</li>
</ol>

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Ślad audytowy</div>

Każde uruchomienie migracji rejestruje w tabeli `log.migration_run` trzy kolumny opisujące użytą konfigurację:

<ol class="assumption-list">
  <li><code>toggle_config_hash</code> — SHA-256 zawartości pliku JSON faktycznie użytego w uruchomieniu.</li>
  <li><code>toggle_config_fetched_at</code> — moment pobrania pliku (UTC).</li>
  <li><code>toggle_config_source</code> — źródło: <code>remote</code> (pobranie z repozytorium), <code>cache</code> (fallback do lokalnej kopii), <code>file</code> (lokalny plik), <code>env</code> (zmienna środowiskowa).</li>
</ol>

Aby zweryfikować, która wersja konfiguracji została użyta w danym uruchomieniu, odczytaj wartość `toggle_config_hash` z tabeli `log.migration_run`, a następnie porównaj z historią pliku w repozytorium `intrum-migration-docs` (`git log -p config/check_toggles.json`).

</div>

Pełna lista dostępnych walidacji wraz z poziomami i opisami — _[Walidacje przed migracją](walidacje.md)_. Pełna lista wskaźników KPI — _[Raport pomigracyjny](../przebieg-migracji/raport-pomigracyjny.md)_.
