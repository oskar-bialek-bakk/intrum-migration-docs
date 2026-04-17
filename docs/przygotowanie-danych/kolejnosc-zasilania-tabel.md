# Kolejność zasilania tabel stagingowych

### Zasady ogólne

1. **Wartości FK** muszą odnosić się do identyfikatorów ze stagingu, nie z bazy produkcyjnej.
2. Tabele w obrębie tej samej iteracji nie mają zależności między sobą i mogą być ładowane równolegle (chyba że zaznaczono inaczej).

---

### Iteracja 1 — Wszystkie tabele słownikowe i referencyjne

Iteracja 1 składa się z dwóch kroków:

**Krok 1A — wykonywany jednorazowo przez zespół BAKK** (przed przekazaniem stagingu zespołowi Intrum):
Skopiowanie istniejących danych produkcyjnych do tabel słownikowych w stagingu.

**Krok 1B — wykonywany przez zespół Intrum:**
1. Dodaj nowe wartości wymagane przez dane źródłowe (wartości nieistniejące jeszcze w bazie produkcyjnej).
2. Używaj identyfikatorów ze stagingu wypełniając kolumny FK w późniejszych iteracjach.
3. Podczas migracji skrypty BAKK automatycznie uzupełnią bazę produkcyjną o nowe wartości (operacja MERGE).

> **Uwaga:** Nie wszystkie słowniki muszą być zasilone przed pierwszą iteracją encji. Wystarczy zasilić tylko te słowniki, które są faktycznie wymagane przez tabele encji w danej iteracji. Przykład: przed Iteracją 2 (dłużnicy) konieczne jest zasilenie `dluznik_typ` oraz słowników atrybutów (`atrybut_dziedzina`, `atrybut_rodzaj`, `atrybut_typ`). Szczegółowe zależności per tabela opisuje kolumna „Zależności FK" w tabelach iteracji 2–9.

| Tabela | Uwagi |
|---|---|
| `dbo.waluta` | Słownik walut |
| `dbo.kurs_walut` | Kursy walut |
| `dbo.kontrahent` | Wierzyciele i kontrahenci |
| `dbo.umowa_kontrahent` | Umowy z kontrahentami — załadować po `kontrahent` |
| `dbo.adres_typ` | Słownik typów adresów |
| `dbo.dluznik_typ` | Słownik typów dłużników |
| `dbo.dokument_typ` | Słownik typów dokumentów |
| `dbo.ksiegowanie_konto` | Słownik kont księgowych |
| `dbo.ksiegowanie_typ` | Słownik typów księgowań |
| `dbo.sprawa_rola_typ` | Słownik ról w sprawie |
| `dbo.sprawa_typ` | Słownik typów spraw |
| `dbo.telefon_typ` | Słownik typów telefonów |
| `dbo.atrybut_dziedzina` | Słownik dziedzin atrybutów |
| `dbo.atrybut_rodzaj` | Słownik rodzajów atrybutów |
| `dbo.akcja_typ` | Słownik typów akcji. **Kolumny `akt_rodzaj` i `akt_ikona` muszą być uzupełnione dla każdego wiersza** — skonsultuj z zespołem BAKK dozwolone wartości z dokumentacji aplikacji. |
| `dbo.rezultat_typ` | Słownik typów rezultatów. **Kolumna `ret_konczy` (BIT) musi być uzupełniona dla każdego wiersza** — określa czy dany rezultat zamyka akcję. |
| `dbo.atrybut_typ` | Słownik typów atrybutów. **Wymaga uprzedniego zasilenia `atrybut_dziedzina` i `atrybut_rodzaj`.** |
| `dbo.sprawa_etap` | Słownik etapów spraw. **Wymaga uprzedniego zasilenia `sprawa_typ` i `akcja_typ`. Każdy wiersz `sprawa_etap` wymaga odpowiadającego wiersza w `akcja_typ`.** |
| `dbo.zrodlo_pochodzenia_informacji` | Słownik źródeł pochodzenia informacji |
| `dbo.wlasciwosc_typ_walidacji` | Słownik typów walidacji właściwości |
| `dbo.wlasciwosc_dziedzina` | Słownik dziedzin właściwości |
| `dbo.wlasciwosc_podtyp` | Słownik podtypów właściwości |
| `dbo.wlasciwosc_typ` | Słownik typów właściwości. **Wymaga uprzedniego zasilenia `wlasciwosc_typ_walidacji`.** |
| `dbo.wlasciwosc_typ_podtyp_dziedzina` | Powiązania typ-podtyp-dziedzina właściwości. **Wymaga uprzedniego zasilenia `wlasciwosc_typ`, `wlasciwosc_dziedzina`, `wlasciwosc_podtyp`.** |

---

### Iteracja 2 — Dłużnicy i ich atrybuty

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.dluznik` | `dl_dt_id → dluznik_typ` | Reguła biznesowa: `dl_dt_id` równe (1,2) → wymagane `dl_imie`, `dl_nazwisko`, `dl_pesel`. `dl_dt_id` równe (3,4) → wymagane `dl_firma`, `dl_nip`. |
| `dbo.atrybut` *(att_atd_id = 3)* | `at_att_id → atrybut_typ` (dziedzina i rodzaj dziedziczone z `atrybut_typ`), `at_ob_id → dluznik.dl_id` | Wyłącznie atrybuty dłużników (`atrybut_typ.att_atd_id = 3`). Załadować po `dluznik`. |
| `dbo.wlasciwosc` *(dziedzina=4)* | `wl_wtpd_id → wlasciwosc_typ_podtyp_dziedzina` | Główna tabela właściwości — załadować wiersze powiązane z dłużnikami (dziedzina=4). Załadować razem z `wlasciwosc_dluznik`. |
| `dbo.wlasciwosc_dluznik` | `wd_wl_id → wlasciwosc`, `wd_dl_id → dluznik` | Właściwości dłużników. Załadować po `dluznik`. Wymaga zasilenia tabel słownikowych `wlasciwosc_*` w Iteracji 1. |

---

### Iteracja 3 — Dane kontaktowe dłużników

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.adres` | `ad_dl_id → dluznik`, `ad_at_id → adres_typ` | Dozwolonych wiele adresów na dłużnika. Maksymalna liczba jednocześnie aktywnych adresów danego typu (`ad_at_id`) jest konfigurowana w prod: `adres_typ_podmiot_konfiguracja.atpk_il` (dla `atp_id=2` — dłużnik). Aktywny = `ad_data_do IS NULL` lub `ad_data_do > GETDATE()`. Przekroczenie limitu jest **blokujące** (BIZ_20). |
| `dbo.mail` | `ma_dl_id → dluznik` | |
| `dbo.telefon` | `tn_dl_id → dluznik`, `tn_tt_id → telefon_typ` | Dozwolonych wiele numerów telefonu na dłużnika, jednak dla każdego typu telefonu (`tn_tt_id`) tylko jeden rekord może być jednocześnie aktywny (brak daty zakończenia lub `tn_data_do > GETDATE()`). |
| `dbo.wlasciwosc` *(dziedzina=1,2,3)* | `wl_wtpd_id → wlasciwosc_typ_podtyp_dziedzina` | Wiersze właściwości powiązane z adresami (dziedzina=2), e-mailami (dziedzina=3) i telefonami (dziedzina=1). Załadować razem z `wlasciwosc_adres`, `wlasciwosc_email`, `wlasciwosc_telefon`. |
| `dbo.wlasciwosc_adres` | `wa_wl_id → wlasciwosc`, `wa_ad_id → adres` | Właściwości adresów. Załadować po `adres`. |
| `dbo.wlasciwosc_email` | `we_wl_id → wlasciwosc`, `we_ma_id → mail` | Właściwości adresów e-mail. Załadować po `mail`. |
| `dbo.wlasciwosc_telefon` | `wt_wl_id → wlasciwosc`, `wt_tn_id → telefon` | Właściwości telefonów. Załadować po `telefon`. |

---

### Iteracja 4 — Sprawy, role i atrybuty spraw

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.sprawa` | `sp_spt_id → sprawa_typ`, `sp_spe_id → sprawa_etap` | `sp_numer_rachunku` — numer rachunku bankowego jako tekst. `sp_pracownik` — opcjonalny. `sp_data_obslugi_od` / `sp_data_obslugi_do` — opcjonalne daty obsługi. `sp_import_info` — data importu w formacie `yyyy-mm-dd hh:mm:ss.zzz`. |
| `dbo.sprawa_rola` | `spr_sp_id → sprawa`, `spr_dl_id → dluznik`, `spr_sprt_id → sprawa_rola_typ` | Przypisanie dłużników do spraw wraz z rolą. Załadować po `sprawa`. |
| `dbo.atrybut` *(att_atd_id = 4)* | `at_att_id → atrybut_typ` (dziedzina i rodzaj dziedziczone z `atrybut_typ`), `at_ob_id → sprawa.sp_id` | Wyłącznie atrybuty spraw (`atrybut_typ.att_atd_id = 4`). Załadować po `sprawa`. |

---

### Iteracja 5 — Akcje i rezultaty

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.akcja` | `ak_sp_id → sprawa`, `ak_akt_id → akcja_typ` | Akcje windykacyjne. `ak_data_zakonczenia` — akcja zamknięta: uzupełnić, jeśli do akcji nie będą dodawane więcej rezultatów. |
| `dbo.rezultat` | `re_ak_id → akcja`, `re_ret_id → rezultat_typ` | Załadować po `akcja`. Wymagany przynajmniej jeden rezultat każdej akcji. |

---

### Iteracja 6 — Wierzytelności i ich atrybuty

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.wierzytelnosc` | `wi_sp_id → sprawa`, `wi_uko_id → umowa_kontrahent` | Wierzytelności powiązane ze sprawami |
| `dbo.atrybut` *(att_atd_id = 2)* | `at_att_id → atrybut_typ` (dziedzina i rodzaj dziedziczone z `atrybut_typ`), `at_ob_id → wierzytelnosc.wi_id` | Wyłącznie atrybuty wierzytelności (`atrybut_typ.att_atd_id = 2`). Załadować po `wierzytelnosc`. |

---

### Iteracja 7 — Dokumenty, role wierzytelności i atrybuty dokumentów

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.wierzytelnosc_rola` | `wir_wi_id → wierzytelnosc`, `wir_sp_id → sprawa` | Powiązania wierzytelności ze sprawami |
| `dbo.dokument` | `do_wi_id → wierzytelnosc`, `do_dot_id → dokument_typ` | Dokumenty finansowe |
| `dbo.atrybut` *(att_atd_id = 1)* | `at_att_id → atrybut_typ` (dziedzina i rodzaj dziedziczone z `atrybut_typ`), `at_ob_id → dokument.do_id` | Wyłącznie atrybuty dokumentów (`atrybut_typ.att_atd_id = 1`). Załadować po `dokument`. |

---

### Iteracja 8 — Dane finansowe

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.ksiegowanie` | `ks_kst_id → ksiegowanie_typ` | Nagłówki księgowań |
| `dbo.operacja` | `oper_wi_id → wierzytelnosc` | Surowe operacje finansowe z systemu źródłowego |
| `dbo.ksiegowanie_dekret` | `ksd_ks_id → ksiegowanie`, `ksd_do_id → dokument`, `ksd_ksk_id → ksiegowanie_konto`, `ksd_sp_id → sprawa`, `ksd_wa_id → waluta` | Załadować po `ksiegowanie`. Kolumny wielowalutowe (`ksd_kurs_bazowy`, `ksd_kwota_wn/ma_*`) są opcjonalne — wypełnić jeśli system źródłowy dostarcza dane wyceny. |

---

### Iteracja 9 — Ostatnia

| Tabela | Zależności FK | Uwagi |
|---|---|---|
| `dbo.harmonogram` | `hr_wi_id → wierzytelnosc` | Harmonogram spłat |
| `dbo.zabezpieczenie` | `zab_wi_id → wierzytelnosc`, `zab_dl_id → dluznik` | **Tylko od etapu 2 migracji** — nie jest wymagane dla etapu 1. |

---

### Podsumowanie kolejności

```
Iteracja 1  → waluta, kurs_walut, kontrahent, umowa_kontrahent,
               adres_typ, dluznik_typ, dokument_typ, ksiegowanie_konto,
               ksiegowanie_typ, sprawa_rola_typ, sprawa_typ, telefon_typ,
               atrybut_dziedzina, atrybut_rodzaj, akcja_typ, rezultat_typ,
               atrybut_typ*, sprawa_etap*, zrodlo_pochodzenia_informacji,
               wlasciwosc_typ_walidacji, wlasciwosc_dziedzina, wlasciwosc_podtyp,
               wlasciwosc_typ*, wlasciwosc_typ_podtyp_dziedzina*          (* po spełnieniu zależności)
Iteracja 2  → dluznik, atrybut (att_atd_id=3), wlasciwosc (dziedzina=4), wlasciwosc_dluznik
Iteracja 3  → adres, mail, telefon, wlasciwosc (dziedzina=1,2,3), wlasciwosc_adres, wlasciwosc_email, wlasciwosc_telefon
Iteracja 4  → sprawa, sprawa_rola, atrybut (att_atd_id=4)
Iteracja 5  → akcja, rezultat
Iteracja 6  → wierzytelnosc, atrybut (att_atd_id=2)
Iteracja 7  → wierzytelnosc_rola, dokument, atrybut (att_atd_id=1)
Iteracja 8  → ksiegowanie, operacja, ksiegowanie_dekret       (dane finansowe)
Iteracja 9  → harmonogram, zabezpieczenie                     (ostatnie)
```
