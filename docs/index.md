---
title: "Migracja danych stagingowych DEBT Manager"
tags:
  - brq211
  - brq212
  - brq213
  - brq214
  - brq216
  - brq217
  - brq218
  - brq219
  - brq2110
  - brq2111
---

# Migracja danych stagingowych DEBT Manager

Dokumentacja techniczna procesu migracji danych stagingowych do bazy produkcyjnej w systemie DEBT Manager. Obejmuje zasady zasilania bazy stagingowej, walidacje jakości danych, przebieg migracji oraz procedurę odbioru po stronie zespołu Intrum.

<div class="feature-grid">

<a class="feature-card" href="zalozenia/">
  <span class="card-icon">⚙</span>
  <span class="card-title">Założenia</span>
  <p class="card-desc">Wstęp, poziomy walidacji, architektura pipeline'u migracyjnego.</p>
</a>

<a class="feature-card" href="przygotowanie-danych/">
  <span class="card-icon">▦</span>
  <span class="card-title">Przygotowanie danych</span>
  <p class="card-desc">Kolejność zasilania tabel, walidacje stagingu, mapowanie tabel staging → prod.</p>
</a>

<a class="feature-card" href="przebieg-migracji/">
  <span class="card-icon">▶</span>
  <span class="card-title">Przebieg migracji</span>
  <p class="card-desc">Uruchomienie migracji, postępowanie po błędach, raport pomigracyjny.</p>
</a>

<a class="feature-card" href="odbior/odbior-danych/">
  <span class="card-icon">✓</span>
  <span class="card-title">Odbiór</span>
  <p class="card-desc">Odbiór danych w środowisku produkcyjnym po stronie zespołu Intrum.</p>
</a>

<a class="feature-card" href="struktura-stagingu/slowniki/">
  <span class="card-icon">❋</span>
  <span class="card-title">Tabele słownikowe</span>
  <p class="card-desc">Słowniki i tabele referencyjne stagingu (iteracja 1) — opis kolumn i mapowanie na prod.</p>
</a>

</div>
