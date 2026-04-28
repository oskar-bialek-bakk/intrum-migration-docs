USE dm_staging;
GO

-- ============================================================
-- Extended property descriptions for staging tables
-- Run after staging schema is created.
-- Generated incrementally — append new tables as reviewed.
-- ============================================================

-- ------------------------------------------------------------
-- dbo.adres_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów adresów (np. zameldowania, korespondencyjny)', 'SCHEMA', 'dbo', 'TABLE', 'adres_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu adresu (PK)', 'SCHEMA', 'dbo', 'TABLE', 'adres_typ', 'COLUMN', 'at_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu adresu', 'SCHEMA', 'dbo', 'TABLE', 'adres_typ', 'COLUMN', 'at_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'adres_typ', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'adres_typ', 'COLUMN', 'at_uuid';

-- ------------------------------------------------------------
-- dbo.dluznik_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów dłużników (np. osoba fizyczna, firma)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu dłużnika (PK)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik_typ', 'COLUMN', 'dt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'dluznik_typ', 'COLUMN', 'dt_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'dluznik_typ', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'dluznik_typ', 'COLUMN', 'dt_uuid';

-- ------------------------------------------------------------
-- dbo.dokument_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów dokumentów powiązanych z wierzytelnością', 'SCHEMA', 'dbo', 'TABLE', 'dokument_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu dokumentu (PK)', 'SCHEMA', 'dbo', 'TABLE', 'dokument_typ', 'COLUMN', 'dot_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu dokumentu', 'SCHEMA', 'dbo', 'TABLE', 'dokument_typ', 'COLUMN', 'dot_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'dokument_typ', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'dokument_typ', 'COLUMN', 'dot_uuid';

-- ------------------------------------------------------------
-- dbo.ksiegowanie_konto
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik kont księgowych używanych przy dekretacji (np. kapitał, odsetki)', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_konto';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator konta księgowego (PK)', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_konto', 'COLUMN', 'ksk_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa konta księgowego', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_konto', 'COLUMN', 'ksk_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_konto', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_konto', 'COLUMN', 'ksk_uuid';

-- ------------------------------------------------------------
-- dbo.ksiegowanie_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów księgowań (np. wpłata, korekta)', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu księgowania (PK)', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_typ', 'COLUMN', 'kst_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu księgowania', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_typ', 'COLUMN', 'kst_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_typ', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_typ', 'COLUMN', 'kst_uuid';

-- ------------------------------------------------------------
-- dbo.akcja_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów akcji możliwych do wykonania w ramach sprawy', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu akcji (PK, IDENTITY)', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ', 'COLUMN', 'akt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kod akcji', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ', 'COLUMN', 'akt_kod_akcji';
EXEC sp_addextendedproperty 'MS_Description', 'Wyświetlana nazwa typu akcji', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ', 'COLUMN', 'akt_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Rodzaj kontrolki akcji, do wyboru z listy z dokumentacji', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ', 'COLUMN', 'akt_rodzaj';
EXEC sp_addextendedproperty 'MS_Description', 'Ikonka kontrolki akcji', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ', 'COLUMN', 'akt_ikona';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ', 'COLUMN', 'akt_uuid';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ', 'COLUMN', 'akt_akk_id';
EXEC sp_addextendedproperty 'MS_Description', 'Koszt jednostkowy wykonania akcji; domyślnie 1.00', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ', 'COLUMN', 'akt_koszt';
EXEC sp_addextendedproperty 'MS_Description', 'Flaga określająca czy akcja może być wykonana wielokrotnie (1=tak, 0=nie)', 'SCHEMA', 'dbo', 'TABLE', 'akcja_typ', 'COLUMN', 'akt_wielokrotna';

-- ------------------------------------------------------------
-- dbo.rezultat_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów rezultatów akcji (możliwe wyniki wykonania akcji)', 'SCHEMA', 'dbo', 'TABLE', 'rezultat_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu rezultatu (PK, IDENTITY)', 'SCHEMA', 'dbo', 'TABLE', 'rezultat_typ', 'COLUMN', 'ret_id';
EXEC sp_addextendedproperty 'MS_Description', 'Krótki kod rezultatu (np. OTR, KZM, WYS)', 'SCHEMA', 'dbo', 'TABLE', 'rezultat_typ', 'COLUMN', 'ret_kod';
EXEC sp_addextendedproperty 'MS_Description', 'Wyświetlana nazwa rezultatu', 'SCHEMA', 'dbo', 'TABLE', 'rezultat_typ', 'COLUMN', 'ret_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Flaga określająca czy rezultat kończy akcję (1=tak, 0=nie)', 'SCHEMA', 'dbo', 'TABLE', 'rezultat_typ', 'COLUMN', 'ret_konczy';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'rezultat_typ', 'COLUMN', 'ret_uuid';

-- ------------------------------------------------------------
-- dbo.sprawa_rola_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów ról uczestników sprawy (np. dłużnik główny, poręczyciel)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu roli (PK)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola_typ', 'COLUMN', 'sprt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu roli uczestnika sprawy', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola_typ', 'COLUMN', 'sprt_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola_typ', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola_typ', 'COLUMN', 'sprt_uuid';

-- ------------------------------------------------------------
-- dbo.sprawa_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów spraw (np. windykacyjna, handlowa)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu sprawy (PK)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_typ', 'COLUMN', 'spt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu sprawy', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_typ', 'COLUMN', 'spt_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_typ', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_typ', 'COLUMN', 'spt_uuid';

-- ------------------------------------------------------------
-- dbo.sprawa_etap
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik etapów sprawy (np. sądowy, egzekucyjny, polubowny)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_etap';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator etapu sprawy (PK)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_etap', 'COLUMN', 'spe_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa etapu sprawy', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_etap', 'COLUMN', 'spe_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'FK do typu sprawy (sprawa_typ.spt_id) - określa do jakiego typu sprawy należy etap', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_etap', 'COLUMN', 'spe_spt_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do akcja_typ (akt_id) - opcjonalny typ akcji domyślnie powiązany z etapem sprawy', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_etap', 'COLUMN', 'spe_akt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_etap', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_etap', 'COLUMN', 'spe_uuid';

-- ------------------------------------------------------------
-- dbo.telefon_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów numerów telefonów (stacjonarny, komórkowy, fax)', 'SCHEMA', 'dbo', 'TABLE', 'telefon_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu telefonu (PK; w produkcji kolumna nosi nazwę tnt_id)', 'SCHEMA', 'dbo', 'TABLE', 'telefon_typ', 'COLUMN', 'tt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu telefonu', 'SCHEMA', 'dbo', 'TABLE', 'telefon_typ', 'COLUMN', 'tt_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'telefon_typ', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'telefon_typ', 'COLUMN', 'tt_uuid';

-- ------------------------------------------------------------
-- dbo.waluta
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Kopia referencyjna tabeli walut z produkcji (dm_data_web_pipeline) - wypełniana przed uruchomieniem migracji, nie edytować', 'SCHEMA', 'dbo', 'TABLE', 'waluta';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator waluty (PK, zgodny z produkcją)', 'SCHEMA', 'dbo', 'TABLE', 'waluta', 'COLUMN', 'wa_id';
EXEC sp_addextendedproperty 'MS_Description', 'Pełna nazwa waluty (np. Polski Złoty, Euro)', 'SCHEMA', 'dbo', 'TABLE', 'waluta', 'COLUMN', 'wa_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Skrócona nazwa waluty (kod ISO, np. PLN, EUR)', 'SCHEMA', 'dbo', 'TABLE', 'waluta', 'COLUMN', 'wa_nazwa_skrocona';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'waluta', 'COLUMN', 'wa_uuid';

-- ------------------------------------------------------------
-- dbo.kurs_walut
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Kopia referencyjna kursów walut z produkcji - wypełniana przed uruchomieniem migracji, nie edytować', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator kursu walutowego (PK)', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut', 'COLUMN', 'kw_id';
EXEC sp_addextendedproperty 'MS_Description', 'Oznaczenie tabeli kursów NBP', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut', 'COLUMN', 'kw_tabela';
EXEC sp_addextendedproperty 'MS_Description', 'Pełna nazwa waluty', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut', 'COLUMN', 'kw_waluta';
EXEC sp_addextendedproperty 'MS_Description', 'Kod ISO waluty', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut', 'COLUMN', 'kw_kod';
EXEC sp_addextendedproperty 'MS_Description', 'Numer tabeli kursów NBP', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut', 'COLUMN', 'kw_numer';
EXEC sp_addextendedproperty 'MS_Description', 'Data obowiązywania kursu', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut', 'COLUMN', 'kw_data';
EXEC sp_addextendedproperty 'MS_Description', 'Wartość kursu waluty względem PLN', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut', 'COLUMN', 'kw_wartosc';
EXEC sp_addextendedproperty 'MS_Description', 'Typ kursu', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut', 'COLUMN', 'kw_typ';
EXEC sp_addextendedproperty 'MS_Description', 'FK do tabeli waluta', 'SCHEMA', 'dbo', 'TABLE', 'kurs_walut', 'COLUMN', 'kw_wa_id';

-- ------------------------------------------------------------
-- mapowanie.plec
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Tabela mapowania wartości tekstowych płci z kolumny dluznik.dl_plec na identyfikatory prod tabeli plec', 'SCHEMA', 'mapowanie', 'TABLE', 'plec';
EXEC sp_addextendedproperty 'MS_Description', 'Jednoliterowy kod płci', 'SCHEMA', 'mapowanie', 'TABLE', 'plec', 'COLUMN', 'pm_kod';
EXEC sp_addextendedproperty 'MS_Description', 'FK do tabeli plec', 'SCHEMA', 'mapowanie', 'TABLE', 'plec', 'COLUMN', 'pm_pl_id';
EXEC sp_addextendedproperty 'MS_Description', 'Opis przekazanego kodu', 'SCHEMA', 'mapowanie', 'TABLE', 'plec', 'COLUMN', 'pm_nazwa';

-- ------------------------------------------------------------
-- dbo.kontrahent
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Kontrahenci (wierzyciele pierwotni i pośrednicy) powiązani z umowami', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator kontrahenta (PK)', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent', 'COLUMN', 'ko_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa firmy kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent', 'COLUMN', 'ko_firma';
EXEC sp_addextendedproperty 'MS_Description', 'Numer NIP kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent', 'COLUMN', 'ko_nip';
EXEC sp_addextendedproperty 'MS_Description', 'Numer REGON kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent', 'COLUMN', 'ko_regon';
EXEC sp_addextendedproperty 'MS_Description', 'Numer KRS kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent', 'COLUMN', 'ko_krs';
EXEC sp_addextendedproperty 'MS_Description', 'Numer rachunku bankowego kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent', 'COLUMN', 'ko_nr_rachunku';
EXEC sp_addextendedproperty 'MS_Description', 'Wewnętrzny numer ewidencyjny kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent', 'COLUMN', 'ko_numer';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator z systemu źródłowego - używany do śledzenia migracji', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent', 'COLUMN', 'ko_id_migracja';
EXEC sp_addextendedproperty 'MS_Description', 'Numer klienta nadany przez kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'kontrahent', 'COLUMN', 'ko_numer_klienta';

-- ------------------------------------------------------------
-- dbo.umowa_kontrahent
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Umowy z kontrahentami określające cesje wierzytelności i warunki współpracy', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny umowy kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do tabeli kontrahent - aktualny cesjonariusz wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_ko_id';
EXEC sp_addextendedproperty 'MS_Description', 'Data cesji wierzytelności na aktualnego cesjonariusza', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_data_cesji';
EXEC sp_addextendedproperty 'MS_Description', 'Data od której naliczane są odsetki', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_data_naliczania_odsetek';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa umowy kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Data zawarcia umowy', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_data_zawarcia';
EXEC sp_addextendedproperty 'MS_Description', 'FK do tabeli kontrahent - wierzyciel pierwotny', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_ko_id_wierzyciel_pierwotny';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator umowy z systemu źródłowego - używany do śledzenia migracji', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_ko_id_migracja';
EXEC sp_addextendedproperty 'MS_Description', 'Data przejścia praw', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_data_ppraw';
EXEC sp_addextendedproperty 'MS_Description', 'FK do tabeli kontrahent - wierzyciel wtórny', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_ko_id_wierzyciel_wtorny';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów umów kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'umowa_kontrahent', 'COLUMN', 'uko_ukot_id';

-- ------------------------------------------------------------
-- dbo.atrybut_dziedzina
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik dziedzin atrybutów - określa typ encji, do której przypisywany jest atrybut', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_dziedzina';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny dziedziny atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_dziedzina', 'COLUMN', 'atd_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa dziedziny - określa typ encji, do której należy atrybut', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_dziedzina', 'COLUMN', 'atd_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_dziedzina', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_dziedzina', 'COLUMN', 'atd_uuid';

-- ------------------------------------------------------------
-- dbo.atrybut_rodzaj
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik rodzajów atrybutów - określa typ danych wartości atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_rodzaj';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny rodzaju atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_rodzaj', 'COLUMN', 'atr_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa rodzaju - określa typ danych wartości atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_rodzaj', 'COLUMN', 'atr_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_rodzaj', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_rodzaj', 'COLUMN', 'atr_uuid';

-- ------------------------------------------------------------
-- dbo.atrybut_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów atrybutów definiujący dostępne pola dodatkowe dla encji', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny typu atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_typ', 'COLUMN', 'att_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_typ', 'COLUMN', 'att_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'FK do atrybut_dziedzina (atd_id) - dziedzina (encja docelowa) atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_typ', 'COLUMN', 'att_atd_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do atrybut_rodzaj (atr_id) - rodzaj (typ danych) atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_typ', 'COLUMN', 'att_atr_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_typ', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'atrybut_typ', 'COLUMN', 'att_uuid';

-- ------------------------------------------------------------
-- dbo.dluznik
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Dłużnicy - osoby fizyczne i podmioty gospodarcze powiązane ze sprawami', 'SCHEMA', 'dbo', 'TABLE', 'dluznik';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny dłużnika w stagingu', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kod płci dłużnika - wartość tekstowa mapowana na prod przez mapowanie.plec', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_plec';
EXEC sp_addextendedproperty 'MS_Description', 'Imię dłużnika - wymagane dla wartości dl_dt_id równych (1,2)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_imie';
EXEC sp_addextendedproperty 'MS_Description', 'Drugie imię dłużnika (PII) - opcjonalne, dla wartości dl_dt_id równych (1,2)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_drugie_imie';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwisko dłużnika - wymagane dla wartości dl_dt_id równych (1,2)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_nazwisko';
EXEC sp_addextendedproperty 'MS_Description', 'Numer dowodu osobistego dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_dowod';
EXEC sp_addextendedproperty 'MS_Description', 'Numer paszportu dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_paszport';
EXEC sp_addextendedproperty 'MS_Description', 'Wewnętrzny numer ewidencyjny dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_dluznik';
EXEC sp_addextendedproperty 'MS_Description', 'Numer PESEL dłużnika - wymagany dla wartości dl_dt_id równych (1,2)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_pesel';
EXEC sp_addextendedproperty 'MS_Description', 'Miejsce urodzenia dłużnika (PII) - opcjonalne, najczęściej wypełniane dla osób fizycznych (dl_dt_id 1,2)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_miejsce_urodzenia';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika krajów (dbo.kraj) - kraj pochodzenia/obywatelstwa dłużnika; opcjonalne', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_kraj_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów dłużnika - determinuje wymagane pola: (1,2) osoba fizyczna, (3,4) podmiot gospodarczy', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_dt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Uwagi dotyczące dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_uwagi';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa firmy dłużnika - wymagana dla wartości dl_dt_id równych (3,4)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_firma';
EXEC sp_addextendedproperty 'MS_Description', 'Numer KRS (Krajowy Rejestr Sądowy) - opcjonalny, dla podmiotów gospodarczych (dl_dt_id 3,4)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_krs';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator paczki importu, z której pochodzi rekord', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_import_info';
EXEC sp_addextendedproperty 'MS_Description', 'Numer NIP dłużnika - wymagany dla wartości dl_dt_id równych (3,4)', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_nip';
EXEC sp_addextendedproperty 'MS_Description', 'Numer REGON dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'dl_regon';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'dluznik', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.kraj
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik krajów (kopia referencyjna z prod) - referencjonowany m.in. przez dluznik.dl_kraj_id', 'SCHEMA', 'dbo', 'TABLE', 'kraj';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator kraju (PK; zgodny z prod kraj.kraj_id)', 'SCHEMA', 'dbo', 'TABLE', 'kraj', 'COLUMN', 'kraj_id';
EXEC sp_addextendedproperty 'MS_Description', 'Pełna nazwa kraju w języku polskim', 'SCHEMA', 'dbo', 'TABLE', 'kraj', 'COLUMN', 'kraj_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'kraj', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'kraj', 'COLUMN', 'kraj_uuid';

-- ------------------------------------------------------------
-- dbo.sprawa
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Sprawy windykacyjne powiązane z dłużnikami i wierzytelnościami', 'SCHEMA', 'dbo', 'TABLE', 'sprawa';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny sprawy', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'sp_id';
EXEC sp_addextendedproperty 'MS_Description', 'Numer sprawy nadany w systemie źródłowym', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'sp_numer_sprawy';
EXEC sp_addextendedproperty 'MS_Description', 'Numer rachunku bankowego sprawy - migrowany do tabeli rachunek_bankowy', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'sp_numer_rachunku';
EXEC sp_addextendedproperty 'MS_Description', 'Login pracownika przypisanego do sprawy, opcjonalny', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'sp_pracownik';
EXEC sp_addextendedproperty 'MS_Description', 'FK do etapu sprawy', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'sp_spe_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów spraw', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'sp_spt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator paczki importu, z której pochodzi rekord', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'sp_import_info';
EXEC sp_addextendedproperty 'MS_Description', 'Data obsługi od (start date)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'sp_data_obslugi_od';
EXEC sp_addextendedproperty 'MS_Description', 'Data obsługi do (end date)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'sp_data_obslugi_do';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'sprawa', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.wierzytelnosc
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Wierzytelności powiązane ze sprawami i umowami kontrahentów', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc', 'COLUMN', 'wi_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do sprawy', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc', 'COLUMN', 'wi_sp_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do umowy kontrahenta', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc', 'COLUMN', 'wi_uko_id';
EXEC sp_addextendedproperty 'MS_Description', 'Numer wierzytelności nadany w systemie źródłowym', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc', 'COLUMN', 'wi_numer';
EXEC sp_addextendedproperty 'MS_Description', 'Tytuł wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc', 'COLUMN', 'wi_tytul';
EXEC sp_addextendedproperty 'MS_Description', 'Data zawarcia umowy źródłowej wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc', 'COLUMN', 'wi_data_umowy';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.adres
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Adresy dłużników', 'SCHEMA', 'dbo', 'TABLE', 'adres';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny adresu', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_dl_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa ulicy', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_ulica';
EXEC sp_addextendedproperty 'MS_Description', 'Numer domu', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_nr_domu';
EXEC sp_addextendedproperty 'MS_Description', 'Numer lokalu', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_nr_lokalu';
EXEC sp_addextendedproperty 'MS_Description', 'Kod pocztowy', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_kod';
EXEC sp_addextendedproperty 'MS_Description', 'Miejscowość', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_miejscowosc';
EXEC sp_addextendedproperty 'MS_Description', 'Poczta', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_poczta';
EXEC sp_addextendedproperty 'MS_Description', 'Kraj', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_panstwo';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów adresów', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_at_id';
EXEC sp_addextendedproperty 'MS_Description', 'Uwagi dotyczące adresu', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_uwagi';
EXEC sp_addextendedproperty 'MS_Description', 'Data początku obowiązywania adresu', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_data_od';
EXEC sp_addextendedproperty 'MS_Description', 'Data końca obowiązywania adresu - NULL oznacza adres aktywny', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'ad_data_do';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'adres', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.akcja
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Akcje windykacyjne wykonane w ramach spraw', 'SCHEMA', 'dbo', 'TABLE', 'akcja';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny akcji', 'SCHEMA', 'dbo', 'TABLE', 'akcja', 'COLUMN', 'ak_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do sprawy', 'SCHEMA', 'dbo', 'TABLE', 'akcja', 'COLUMN', 'ak_sp_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów akcji', 'SCHEMA', 'dbo', 'TABLE', 'akcja', 'COLUMN', 'ak_akt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Data zakończenia akcji - mapowana na ak_zakonczono w prod', 'SCHEMA', 'dbo', 'TABLE', 'akcja', 'COLUMN', 'ak_data_zakonczenia';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'akcja', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.atrybut
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Wartości atrybutów dodatkowych przypisanych do encji', 'SCHEMA', 'dbo', 'TABLE', 'atrybut';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut', 'COLUMN', 'at_id';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator encji docelowej - FK do tabeli określonej przez atrybut_typ.att_atd_id', 'SCHEMA', 'dbo', 'TABLE', 'atrybut', 'COLUMN', 'at_ob_id';
EXEC sp_addextendedproperty 'MS_Description', 'Wartość atrybutu', 'SCHEMA', 'dbo', 'TABLE', 'atrybut', 'COLUMN', 'at_wartosc';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów atrybutu - dziedzina i rodzaj dziedziczone z atrybut_typ', 'SCHEMA', 'dbo', 'TABLE', 'atrybut', 'COLUMN', 'at_att_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'atrybut', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.mail
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Adresy e-mail dłużników', 'SCHEMA', 'dbo', 'TABLE', 'mail';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny adresu e-mail', 'SCHEMA', 'dbo', 'TABLE', 'mail', 'COLUMN', 'ma_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'mail', 'COLUMN', 'ma_dl_id';
EXEC sp_addextendedproperty 'MS_Description', 'Adres e-mail dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'mail', 'COLUMN', 'ma_adres_mailowy';
EXEC sp_addextendedproperty 'MS_Description', 'Data początku obowiązywania adresu e-mail', 'SCHEMA', 'dbo', 'TABLE', 'mail', 'COLUMN', 'ma_data_od';
EXEC sp_addextendedproperty 'MS_Description', 'Data końca obowiązywania adresu e-mail - NULL oznacza adres aktywny', 'SCHEMA', 'dbo', 'TABLE', 'mail', 'COLUMN', 'ma_data_do';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'mail', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.telefon
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Numery telefonów dłużników', 'SCHEMA', 'dbo', 'TABLE', 'telefon';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny numeru telefonu', 'SCHEMA', 'dbo', 'TABLE', 'telefon', 'COLUMN', 'tn_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'telefon', 'COLUMN', 'tn_dl_id';
EXEC sp_addextendedproperty 'MS_Description', 'Numer telefonu', 'SCHEMA', 'dbo', 'TABLE', 'telefon', 'COLUMN', 'tn_numer';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów telefonów', 'SCHEMA', 'dbo', 'TABLE', 'telefon', 'COLUMN', 'tn_tt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Data początku obowiązywania numeru telefonu', 'SCHEMA', 'dbo', 'TABLE', 'telefon', 'COLUMN', 'tn_data_od';
EXEC sp_addextendedproperty 'MS_Description', 'Data końca obowiązywania numeru telefonu - NULL oznacza numer aktywny', 'SCHEMA', 'dbo', 'TABLE', 'telefon', 'COLUMN', 'tn_data_do';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'telefon', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.sprawa_rola
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Powiązania dłużników ze sprawami wraz z przypisaną rolą', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny powiązania sprawy z dłużnikiem', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola', 'COLUMN', 'spr_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do sprawy', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola', 'COLUMN', 'spr_sp_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola', 'COLUMN', 'spr_dl_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika ról w sprawie', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola', 'COLUMN', 'spr_sprt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Data początku obowiązywania roli dłużnika w sprawie. Pole opcjonalne - jeśli puste, podstawiana jest data wczytania wiersza do staging (mod_date)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola', 'COLUMN', 'spr_data_od';
EXEC sp_addextendedproperty 'MS_Description', 'Data zakończenia obowiązywania roli dłużnika w sprawie. Pole opcjonalne - jeśli puste, podstawiana jest data sentinel 9999-12-31 (rola otwarta bezterminowo)', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola', 'COLUMN', 'spr_data_do';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'sprawa_rola', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.wierzytelnosc_rola
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Powiązania wierzytelności ze sprawami wraz z przypisaną rolą', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc_rola';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny powiązania wierzytelności ze sprawą', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc_rola', 'COLUMN', 'wir_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do sprawy', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc_rola', 'COLUMN', 'wir_sp_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc_rola', 'COLUMN', 'wir_wi_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika ról wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc_rola', 'COLUMN', 'wir_rl_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wierzytelnosc_rola', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.rezultat
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Rezultaty akcji windykacyjnych', 'SCHEMA', 'dbo', 'TABLE', 'rezultat';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny rezultatu akcji', 'SCHEMA', 'dbo', 'TABLE', 'rezultat', 'COLUMN', 're_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do akcji', 'SCHEMA', 'dbo', 'TABLE', 'rezultat', 'COLUMN', 're_ak_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów rezultatów', 'SCHEMA', 'dbo', 'TABLE', 'rezultat', 'COLUMN', 're_ret_id';
EXEC sp_addextendedproperty 'MS_Description', 'Data wykonania rezultatu', 'SCHEMA', 'dbo', 'TABLE', 'rezultat', 'COLUMN', 're_data_wykonania';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'rezultat', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.dokument
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Dokumenty finansowe powiązane z wierzytelnościami', 'SCHEMA', 'dbo', 'TABLE', 'dokument';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny dokumentu', 'SCHEMA', 'dbo', 'TABLE', 'dokument', 'COLUMN', 'do_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'dokument', 'COLUMN', 'do_wi_id';
EXEC sp_addextendedproperty 'MS_Description', 'Numer dokumentu nadany w systemie źródłowym', 'SCHEMA', 'dbo', 'TABLE', 'dokument', 'COLUMN', 'do_numer_dokumentu';
EXEC sp_addextendedproperty 'MS_Description', 'Data wystawienia dokumentu', 'SCHEMA', 'dbo', 'TABLE', 'dokument', 'COLUMN', 'do_data_wystawienia';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów dokumentów', 'SCHEMA', 'dbo', 'TABLE', 'dokument', 'COLUMN', 'do_dot_id';
EXEC sp_addextendedproperty 'MS_Description', 'Data wymagalności dokumentu', 'SCHEMA', 'dbo', 'TABLE', 'dokument', 'COLUMN', 'do_data_wymagalnosci';
EXEC sp_addextendedproperty 'MS_Description', 'Tytuł dokumentu', 'SCHEMA', 'dbo', 'TABLE', 'dokument', 'COLUMN', 'do_tytul_dokumentu';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'dokument', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.harmonogram
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Harmonogram spłat rat powiązany z wierzytelnościami', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny raty harmonogramu', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram', 'COLUMN', 'hr_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram', 'COLUMN', 'hr_wi_id';
EXEC sp_addextendedproperty 'MS_Description', 'Typ harmonogramu', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram', 'COLUMN', 'hr_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Data płatności raty', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram', 'COLUMN', 'hr_data_raty';
EXEC sp_addextendedproperty 'MS_Description', 'Numer kolejny raty', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram', 'COLUMN', 'hr_numer_raty';
EXEC sp_addextendedproperty 'MS_Description', 'Łączna kwota raty', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram', 'COLUMN', 'hr_kwota_raty';
EXEC sp_addextendedproperty 'MS_Description', 'Część kapitałowa raty', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram', 'COLUMN', 'hr_kwota_kapitalu';
EXEC sp_addextendedproperty 'MS_Description', 'Część odsetkowa raty', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram', 'COLUMN', 'hr_kwota_odsetek';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'harmonogram', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.ksiegowanie
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Nagłówki księgowań finansowych', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny księgowania', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie', 'COLUMN', 'ks_id';
EXEC sp_addextendedproperty 'MS_Description', 'Data zaksięgowania operacji', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie', 'COLUMN', 'ks_data_ksiegowania';
EXEC sp_addextendedproperty 'MS_Description', 'Data operacji finansowej', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie', 'COLUMN', 'ks_data_operacji';
EXEC sp_addextendedproperty 'MS_Description', 'Uwagi dotyczące księgowania', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie', 'COLUMN', 'ks_uwagi';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika typów księgowań', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie', 'COLUMN', 'ks_kst_id';
EXEC sp_addextendedproperty 'MS_Description', 'Flaga: księgowanie pierwotne (1) vs. korygujące (0)', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie', 'COLUMN', 'ks_pierwotne';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.ksiegowanie_dekret
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Dekrety księgowań - pozycje szczegółowe przypisane do dokumentów', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny dekretu księgowania', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do księgowania', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_ks_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do dokumentu', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_do_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota dekretu w walucie dokumentu', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_kwota';
EXEC sp_addextendedproperty 'MS_Description', 'Data od której naliczane są odsetki dla dekretu', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_data_naliczania_odsetek';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika kont księgowych', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_ksk_id';
EXEC sp_addextendedproperty 'MS_Description', 'Uwagi dotyczące dekretu', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_uwagi';
EXEC sp_addextendedproperty 'MS_Description', 'FK do sprawy', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_sp_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kurs wymiany do waluty bazowej', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_kurs_bazowy';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota Winien w walucie wyceny', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_kwota_wn_wyceny';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota Ma w walucie wyceny', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_kwota_ma_wyceny';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika walut - waluta wyceny', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_wa_id_wyceny';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota Winien w walucie bazowej', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_kwota_wn_bazowa';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota Ma w walucie bazowej', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_kwota_ma_bazowa';
EXEC sp_addextendedproperty 'MS_Description', 'FK do słownika walut - waluta dekretu', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_wa_id';
EXEC sp_addextendedproperty 'MS_Description', 'Data wymagalności dekretu - jeśli brak dokumentu, ustawiany na sentinel 9999-12-31', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_data_wymagalnosci';
EXEC sp_addextendedproperty 'MS_Description', 'FK do subkonta konta księgowego (ksiegowanie_konto_subkonto)', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'ksd_ksksub_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'ksiegowanie_dekret', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.operacja
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Operacje finansowe z systemu źródłowego - dane surowe do mapowania na księgowania', 'SCHEMA', 'dbo', 'TABLE', 'operacja';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny operacji finansowej', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_wi_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kod waluty operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_waluta';
EXEC sp_addextendedproperty 'MS_Description', 'Kod rejestru finansowego', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_rejestr_kod';
EXEC sp_addextendedproperty 'MS_Description', 'Typ dekretu operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_typ_dekretu';
EXEC sp_addextendedproperty 'MS_Description', 'Opis dekretu operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_opis_dekretu';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu dokumentu w systemie źródłowym', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_dokument_typ_prod_id';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator podtypu dokumentu w systemie źródłowym', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_dokument_podtyp_prod_id';
EXEC sp_addextendedproperty 'MS_Description', 'Opis typu dokumentu w systemie źródłowym', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_dokument_typ_prod_opis';
EXEC sp_addextendedproperty 'MS_Description', 'Opis podtypu dokumentu w systemie źródłowym', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_dokument_podtyp_prod_opis';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator dokumentu w systemie źródłowym', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_dokument_prod_id';
EXEC sp_addextendedproperty 'MS_Description', 'Słowny opis operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_opis_slowny';
EXEC sp_addextendedproperty 'MS_Description', 'Opis techniczny operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_opis';
EXEC sp_addextendedproperty 'MS_Description', 'Strona dekretu - określa kierunek operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_strona';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota operacji w walucie oryginalnej', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota dekretu', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_dekretu';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota kapitału', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_kapitalu';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota odsetek', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_odsetek';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota odsetek karnych', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kowta_odsetek_karnych';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota opłaty', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_oplaty';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota prowizji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_prowizji';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota operacji przeliczona na PLN', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_w_pln';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota dekretu przeliczona na PLN', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_dekretu_w_pln';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota kapitału przeliczona na PLN', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_kapitalu_w_pln';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota odsetek przeliczona na PLN', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_odsetek_w_pln';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota odsetek karnych przeliczona na PLN', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kowta_odsetek_karnych_w_pln';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota opłaty przeliczona na PLN', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_oplaty_w_pln';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota prowizji przeliczona na PLN', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_kwota_prowizji_w_pln';
EXEC sp_addextendedproperty 'MS_Description', 'Data waluty operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_data_waluty';
EXEC sp_addextendedproperty 'MS_Description', 'Data danych źródłowych', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_data_danych';
EXEC sp_addextendedproperty 'MS_Description', 'Data dekretu', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_data_dekretu';
EXEC sp_addextendedproperty 'MS_Description', 'Data zaksięgowania operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_data_ksiegowania';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa beneficjenta operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_beneficjent_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa zleceniodawcy operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_remitter_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Numer konta bankowego operacji', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_konto';
EXEC sp_addextendedproperty 'MS_Description', 'FK do dokumentu powiązanego z operacją', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'oper_do_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'operacja', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.zabezpieczenie
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Zabezpieczenia wierzytelności przypisane do dłużników', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_wi_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do dłużnika', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_dl_id';
EXEC sp_addextendedproperty 'MS_Description', 'Relacja zabezpieczenia do wierzytelności', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_relacja';
EXEC sp_addextendedproperty 'MS_Description', 'Opis zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_opis';
EXEC sp_addextendedproperty 'MS_Description', 'Procent zmiany rezerwy', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_procent_zm_rez';
EXEC sp_addextendedproperty 'MS_Description', 'Klasyfikacja zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_klasyfikacja';
EXEC sp_addextendedproperty 'MS_Description', 'Kod rodzaju zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_rodzaj';
EXEC sp_addextendedproperty 'MS_Description', 'Opis rodzaju zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_rodzaj_opis';
EXEC sp_addextendedproperty 'MS_Description', 'Typ zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_typ_zabezpieczenia';
EXEC sp_addextendedproperty 'MS_Description', 'Wartość zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_wartosc_zab';
EXEC sp_addextendedproperty 'MS_Description', 'Wartość zmiany rezerwy', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_wartosc_zm_rez';
EXEC sp_addextendedproperty 'MS_Description', 'Podstawa wyliczenia zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_podstawa';
EXEC sp_addextendedproperty 'MS_Description', 'Data ustanowienia zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_data_ustanowienia';
EXEC sp_addextendedproperty 'MS_Description', 'Data zwolnienia zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_data_zwolnienia';
EXEC sp_addextendedproperty 'MS_Description', 'Data ważności zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_data_waznosci';
EXEC sp_addextendedproperty 'MS_Description', 'Wartość rynkowa zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_wartosc_rynkowa';
EXEC sp_addextendedproperty 'MS_Description', 'Waluta wyceny zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_waluta_wyceny';
EXEC sp_addextendedproperty 'MS_Description', 'Wartość bankowa hipoteki', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_wartosc_bank_hip';
EXEC sp_addextendedproperty 'MS_Description', 'Waluta wpisu do księgi wieczystej', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_waluta_kw';
EXEC sp_addextendedproperty 'MS_Description', 'Kwota wpisu do księgi wieczystej', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_wpis_kw';
EXEC sp_addextendedproperty 'MS_Description', 'Priorytet zabezpieczenia', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'zab_priorytet';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'zabezpieczenie', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.zrodlo_pochodzenia_informacji
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik źródeł pochodzenia informacji (skąd w systemie pojawił się dany wpis, np. import, użytkownik, integracja)', 'SCHEMA', 'dbo', 'TABLE', 'zrodlo_pochodzenia_informacji';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator źródła pochodzenia informacji (PK)', 'SCHEMA', 'dbo', 'TABLE', 'zrodlo_pochodzenia_informacji', 'COLUMN', 'zpi_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa źródła pochodzenia informacji', 'SCHEMA', 'dbo', 'TABLE', 'zrodlo_pochodzenia_informacji', 'COLUMN', 'zpi_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Opis źródła pochodzenia informacji (opcjonalny)', 'SCHEMA', 'dbo', 'TABLE', 'zrodlo_pochodzenia_informacji', 'COLUMN', 'zpi_opis';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz naturalny UUID używany do MERGE między stagingiem a produkcją', 'SCHEMA', 'dbo', 'TABLE', 'zrodlo_pochodzenia_informacji', 'COLUMN', 'zpi_uuid';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'zrodlo_pochodzenia_informacji', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - pole mapowania staging→prod, uzupełniane automatycznie po MERGE; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'zrodlo_pochodzenia_informacji', 'COLUMN', 'zpi_ext_id';

-- ------------------------------------------------------------
-- dbo.wlasciwosc_typ_walidacji
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów walidacji stosowanych dla właściwości (np. liczba, tekst, data, wartość z listy)', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_walidacji';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu walidacji właściwości (PK)', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_walidacji', 'COLUMN', 'wtw_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu walidacji właściwości', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_walidacji', 'COLUMN', 'wtw_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz naturalny UUID używany do MERGE między stagingiem a produkcją', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_walidacji', 'COLUMN', 'wtw_uuid';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_walidacji', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - pole mapowania staging→prod, uzupełniane automatycznie po MERGE; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_walidacji', 'COLUMN', 'wtw_ext_id';

-- ------------------------------------------------------------
-- dbo.wlasciwosc_dziedzina
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik dziedzin właściwości - określa, do jakiej encji odnosi się właściwość (dłużnik, sprawa, adres, e-mail, telefon itd.)', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dziedzina';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator dziedziny właściwości (PK)', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dziedzina', 'COLUMN', 'wdzi_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa dziedziny właściwości', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dziedzina', 'COLUMN', 'wdzi_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz naturalny UUID używany do MERGE między stagingiem a produkcją', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dziedzina', 'COLUMN', 'wdzi_uuid';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dziedzina', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - pole mapowania staging→prod, uzupełniane automatycznie po MERGE; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dziedzina', 'COLUMN', 'wdzi_ext_id';

-- ------------------------------------------------------------
-- dbo.wlasciwosc_podtyp
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik podtypów właściwości - doprecyzowuje rodzaj właściwości w ramach dziedziny', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_podtyp';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator podtypu właściwości (PK)', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_podtyp', 'COLUMN', 'wpt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa podtypu właściwości', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_podtyp', 'COLUMN', 'wpt_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz naturalny UUID używany do MERGE między stagingiem a produkcją', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_podtyp', 'COLUMN', 'wpt_uuid';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_podtyp', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - pole mapowania staging→prod, uzupełniane automatycznie po MERGE; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_podtyp', 'COLUMN', 'wpt_ext_id';

-- ------------------------------------------------------------
-- dbo.wlasciwosc_typ
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Słownik typów właściwości - definiuje nazwane właściwości i przypisuje im typ walidacji', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator typu właściwości (PK)', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ', 'COLUMN', 'wt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Nazwa typu właściwości', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ', 'COLUMN', 'wt_nazwa';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wlasciwosc_typ_walidacji (wtw_id) - typ walidacji stosowanej dla tej właściwości', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ', 'COLUMN', 'wt_wtw_id';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz naturalny UUID używany do MERGE między stagingiem a produkcją', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ', 'COLUMN', 'wt_uuid';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - pole mapowania staging→prod, uzupełniane automatycznie po MERGE; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ', 'COLUMN', 'wt_ext_id';

-- ------------------------------------------------------------
-- dbo.wlasciwosc_typ_podtyp_dziedzina
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Tabela łącząca typ właściwości z dziedziną i podtypem - definiuje, w jakich dziedzinach i z jakimi podtypami dana właściwość może wystąpić', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_podtyp_dziedzina';
EXEC sp_addextendedproperty 'MS_Description', 'Identyfikator rekordu łączącego (PK)', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_podtyp_dziedzina', 'COLUMN', 'wtpd_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wlasciwosc_typ (wt_id) - typ właściwości', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_podtyp_dziedzina', 'COLUMN', 'wtpd_wt_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wlasciwosc_dziedzina (wdzi_id) - dziedzina, w której właściwość występuje', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_podtyp_dziedzina', 'COLUMN', 'wtpd_dzi_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wlasciwosc_podtyp (wpt_id) - podtyp doprecyzowujący właściwość', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_podtyp_dziedzina', 'COLUMN', 'wtpd_wpt_id';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz naturalny UUID używany do MERGE między stagingiem a produkcją', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_podtyp_dziedzina', 'COLUMN', 'wtpd_uuid';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_podtyp_dziedzina', 'COLUMN', 'mod_date';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - pole mapowania staging→prod, uzupełniane automatycznie po MERGE; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_typ_podtyp_dziedzina', 'COLUMN', 'wtpd_ext_id';

-- ------------------------------------------------------------
-- dbo.wlasciwosc
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Wartości właściwości przypisanych do encji biznesowych (dłużnik, adres, e-mail, telefon) - obsługiwane zbiorczo przez usp_migrate_wlasciwosc_domain, iteracja wybiera dziedzinę przez wlasciwosc_typ_podtyp_dziedzina', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny właściwości w stagingu', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc', 'COLUMN', 'wl_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do konfiguracji typ/podtyp/dziedzina (wlasciwosc_typ_podtyp_dziedzina.wtpd_id) - determinuje dziedzinę (dluznik/adres/mail/telefon)', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc', 'COLUMN', 'wl_wtpd_id';
EXEC sp_addextendedproperty 'MS_Description', 'Data początku obowiązywania właściwości', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc', 'COLUMN', 'wl_aktywny_od';
EXEC sp_addextendedproperty 'MS_Description', 'Data końca obowiązywania właściwości - NULL oznacza obowiązywanie bezterminowe', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc', 'COLUMN', 'wl_aktywny_do';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.wlasciwosc_dluznik
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Tabela łącząca wlasciwosc (dziedzina=4, dluznik) z konkretnym dłużnikiem - ładowana w iter2 razem z rodzicem wlasciwosc', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dluznik';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny wiersza łączącego', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dluznik', 'COLUMN', 'wd_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wlasciwosc (wl_id) - konkretna właściwość przypisana dłużnikowi', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dluznik', 'COLUMN', 'wd_wl_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do dluznik (dl_id) - dłużnik, któremu przypisano właściwość', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dluznik', 'COLUMN', 'wd_dl_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_dluznik', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.wlasciwosc_adres
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Tabela łącząca wlasciwosc (dziedzina=2, adres) z konkretnym adresem - ładowana w iter3 razem z rodzicem wlasciwosc', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_adres';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny wiersza łączącego', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_adres', 'COLUMN', 'wa_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wlasciwosc (wl_id) - konkretna właściwość przypisana adresowi', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_adres', 'COLUMN', 'wa_wl_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do adres (ad_id) - adres, któremu przypisano właściwość', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_adres', 'COLUMN', 'wa_ad_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_adres', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.wlasciwosc_email
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Tabela łącząca wlasciwosc (dziedzina=3, email) z konkretnym adresem e-mail - ładowana w iter3 razem z rodzicem wlasciwosc', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_email';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny wiersza łączącego', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_email', 'COLUMN', 'we_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wlasciwosc (wl_id) - konkretna właściwość przypisana adresowi e-mail', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_email', 'COLUMN', 'we_wl_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do mail (ma_id) - adres e-mail, któremu przypisano właściwość', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_email', 'COLUMN', 'we_ma_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_email', 'COLUMN', 'mod_date';

-- ------------------------------------------------------------
-- dbo.wlasciwosc_telefon
-- ------------------------------------------------------------
EXEC sp_addextendedproperty 'MS_Description', 'Tabela łącząca wlasciwosc (dziedzina=1, telefon) z konkretnym numerem telefonu - ładowana w iter3 razem z rodzicem wlasciwosc', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_telefon';
EXEC sp_addextendedproperty 'MS_Description', 'Klucz główny wiersza łączącego', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_telefon', 'COLUMN', 'wt_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do wlasciwosc (wl_id) - konkretna właściwość przypisana numerowi telefonu', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_telefon', 'COLUMN', 'wt_wl_id';
EXEC sp_addextendedproperty 'MS_Description', 'FK do telefon (tn_id) - numer telefonu, któremu przypisano właściwość', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_telefon', 'COLUMN', 'wt_tn_id';
EXEC sp_addextendedproperty 'MS_Description', 'Kolumna techniczna - obsługiwana triggerami insert; nie wypełniać', 'SCHEMA', 'dbo', 'TABLE', 'wlasciwosc_telefon', 'COLUMN', 'mod_date';
