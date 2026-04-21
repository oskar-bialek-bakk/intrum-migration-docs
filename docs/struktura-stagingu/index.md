---
title: "Migracja ⬝ Struktura stagingu"
tags:
  - brq211
  - brq212
  - brq214
---

# Struktura stagingu

Sekcja opisuje tabele bazy stagingowej `dm_staging` w podziale na dziewięć iteracji ładowania oraz wspólne definicje referencyjne. Każda strona zawiera diagram ER, szczegółowe definicje kolumn i odwzorowanie na tabele produkcyjne `dm_data_web`.

## Fale dostawy danych

<div class="feature-grid">

<a class="feature-card" href="slowniki/">
  <span class="card-icon">❋</span>
  <span class="card-title">Iteracja 1 — Słowniki</span>
  <p class="card-desc">Tabele słownikowe i referencyjne — waluty, kursy, typy, dziedziny. Pierwsza fala, musi być załadowana przed wszystkim innym.</p>
</a>

<a class="feature-card" href="dluznicy/">
  <span class="card-icon">▦</span>
  <span class="card-title">Iteracja 2 — Dłużnicy</span>
  <p class="card-desc">Główni dłużnicy wraz z atrybutami identyfikującymi. Po słownikach.</p>
</a>

<a class="feature-card" href="kontakty/">
  <span class="card-icon">✉</span>
  <span class="card-title">Iteracja 3 — Kontakty</span>
  <p class="card-desc">Adresy, numery telefonu, adresy e-mail dłużników. Po dłużnikach.</p>
</a>

<a class="feature-card" href="sprawy/">
  <span class="card-icon">⎆</span>
  <span class="card-title">Iteracja 4 — Sprawy</span>
  <p class="card-desc">Sprawy i role w sprawach. Po dłużnikach.</p>
</a>

<a class="feature-card" href="akcje/">
  <span class="card-icon">▶</span>
  <span class="card-title">Iteracja 5 — Akcje</span>
  <p class="card-desc">Akcje prowadzone w sprawach i ich rezultaty. Po sprawach.</p>
</a>

<a class="feature-card" href="wierzytelnosci/">
  <span class="card-icon">€</span>
  <span class="card-title">Iteracja 6 — Wierzytelności</span>
  <p class="card-desc">Wierzytelności i ich atrybuty. Po sprawach.</p>
</a>

<a class="feature-card" href="role-wierzytelnosci-i-dokumenty/">
  <span class="card-icon">§</span>
  <span class="card-title">Iteracja 7 — Role wierzytelności i dokumenty</span>
  <p class="card-desc">Role wierzytelności oraz dokumenty. Po wierzytelnościach.</p>
</a>

<a class="feature-card" href="finanse/">
  <span class="card-icon">∑</span>
  <span class="card-title">Iteracja 8 — Finanse</span>
  <p class="card-desc">Księgowania i dekrety. Po dokumentach.</p>
</a>

<a class="feature-card" href="harmonogram/">
  <span class="card-icon">◷</span>
  <span class="card-title">Iteracja 9 — Harmonogram</span>
  <p class="card-desc">Harmonogramy spłat. Po wierzytelnościach.</p>
</a>

</div>

## Referencje

<div class="feature-grid">

<a class="feature-card" href="tabele-generyczne/">
  <span class="card-icon">⚙</span>
  <span class="card-title">Tabele generyczne</span>
  <p class="card-desc">Definicje tabel współdzielonych między iteracjami (<code>atrybut</code>, <code>wlasciwosc</code>) wraz z opisem kolumn-dyskryminatorów.</p>
</a>

</div>
