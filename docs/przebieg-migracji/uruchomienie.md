---
title: "Migracja ⬝ Uruchomienie"
---

# Uruchomienie migracji

Po uzyskaniu raportu walidacji bez błędów blokujących zespół BAKK przystępuje do migracji danych ze stagingu do bazy produkcyjnej `dm_data_web`. Migracja wykonywana jest w ustalonym oknie czasowym i obejmuje wszystkie zasilone tabele stagingowe w kolejności wynikającej z zależności FK.

<div class="api-section" markdown>
<div class="api-section-title">Przebieg migracji</div>

<div class="pipeline">
  <div class="pipeline-step">
    <span class="step-num">1</span>
    <span class="step-title">Snapshot przed migracją</span>
    <span class="step-desc">Zrzut stanu tabel produkcyjnych (liczba rekordów, sumy kluczowych kolumn finansowych) jako referencja dla raportu pomigracyjnego.</span>
  </div>
  <span class="pipeline-arrow">&#x2192;</span>
  <div class="pipeline-step">
    <span class="step-num">2</span>
    <span class="step-title">Wyłączenie indeksów</span>
    <span class="step-desc">NCI na kluczowych tabelach produkcyjnych są wyłączane przed masowymi INSERT-ami.</span>
  </div>
  <span class="pipeline-arrow">&#x2192;</span>
  <div class="pipeline-step">
    <span class="step-num">3</span>
    <span class="step-title">Migracja iteracyjna</span>
    <span class="step-desc">Tabele ładowane są w 9 iteracjach — od słowników, przez dłużników i sprawy, po dane finansowe i harmonogram.</span>
  </div>
  <span class="pipeline-arrow">&#x2192;</span>
  <div class="pipeline-step">
    <span class="step-num">4</span>
    <span class="step-title">Rebuild indeksów</span>
    <span class="step-desc">Odbudowa NCI oraz aktualizacja statystyk na tabelach zmienionych w trakcie migracji.</span>
  </div>
  <span class="pipeline-arrow">&#x2192;</span>
  <div class="pipeline-step">
    <span class="step-num">5</span>
    <span class="step-title">Raport pomigracyjny</span>
    <span class="step-desc">Uruchomienie skryptu <code>99_post_report.sql</code> i przekazanie wyniku zespołowi Intrum.</span>
  </div>
</div>

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Kolejność iteracji</div>

<ol class="assumption-list">
  <li><strong>Iteracja 1</strong> — tabele słownikowe i referencyjne (waluty, typy dłużników, atrybuty, właściwości, akcje).</li>
  <li><strong>Iteracja 2</strong> — dłużnicy i ich atrybuty / właściwości.</li>
  <li><strong>Iteracja 3</strong> — dane kontaktowe dłużników (adresy, telefony, e-maile).</li>
  <li><strong>Iteracja 4</strong> — sprawy, role w sprawach i atrybuty spraw.</li>
  <li><strong>Iteracja 5</strong> — akcje i rezultaty.</li>
  <li><strong>Iteracja 6</strong> — wierzytelności i ich atrybuty.</li>
  <li><strong>Iteracja 7</strong> — dokumenty, role wierzytelności i atrybuty dokumentów.</li>
  <li><strong>Iteracja 8</strong> — dane finansowe (księgowania, operacje, dekrety).</li>
  <li><strong>Iteracja 9</strong> — harmonogram spłat i zabezpieczenia (etap 2).</li>
</ol>

</div>

Po zakończeniu pipeline zespół BAKK przekazuje raport pomigracyjny oraz podsumowanie liczby zmigrowanych rekordów per tabela jako podstawę do formalnego odbioru przez Intrum. Szczegóły raportu — _[Raport pomigracyjny](raport-pomigracyjny.md)_.
