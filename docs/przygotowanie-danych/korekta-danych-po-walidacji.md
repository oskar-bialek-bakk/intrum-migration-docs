---
title: "Migracja ⬝ Korekta danych po walidacji"
---

# Korekta danych po walidacji

Po uruchomieniu walidacji zespół BAKK przekazuje raport w formie wyniku zapytania SQL (szczegóły zapytania — _[Walidacje przed migracją](walidacje.md)_). Raport zawiera dla każdego wykrytego naruszenia: kod reguły, poziom wagi, przykładowe identyfikatory rekordów oraz opis odchylenia.

<div class="api-section" markdown>
<div class="api-section-title">Przykładowy raport błędów blokujących</div>

Każdy rekord raportu to jeden naruszający identyfikator — kody reguł powtarzają się tyle razy, ile rekordów narusza daną regułę.

<div class="report-dashboard">
<table class="report-table">
  <thead>
    <tr>
      <th class="col-kpi">Kod</th>
      <th class="col-status">Poziom</th>
      <th class="col-num">ID rekordu</th>
      <th class="col-uwaga">Opis</th>
    </tr>
  </thead>
  <tbody>
    <tr class="row-alert">
      <td><code>STR_06</code></td>
      <td><span class="status-pill status-fail">BLOCKING</span></td>
      <td class="num">201</td>
      <td>Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden</td>
    </tr>
    <tr class="row-alert">
      <td><code>STR_06</code></td>
      <td><span class="status-pill status-fail">BLOCKING</span></td>
      <td class="num">202</td>
      <td>Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden</td>
    </tr>
    <tr class="row-alert">
      <td><code>STR_06</code></td>
      <td><span class="status-pill status-fail">BLOCKING</span></td>
      <td class="num">203</td>
      <td>Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden</td>
    </tr>
    <tr class="row-alert">
      <td><code>STR_06</code></td>
      <td><span class="status-pill status-fail">BLOCKING</span></td>
      <td class="num">204</td>
      <td>Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden</td>
    </tr>
    <tr class="row-alert">
      <td><code>STR_06</code></td>
      <td><span class="status-pill status-fail">BLOCKING</span></td>
      <td class="num">205</td>
      <td>Akcja nie ma żadnego rezultatu — wymagany co najmniej jeden</td>
    </tr>
    <tr class="row-alert">
      <td><code>REF_14</code></td>
      <td><span class="status-pill status-fail">BLOCKING</span></td>
      <td class="num">310</td>
      <td><code>akcja.ak_sp_id</code> wskazuje na nieistniejącą sprawę</td>
    </tr>
    <tr class="row-alert">
      <td><code>REF_14</code></td>
      <td><span class="status-pill status-fail">BLOCKING</span></td>
      <td class="num">311</td>
      <td><code>akcja.ak_sp_id</code> wskazuje na nieistniejącą sprawę</td>
    </tr>
    <tr class="row-alert">
      <td><code>TECH_03</code></td>
      <td><span class="status-pill status-fail">BLOCKING</span></td>
      <td class="num">88</td>
      <td><code>sprawa.sp_numer_rachunku</code> ma wartość NULL — pole wymagane</td>
    </tr>
  </tbody>
</table>
</div>

</div>

---

<div class="api-section" markdown>
<div class="api-section-title">Procedura korekty</div>

!!! danger "Błędy blokujące"
    Wymagają korekty w danych źródłowych i ponownego załadowania do stagingu. **Migracja nie może się rozpocząć, dopóki w raporcie pozostaje choć jeden błąd blokujący.**

!!! warning "Ostrzeżenia"
    Można zdecydować o korekcie w stagingu lub pisemnej akceptacji odchylenia przed migracją. Decyzja należy do zespołu Intrum.

!!! info "Informacje"
    Nie wymagają żadnej akcji — służą wyłącznie zwiększeniu świadomości o stanie danych.

Po każdej rundzie korekt walidacje uruchamiane są ponownie. Cykl powtarzany jest aż do uzyskania raportu bez błędów blokujących — dopiero wtedy możliwe jest przejście do etapu _[Uruchomienie migracji](../przebieg-migracji/uruchomienie.md)_.

</div>
