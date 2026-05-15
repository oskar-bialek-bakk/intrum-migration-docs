---
title: "Migracja ⬝ Tabele generyczne"
tags:
  - brq211
  - brq212
---

# Tabele generyczne

Tabele generyczne to staging-owe tabele, do których ładuje się dane dotyczące różnych obiektów (dłużnik, sprawa, wierzytelność, dokument itp.). Rozróżnienie obiektów następuje przez kolumnę-dyskryminator (`obiekt_typ`, `att_atd_id`, `wdzi_id`). Aby załadować atrybut/właściwość dla konkretnej domeny, ustaw wartość dyskryminatora zgodnie z tabelą poniżej w opisie tabeli.

<div class="iter-meta">
  <span>Używane w: Iteracja 2, 3, 4, 6, 7</span>
  <span>Walidacje: — (walidacje per-iteracja obejmują też generyczne)</span>
  <span>Zakres: tabele współdzielone między iteracjami</span>
</div>

## Diagram ER

```mermaid
erDiagram
    atrybut {
        bigint      at_id              PK
        bigint      at_ob_id           FK   "polimorficzny FK → dl_id/sp_id/wi_id/do_id"
        int         at_att_id          FK
        varchar     at_wartosc
    }

    atrybut_dziedzina {
        int         atd_id             PK
    }

    wlasciwosc {
        bigint      wl_id              PK
        int         wl_wtpd_id         FK   "→ wlasciwosc_typ_podtyp_dziedzina"
        datetime    wl_aktywny_od
        datetime    wl_aktywny_do            "NULL = aktywna"
    }

    wlasciwosc_dluznik {
        bigint      wd_id              PK
        bigint      wd_wl_id           FK
        bigint      wd_dl_id           FK
    }

    wlasciwosc_adres {
        bigint      wa_id              PK
        bigint      wa_wl_id           FK
        bigint      wa_ad_id           FK
    }

    wlasciwosc_email {
        bigint      we_id              PK
        bigint      we_wl_id           FK
        bigint      we_ma_id           FK
    }

    wlasciwosc_telefon {
        bigint      wt_id              PK
        bigint      wt_wl_id           FK
        bigint      wt_tn_id           FK
    }

    wlasciwosc_dluznik }o--|| wlasciwosc : "wd_wl_id"
    wlasciwosc_adres }o--|| wlasciwosc : "wa_wl_id"
    wlasciwosc_email }o--|| wlasciwosc : "we_wl_id"
    wlasciwosc_telefon }o--|| wlasciwosc : "wt_wl_id"
```

## Tabele

### dbo.atrybut

<details markdown="1">
<summary><code>dbo.atrybut</code> — <span class="ksztalt-badge ksztalt-rozbicie">rozbicie</span> atrybuty dla dłużnika / sprawy / wierzytelności / dokumentu</summary>

<div class="dict-meta">
  <span>Tabele prod: (wiele, per dziedzina)</span>
  <span>Kształt mapowania: rozbicie</span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak</span>
</div>

Atrybut jest wiersza-na-obiekt — jedna tabela `dbo.atrybut` ładuje dane atrybutowe dla wielu domen. Rozróżnienie domeny następuje pośrednio: `at_att_id` → `atrybut_typ.att_atd_id` → `atrybut_dziedzina`. Poniższa tabela pokazuje, jak dobierać `at_att_id` zależnie od obiektu, który opisujesz:

| `at_att_id` → `atrybut_typ.att_atd_id` | Dziedzina | Iteracja ładowania |
|---|---|---|
| att_atd_id = 1 | dokument | Iter 7 — [role-wierzytelnosci-i-dokumenty](role-wierzytelnosci-i-dokumenty.md) |
| att_atd_id = 2 | wierzytelność | Iter 6 — [wierzytelnosci](wierzytelnosci.md) |
| att_atd_id = 3 | dłużnik | Iter 2 — [dluznicy](dluznicy.md) |
| att_atd_id = 4 | sprawa | Iter 4 — [sprawy](sprawy.md) |

<ul class="param-list">
  <li>
    <span class="param-name pk required">at_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">Klucz główny atrybutu</span>
  </li>
  <li>
    <span class="param-name fk required">at_ob_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">FK polimorficzny do encji docelowej - identyfikator obiektu określonego przez atrybut_typ.att_atd_id (referuje dl_id / sp_id / wi_id / do_id, dlatego BIGINT)</span>
  </li>
  <li>
    <span class="param-name fk required">at_att_id</span>
    <span class="param-type">INT</span>
    <span class="param-desc">Typ atrybutu - FK do atrybut_typ (rodzaj informacji, np. PESEL, adres email, numer sprawy w sądzie)</span>
  </li>
  <li>
    <span class="param-name required">at_wartosc</span>
    <span class="param-type">VARCHAR(500)</span>
    <span class="param-desc">Wartość atrybutu - tekst, liczba lub data w formacie zgodnym z at_att_id.typ_wartosci</span>
  </li>
</ul>

</details>

### dbo.wlasciwosc

<details markdown="1">
<summary><code>dbo.wlasciwosc</code> + <code>dbo.wlasciwosc_{dluznik,adres,email,telefon}</code> — <span class="ksztalt-badge ksztalt-rozbicie">rozbicie</span> właściwości dla dłużnika i kanałów kontaktowych</summary>

<div class="dict-meta">
  <span>Tabele prod: (wiele, per kanał)</span>
  <span>Kształt mapowania: rozbicie</span>
  <span>Obowiązkowa: nie</span>
  <span>Multi-row: tak</span>
</div>

Właściwość działa w układzie par `wlasciwosc` + tabela łącznikowa specyficzna dla domeny (`wlasciwosc_dluznik`, `wlasciwosc_adres`, `wlasciwosc_email`, `wlasciwosc_telefon`). Każda para korzysta z własnego `wdzi_id` z tabeli `wlasciwosc_dziedzina`:

| `wdzi_id` | Dziedzina / tabela łącznikowa | Iteracja ładowania |
|---|---|---|
| 1 | telefon / `wlasciwosc_telefon` | Iter 3 — [kontakty](kontakty.md) |
| 2 | adres / `wlasciwosc_adres` | Iter 3 — [kontakty](kontakty.md) |
| 3 | email / `wlasciwosc_email` | Iter 3 — [kontakty](kontakty.md) |
| 4 | dłużnik / `wlasciwosc_dluznik` | Iter 2 — [dluznicy](dluznicy.md) |

<ul class="param-list">
  <li>
    <span class="param-name pk required">wl_id</span>
    <span class="param-type">BIGINT</span>
    <span class="param-desc">Klucz główny właściwości</span>
  </li>
  <li>
    <span class="param-name required">w_wartosc</span>
    <span class="param-type">VARCHAR(500)</span>
    <span class="param-desc">Wartość właściwości - format zgodny z wlasciwosc_typ.typ_walidacji</span>
  </li>
</ul>

Szczegóły tabel łącznikowych (`wlasciwosc_dluznik`, `wlasciwosc_adres`, `wlasciwosc_email`, `wlasciwosc_telefon`) — patrz odpowiadające im iteracje [2 — dłużnicy](dluznicy.md) / [3 — kontakty](kontakty.md).

</details>

## Powiązania

- Słownik dziedzin atrybutów: [Słowniki § dbo.atrybut_dziedzina](slowniki.md#dboatrybut_dziedzina)
- Słownik typów atrybutów: [Słowniki § dbo.atrybut_typ](slowniki.md#dboatrybut_typ)
- Słownik dziedzin właściwości: [Słowniki § dbo.wlasciwosc_dziedzina](slowniki.md#dbowlasciwosc_dziedzina)
- Słownik typów właściwości: [Słowniki § dbo.wlasciwosc_typ](slowniki.md#dbowlasciwosc_typ)

