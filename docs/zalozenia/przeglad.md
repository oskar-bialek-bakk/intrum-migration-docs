---
title: "Migracja ⬝ Przegląd"
---

# Przegląd

Niniejsza dokumentacja opisuje proces migracji danych historycznych Intrum z bazy stagingowej `dm_staging` do produkcyjnej bazy `dm_data_web` systemu DEBT Manager. Dokument stanowi wspólny punkt odniesienia dla zespołów BAKK (dostawca systemu) i Intrum (właściciel danych) na każdym etapie procesu — od zasilenia stagingu, przez walidacje, aż po formalny odbiór.

<div class="api-section" markdown>
<div class="api-section-title">Zakres procesu</div>

Migracja obejmuje trzy główne etapy:

<ol class="assumption-list">
  <li><strong>Zasilenie stagingu</strong> — zespół Intrum ładuje dane do bazy <code>dm_staging</code> zgodnie z kolejnością opisaną w sekcji <a href="../przygotowanie-danych/index.md"><em>Przygotowanie danych</em></a>.</li>
  <li><strong>Walidacje przed migracją</strong> — zespół BAKK uruchamia zestaw reguł walidacyjnych na stagingu; wynik (błędy blokujące, ostrzeżenia, informacje) jest przekazywany Intrum do korekty.</li>
  <li><strong>Migracja do produkcji</strong> — po usunięciu błędów blokujących dane są przenoszone do <code>dm_data_web</code> i generowany jest raport pomigracyjny stanowiący podstawę formalnego odbioru.</li>
</ol>

</div>

---

<div class="api-section">
<div class="api-section-title">Podział odpowiedzialności</div>

<div class="role-card">
  <div class="role-header">
    <span class="role-owner role-kontrahent">Intrum</span>
    <span class="role-name">Właściciel danych</span>
  </div>
  <p class="role-desc">Dostarczenie kompletnych i poprawnych danych w stagingu, korekta błędów blokujących, decyzja o akceptacji ostrzeżeń, formalny odbiór po migracji.</p>
</div>

<div class="role-card">
  <div class="role-header">
    <span class="role-owner role-it">BAKK</span>
    <span class="role-name">Dostawca systemu</span>
  </div>
  <p class="role-desc">Projekt stagingu, implementacja i utrzymanie pipeline'u migracyjnego, uruchomienie walidacji i migracji, wygenerowanie raportu pomigracyjnego.</p>
</div>

</div>

Szczegółowy opis klasyfikacji walidacji znajduje się na stronie _[Poziomy walidacji](poziomy-walidacji.md)_.
