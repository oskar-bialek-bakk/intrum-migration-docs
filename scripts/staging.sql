-- ============================================================
-- Database
-- ============================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'dm_staging')
    CREATE DATABASE dm_staging COLLATE Polish_CI_AI;
GO

USE dm_staging;
GO

-- ============================================================
-- Schemas
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'mapowanie')
    EXEC('CREATE SCHEMA mapowanie AUTHORIZATION dbo');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'log')
    EXEC('CREATE SCHEMA log AUTHORIZATION dbo');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'configuration')
    EXEC('CREATE SCHEMA configuration AUTHORIZATION dbo');
GO

-- ============================================================
-- Drop existing tables (reverse dependency order)
-- ============================================================

-- Drop all FK constraints first so DROP TABLE succeeds in any order
DECLARE @dropfk NVARCHAR(MAX) = N'';
SELECT @dropfk = @dropfk +
    'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name) +
    ' DROP CONSTRAINT ' + QUOTENAME(fk.name) + '; '
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
WHERE t.is_ms_shipped = 0;
IF LEN(@dropfk) > 0 EXEC sp_executesql @dropfk;

DROP TABLE IF EXISTS dbo.zabezpieczenie;
DROP TABLE IF EXISTS dbo.wierzytelnosc_rola;
DROP TABLE IF EXISTS dbo.telefon;
DROP TABLE IF EXISTS dbo.sprawa_rola;
DROP TABLE IF EXISTS dbo.operacja;
DROP TABLE IF EXISTS dbo.mail;
DROP TABLE IF EXISTS dbo.ksiegowanie_dekret;
DROP TABLE IF EXISTS dbo.harmonogram;
DROP TABLE IF EXISTS dbo.dokument;
DROP TABLE IF EXISTS dbo.rezultat;
DROP TABLE IF EXISTS dbo.atrybut;
DROP TABLE IF EXISTS dbo.wlasciwosc_telefon;
DROP TABLE IF EXISTS dbo.wlasciwosc_email;
DROP TABLE IF EXISTS dbo.wlasciwosc_adres;
DROP TABLE IF EXISTS dbo.wlasciwosc_dluznik;
DROP TABLE IF EXISTS dbo.wlasciwosc;
DROP TABLE IF EXISTS dbo.wlasciwosc_typ_podtyp_dziedzina;
DROP TABLE IF EXISTS dbo.wlasciwosc_typ;
DROP TABLE IF EXISTS dbo.wlasciwosc_podtyp;
DROP TABLE IF EXISTS dbo.wlasciwosc_dziedzina;
DROP TABLE IF EXISTS dbo.wlasciwosc_typ_walidacji;
DROP TABLE IF EXISTS dbo.zrodlo_pochodzenia_informacji;
DROP TABLE IF EXISTS dbo.akcja;
DROP TABLE IF EXISTS dbo.adres;
DROP TABLE IF EXISTS dbo.ksiegowanie;
DROP TABLE IF EXISTS dbo.wierzytelnosc;
DROP TABLE IF EXISTS dbo.umowa_kontrahent;
DROP TABLE IF EXISTS dbo.kontrahent;
DROP TABLE IF EXISTS dbo.sprawa;
DROP TABLE IF EXISTS dbo.dluznik;
DROP TABLE IF EXISTS dbo.atrybut_typ;
DROP TABLE IF EXISTS dbo.atrybut_rodzaj;
DROP TABLE IF EXISTS dbo.atrybut_dziedzina;
DROP TABLE IF EXISTS dbo.telefon_typ;
DROP TABLE IF EXISTS dbo.sprawa_rola_typ;
DROP TABLE IF EXISTS dbo.sprawa_etap;
DROP TABLE IF EXISTS dbo.sprawa_typ;
DROP TABLE IF EXISTS dbo.ksiegowanie_typ;
DROP TABLE IF EXISTS dbo.ksiegowanie_konto_subkonto;
DROP TABLE IF EXISTS dbo.ksiegowanie_konto;
DROP TABLE IF EXISTS dbo.dokument_odsetki_przerwy;
DROP TABLE IF EXISTS dbo.dokument_odsetki_przerwy_typ;
DROP TABLE IF EXISTS dbo.dokument_typ;
DROP TABLE IF EXISTS dbo.kurs_walut;
DROP TABLE IF EXISTS dbo.waluta;
DROP TABLE IF EXISTS mapowanie.dodane_dokumenty;
DROP TABLE IF EXISTS mapowanie.dodane_wierzytelnosci;
DROP TABLE IF EXISTS mapowanie.dodani_dluznicy;
DROP TABLE IF EXISTS mapowanie.dodane_sprawy;
DROP TABLE IF EXISTS mapowanie.plec;
DROP TABLE IF EXISTS dbo.dluznik_typ;
DROP TABLE IF EXISTS dbo.adres_typ;
DROP TABLE IF EXISTS dbo.rezultat_typ;
DROP TABLE IF EXISTS dbo.akcja_typ;

-- logowanie and configuration schema cleanup
DROP TABLE IF EXISTS log.prod_snapshot;
DROP TABLE IF EXISTS log.configuration;
DROP TABLE IF EXISTS log.validation_result;
DROP TABLE IF EXISTS log.postmigration_check;
DROP TABLE IF EXISTS log.migration_error;
DROP TABLE IF EXISTS log.migration_table_summary;
DROP TABLE IF EXISTS log.migration_run;
DROP TABLE IF EXISTS configuration.threshold_config;
GO

-- ============================================================
-- Lookup / reference tables (no FK dependencies)
-- ============================================================

-- Reference copy from dm_data_web_pipeline.dbo.waluta (populated before migration run)
CREATE TABLE dbo.waluta (
    wa_id               INT          NOT NULL,
    wa_nazwa            VARCHAR(100) NULL,
    wa_nazwa_skrocona   VARCHAR(50)  NULL,
    wa_uuid             VARCHAR(50)  NULL,
    CONSTRAINT PK_waluta PRIMARY KEY (wa_id)
);

-- Reference copy from dm_data_web_pipeline.dbo.kurs_walut (populated before migration run)
CREATE TABLE dbo.kurs_walut (
    kw_id       INT              NOT NULL,
    kw_tabela   VARCHAR(5)       NULL,
    kw_waluta   VARCHAR(MAX)     NOT NULL,
    kw_kod      VARCHAR(5)       NOT NULL,
    kw_numer    VARCHAR(MAX)     NOT NULL,
    kw_data     DATETIME         NOT NULL,
    kw_wartosc  DECIMAL(18,4)    NOT NULL,
    kw_typ      VARCHAR(1)       NULL,
    kw_wa_id    INT              NULL,
    CONSTRAINT PK_kurs_walut PRIMARY KEY (kw_id),
    CONSTRAINT FK_kurs_walut_waluta FOREIGN KEY (kw_wa_id) REFERENCES dbo.waluta (wa_id)
);

CREATE TABLE mapowanie.plec (
    pm_kod      VARCHAR(1)   NOT NULL,  -- 'K'=kobieta, 'M'=mezczyzna, 'B'=brak danych
    pm_pl_id    INT          NOT NULL,  -- references prod dbo.plec.pl_id
    pm_nazwa    VARCHAR(50)  NULL,
    CONSTRAINT PK_mapowanie_plec PRIMARY KEY (pm_kod)
);

-- Persistent staging→prod ID mapping tables (populated by iter2/iter4 via OUTPUT)
CREATE TABLE mapowanie.dodani_dluznicy (
    staging_dl_id INT NOT NULL,
    prod_dl_id    INT NOT NULL,
    CONSTRAINT PK_dodani_dluznicy PRIMARY KEY (staging_dl_id)
);

CREATE TABLE mapowanie.dodane_sprawy (
    staging_sp_id INT NOT NULL,
    prod_sp_id    INT NOT NULL,
    CONSTRAINT PK_dodane_sprawy PRIMARY KEY (staging_sp_id)
);

CREATE TABLE mapowanie.dodane_wierzytelnosci (
    staging_wi_id INT NOT NULL,
    prod_wi_id    INT NOT NULL,
    CONSTRAINT PK_dodane_wierzytelnosci PRIMARY KEY (staging_wi_id)
);

CREATE TABLE mapowanie.dodane_dokumenty (
    staging_do_id INT NOT NULL,
    prod_do_id    INT NOT NULL,
    CONSTRAINT PK_dodane_dokumenty PRIMARY KEY (staging_do_id)
);

CREATE TABLE dbo.adres_typ (
    at_id       INT              NOT NULL,
    at_nazwa    VARCHAR(50)      NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    at_uuid     UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_adres_typ PRIMARY KEY (at_id)
);

CREATE TABLE dbo.dluznik_typ (
    dt_id       INT              NOT NULL,
    dt_nazwa    VARCHAR(50)      NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    dt_uuid     UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_dluznik_typ PRIMARY KEY (dt_id)
);

CREATE TABLE dbo.dokument_typ (
    dot_id      INT              NOT NULL,
    dot_nazwa   VARCHAR(50)      NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    dot_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_dokument_typ PRIMARY KEY (dot_id)
);

CREATE TABLE dbo.ksiegowanie_konto (
    ksk_id      INT              NOT NULL,
    ksk_nazwa   VARCHAR(50)      NOT NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    ksk_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_ksiegowanie_konto PRIMARY KEY (ksk_id)
);

-- Reference copy from dm_data_web_pipeline.dbo.ksiegowanie_konto_subkonto (populated before migration run)
CREATE TABLE dbo.ksiegowanie_konto_subkonto (
    ksksub_id    INT          NOT NULL,
    ksksub_ksk_id INT         NOT NULL,
    ksksub_nazwa  VARCHAR(400) NOT NULL,
    ksksub_etap   INT          NULL,
    ksksub_uuid   VARCHAR(50)  NULL,
    CONSTRAINT PK_ksiegowanie_konto_subkonto PRIMARY KEY (ksksub_id),
    CONSTRAINT FK_ksksub_ksk FOREIGN KEY (ksksub_ksk_id) REFERENCES dbo.ksiegowanie_konto (ksk_id)
);

CREATE TABLE dbo.ksiegowanie_typ (
    kst_id      INT              NOT NULL,
    kst_nazwa   VARCHAR(50)      NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    kst_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_ksiegowanie_typ PRIMARY KEY (kst_id)
);

CREATE TABLE dbo.akcja_typ (
    akt_id          INT             NOT NULL IDENTITY(1,1),
    akt_kod_akcji   VARCHAR(50)     NULL,
    akt_nazwa       VARCHAR(200)    NULL,
    akt_rodzaj      VARCHAR(50)     NULL,   -- set manually per row before migration
    akt_ikona       VARCHAR(100)    NULL,   -- set manually per row before migration
    akt_uuid        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    akt_akk_id      INT             NOT NULL DEFAULT 1,
    akt_koszt       DECIMAL(18,2)   NOT NULL DEFAULT 1.00,
    akt_wielokrotna BIT             NOT NULL DEFAULT 1,
    CONSTRAINT PK_akcja_typ PRIMARY KEY (akt_id)
);

CREATE TABLE dbo.rezultat_typ (
    ret_id      INT             NOT NULL IDENTITY(1,1),
    ret_kod     VARCHAR(50)     NULL,
    ret_nazwa   VARCHAR(200)    NULL,
    ret_konczy  BIT             NOT NULL DEFAULT 0,  -- set manually per row before migration
    ret_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_rezultat_typ PRIMARY KEY (ret_id)
);

CREATE TABLE dbo.kontrahent (
    ko_id               INT          NOT NULL,
    ko_firma            VARCHAR(200) NULL,
    ko_nip              VARCHAR(20)  NULL,
    ko_regon            VARCHAR(20)  NULL,
    ko_krs              VARCHAR(20)  NULL,
    ko_nr_rachunku      VARCHAR(50)  NULL,
    ko_numer            VARCHAR(50)  NULL,
    ko_id_migracja      INT          NULL,
    ko_numer_klienta    VARCHAR(50)  NULL,
    CONSTRAINT PK_kontrahent PRIMARY KEY (ko_id)
);

CREATE TABLE dbo.umowa_kontrahent (
    uko_id                          INT          NOT NULL,
    uko_ko_id                       INT          NOT NULL,
    uko_data_cesji                  DATE         NULL,
    uko_data_naliczania_odsetek     DATE         NULL,
    uko_nazwa                       VARCHAR(200) NULL,
    uko_data_zawarcia               DATE         NULL,
    uko_ko_id_wierzyciel_pierwotny  INT          NULL,
    uko_ko_id_migracja              INT          NULL,
    uko_data_ppraw                  DATE         NULL,
    uko_ko_id_wierzyciel_wtorny     INT          NULL,
    uko_ukot_id                     INT          NULL,
    CONSTRAINT PK_umowa_kontrahent PRIMARY KEY (uko_id),
    CONSTRAINT FK_umowa_kontrahent_kontrahent FOREIGN KEY (uko_ko_id) REFERENCES dbo.kontrahent (ko_id)
);

CREATE TABLE dbo.sprawa_rola_typ (
    sprt_id     INT              NOT NULL,
    sprt_nazwa  VARCHAR(50)      NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    sprt_uuid   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_sprawa_rola_typ PRIMARY KEY (sprt_id)
);

CREATE TABLE dbo.sprawa_typ (
    spt_id      INT              NOT NULL,
    spt_nazwa   VARCHAR(50)      NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    spt_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_sprawa_typ PRIMARY KEY (spt_id)
);

CREATE TABLE dbo.sprawa_etap (
    spe_id      INT              NOT NULL,
    spe_nazwa   VARCHAR(50)      NULL,
    spe_spt_id  INT              NOT NULL,
    spe_akt_id  INT              NULL,
    spe_ext_id  INT              NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    spe_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_sprawa_etap PRIMARY KEY (spe_id),
    CONSTRAINT FK_sprawa_etap_sprawa_typ FOREIGN KEY (spe_spt_id) REFERENCES dbo.sprawa_typ (spt_id),
    CONSTRAINT FK_sprawa_etap_akcja_typ  FOREIGN KEY (spe_akt_id) REFERENCES dbo.akcja_typ  (akt_id)
);

CREATE TABLE dbo.telefon_typ (
    tt_id       INT              NOT NULL,
    tt_nazwa    VARCHAR(50)      NOT NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    tt_uuid     UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_telefon_typ PRIMARY KEY (tt_id)
);

CREATE TABLE dbo.atrybut_dziedzina (
    atd_id      INT              NOT NULL,
    atd_nazwa   VARCHAR(4000)    NOT NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    atd_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_atrybut_dziedzina PRIMARY KEY (atd_id)
);

CREATE TABLE dbo.atrybut_rodzaj (
    atr_id      INT              NOT NULL,
    atr_nazwa   VARCHAR(4000)    NOT NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    atr_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_atrybut_rodzaj PRIMARY KEY (atr_id)
);

CREATE TABLE dbo.atrybut_typ (
    att_id      INT              NOT NULL,
    att_nazwa   VARCHAR(4000)    NOT NULL,
    att_atd_id  INT              NOT NULL,
    att_atr_id  INT              NOT NULL,
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    att_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_atrybut_typ PRIMARY KEY (att_id),
    CONSTRAINT FK_atrybut_typ_dziedzina FOREIGN KEY (att_atd_id) REFERENCES dbo.atrybut_dziedzina (atd_id),
    CONSTRAINT FK_atrybut_typ_rodzaj    FOREIGN KEY (att_atr_id) REFERENCES dbo.atrybut_rodzaj    (atr_id)
);

-- ============================================================
-- Wlasciwosc lookup tables (copied from prod, no IDENTITY)
-- ============================================================

CREATE TABLE dbo.zrodlo_pochodzenia_informacji (
    zpi_id      INT              NOT NULL,
    zpi_nazwa   NVARCHAR(255)    NOT NULL,
    zpi_opis    NVARCHAR(2000)   NULL,
    zpi_uuid    VARCHAR(50)      NOT NULL DEFAULT CAST(NEWID() AS VARCHAR(50)),
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_zrodlo_pochodzenia_informacji PRIMARY KEY (zpi_id)
);

CREATE TABLE dbo.wlasciwosc_typ_walidacji (
    wtw_id      INT              NOT NULL,
    wtw_nazwa   VARCHAR(50)      NOT NULL,
    wtw_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc_typ_walidacji PRIMARY KEY (wtw_id)
);

CREATE TABLE dbo.wlasciwosc_dziedzina (
    wdzi_id     INT              NOT NULL,
    wdzi_nazwa  VARCHAR(100)     NOT NULL,
    wdzi_uuid   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc_dziedzina PRIMARY KEY (wdzi_id)
);

CREATE TABLE dbo.wlasciwosc_podtyp (
    wpt_id      INT              NOT NULL,
    wpt_nazwa   VARCHAR(255)     NOT NULL,
    wpt_uuid    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc_podtyp PRIMARY KEY (wpt_id)
);

CREATE TABLE dbo.wlasciwosc_typ (
    wt_id       INT              NOT NULL,
    wt_nazwa    VARCHAR(255)     NOT NULL,
    wt_wtw_id   INT              NOT NULL,
    wt_uuid     UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc_typ PRIMARY KEY (wt_id),
    CONSTRAINT FK_wlasciwosc_typ_walidacji FOREIGN KEY (wt_wtw_id) REFERENCES dbo.wlasciwosc_typ_walidacji (wtw_id)
);

CREATE TABLE dbo.wlasciwosc_typ_podtyp_dziedzina (
    wtpd_id     INT              NOT NULL,
    wtpd_wt_id  INT              NOT NULL,
    wtpd_dzi_id INT              NOT NULL,
    wtpd_wpt_id INT              NOT NULL,
    wtpd_uuid   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    mod_date    DATETIME         NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc_typ_podtyp_dziedzina PRIMARY KEY (wtpd_id),
    CONSTRAINT FK_wtpd_wt   FOREIGN KEY (wtpd_wt_id)  REFERENCES dbo.wlasciwosc_typ  (wt_id),
    CONSTRAINT FK_wtpd_dzi  FOREIGN KEY (wtpd_dzi_id)  REFERENCES dbo.wlasciwosc_dziedzina (wdzi_id),
    CONSTRAINT FK_wtpd_wpt  FOREIGN KEY (wtpd_wpt_id)  REFERENCES dbo.wlasciwosc_podtyp    (wpt_id)
);

-- ============================================================
-- Core entity tables
-- ============================================================

CREATE TABLE dbo.dluznik (
    dl_id           INT           NOT NULL,
    dl_plec         VARCHAR(1)    NULL,
    dl_imie         VARCHAR(200)  NULL,
    dl_nazwisko     VARCHAR(200)  NULL,
    dl_dowod        VARCHAR(50)   NULL,
    dl_paszport     VARCHAR(50)   NULL,
    dl_dluznik      VARCHAR(50)   NULL,
    dl_pesel        VARCHAR(11)   NULL,
    dl_dt_id        INT           NOT NULL,
    dl_uwagi        VARCHAR(4000) NULL,
    dl_firma        VARCHAR(4000) NULL,
    dl_import_info  INT           NULL,
    dl_nip          VARCHAR(20)   NULL,
    dl_regon        VARCHAR(20)   NULL,
    mod_date        DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_dluznik PRIMARY KEY (dl_id),
    CONSTRAINT FK_dluznik_dluznik_typ  FOREIGN KEY (dl_dt_id) REFERENCES dbo.dluznik_typ  (dt_id),
    CONSTRAINT FK_dluznik_plec_mapping FOREIGN KEY (dl_plec)  REFERENCES mapowanie.plec (pm_kod)
);

CREATE TABLE dbo.sprawa (
    sp_id               INT          NOT NULL,
    sp_numer_sprawy     VARCHAR(50)  NOT NULL,
    sp_numer_rachunku   VARCHAR(50)  NULL,
    sp_pracownik        VARCHAR(50)  NULL,
    sp_spe_id           INT          NOT NULL,
    sp_spt_id           INT          NOT NULL,
    sp_import_info      VARCHAR(50)  NULL,
    sp_data_obslugi_od  DATETIME     NULL,
    sp_data_obslugi_do  DATETIME     NULL,
    mod_date            DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_sprawa PRIMARY KEY (sp_id),
    CONSTRAINT FK_sprawa_sprawa_etap FOREIGN KEY (sp_spe_id) REFERENCES dbo.sprawa_etap (spe_id),
    CONSTRAINT FK_sprawa_sprawa_typ  FOREIGN KEY (sp_spt_id) REFERENCES dbo.sprawa_typ  (spt_id)
);

CREATE TABLE dbo.wierzytelnosc (
    wi_id           INT          NOT NULL,
    wi_sp_id        INT          NOT NULL,
    wi_uko_id       INT          NULL,
    wi_numer        VARCHAR(50)  NULL,
    wi_tytul        VARCHAR(200) NULL,
    wi_data_umowy   DATE         NULL,
    mod_date        DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wierzytelnosc PRIMARY KEY (wi_id),
    CONSTRAINT FK_wierzytelnosc_sprawa           FOREIGN KEY (wi_sp_id)  REFERENCES dbo.sprawa           (sp_id),
    CONSTRAINT FK_wierzytelnosc_umowa_kontrahent FOREIGN KEY (wi_uko_id) REFERENCES dbo.umowa_kontrahent (uko_id)
);

CREATE TABLE dbo.ksiegowanie (
    ks_id                   INT          NOT NULL,
    ks_data_ksiegowania     DATE         NOT NULL,
    ks_data_operacji        DATE         NOT NULL,
    ks_uwagi                VARCHAR(200) NULL,
    ks_kst_id               INT          NOT NULL,
    ks_pierwotne            BIT          NULL,
    ks_korekta              BIT          NULL,
    mod_date                DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_ksiegowanie PRIMARY KEY (ks_id),
    CONSTRAINT FK_ksiegowanie_ksiegowanie_typ FOREIGN KEY (ks_kst_id) REFERENCES dbo.ksiegowanie_typ (kst_id)
);

-- ============================================================
-- Dependent tables
-- ============================================================

CREATE TABLE dbo.adres (
    ad_id           INT           NOT NULL,
    ad_dl_id        INT           NOT NULL,
    ad_ulica        VARCHAR(200)  NULL,
    ad_nr_domu      VARCHAR(20)   NULL,
    ad_nr_lokalu    VARCHAR(20)   NULL,
    ad_kod          VARCHAR(10)   NULL,
    ad_miejscowosc  VARCHAR(200)  NULL,
    ad_poczta       VARCHAR(100)  NULL,
    ad_panstwo      VARCHAR(100)  NULL,
    ad_at_id        INT           NOT NULL,
    ad_uwagi        VARCHAR(4000) NULL,
    ad_data_od      DATETIME      NULL,
    ad_data_do      DATETIME      NULL,
    mod_date        DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_adres PRIMARY KEY (ad_id),
    CONSTRAINT FK_adres_dluznik   FOREIGN KEY (ad_dl_id) REFERENCES dbo.dluznik   (dl_id),
    CONSTRAINT FK_adres_adres_typ FOREIGN KEY (ad_at_id) REFERENCES dbo.adres_typ (at_id)
);

CREATE TABLE dbo.akcja (
    ak_id               INT      NOT NULL,
    ak_sp_id            INT      NOT NULL,
    ak_akt_id           INT      NULL,
    ak_data_zakonczenia DATE     NULL,
    mod_date            DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_akcja PRIMARY KEY (ak_id),
    CONSTRAINT FK_akcja_sprawa    FOREIGN KEY (ak_sp_id)  REFERENCES dbo.sprawa    (sp_id),
    CONSTRAINT FK_akcja_akcja_typ FOREIGN KEY (ak_akt_id) REFERENCES dbo.akcja_typ (akt_id)
);

CREATE TABLE dbo.rezultat (
    re_id               INT  NOT NULL IDENTITY(1,1),
    re_ak_id            INT  NOT NULL,
    re_ret_id           INT  NOT NULL,
    re_data_wykonania   DATE NULL,
    mod_date            DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_rezultat PRIMARY KEY (re_id),
    CONSTRAINT FK_rezultat_akcja        FOREIGN KEY (re_ak_id)  REFERENCES dbo.akcja       (ak_id),
    CONSTRAINT FK_rezultat_rezultat_typ FOREIGN KEY (re_ret_id) REFERENCES dbo.rezultat_typ (ret_id)
);

CREATE TABLE dbo.atrybut (
    at_id       INT           NOT NULL,
    at_ob_id    INT           NOT NULL,
    at_wartosc  VARCHAR(100)  NOT NULL,
    at_att_id   INT           NOT NULL,
    mod_date    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_atrybut PRIMARY KEY (at_id),
    CONSTRAINT FK_atrybut_typ FOREIGN KEY (at_att_id) REFERENCES dbo.atrybut_typ (att_id)
);

CREATE TABLE dbo.dokument (
    do_id                   INT          NOT NULL,
    do_wi_id                INT          NOT NULL,
    do_numer_dokumentu      VARCHAR(200) NULL,
    do_data_wystawienia     DATE         NULL,
    do_dot_id               INT          NOT NULL,
    do_data_wymagalnosci    DATE         NULL,
    do_tytul_dokumentu      VARCHAR(200) NULL,
    mod_date                DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_dokument PRIMARY KEY (do_id),
    CONSTRAINT FK_dokument_wierzytelnosc FOREIGN KEY (do_wi_id)  REFERENCES dbo.wierzytelnosc (wi_id),
    CONSTRAINT FK_dokument_dokument_typ  FOREIGN KEY (do_dot_id) REFERENCES dbo.dokument_typ  (dot_id)
);

-- Reference copy from dm_data_web_pipeline.dbo.dokument_odsetki_przerwy_typ (populated before migration run)
CREATE TABLE dbo.dokument_odsetki_przerwy_typ (
    dopt_id    INT          NOT NULL,
    dopt_nazwa VARCHAR(MAX) NULL,
    dopt_opis  VARCHAR(MAX) NULL,
    CONSTRAINT PK_dokument_odsetki_przerwy_typ PRIMARY KEY (dopt_id)
);

CREATE TABLE dbo.dokument_odsetki_przerwy (
    dop_id                      BIGINT   IDENTITY(1,1) NOT NULL,
    dop_do_id                   INT      NULL,
    dop_data_od                 DATETIME NULL,
    dop_data_do                 DATETIME NULL,
    dop_licz_od_niewymagalnych  BIT      NOT NULL DEFAULT 0,
    dop_dopt_id                 INT      NOT NULL,
    dop_ak_id                   INT      NULL,
    mod_date                    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_dokument_odsetki_przerwy PRIMARY KEY (dop_id),
    CONSTRAINT FK_dop_do   FOREIGN KEY (dop_do_id)   REFERENCES dbo.dokument (do_id),
    CONSTRAINT FK_dop_dopt FOREIGN KEY (dop_dopt_id) REFERENCES dbo.dokument_odsetki_przerwy_typ (dopt_id)
);

CREATE TABLE dbo.harmonogram (
    hr_id               INT             NOT NULL,
    hr_wi_id            INT             NOT NULL,
    hr_typ              VARCHAR(50)     NOT NULL,
    hr_data_raty        DATE            NOT NULL,
    hr_numer_raty       INT             NOT NULL,
    hr_kwota_raty       DECIMAL(18,2)   NOT NULL,
    hr_kwota_kapitalu   DECIMAL(18,2)   NOT NULL,
    hr_kwota_odsetek    DECIMAL(18,2)   NOT NULL,
    mod_date            DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_harmonogram PRIMARY KEY (hr_id),
    CONSTRAINT FK_harmonogram_wierzytelnosc FOREIGN KEY (hr_wi_id) REFERENCES dbo.wierzytelnosc (wi_id)
);

CREATE TABLE dbo.ksiegowanie_dekret (
    ksd_id                      INT           NOT NULL,
    ksd_ks_id                   INT           NOT NULL,
    ksd_do_id                   INT           NULL,
    ksd_kwota                   DECIMAL(18,2) NOT NULL,
    ksd_data_naliczania_odsetek DATE          NULL,
    ksd_data_wymagalnosci       DATE          NULL,
    ksd_ksk_id                  INT           NOT NULL,
    ksd_uwagi                   VARCHAR(500)  NULL,
    ksd_sp_id                   INT           NULL,
    -- multi-currency columns (already on prod; added to staging for migration)
    ksd_kurs_bazowy             DECIMAL(18,4) NULL,
    ksd_kwota_wn_wyceny         DECIMAL(18,2) NULL,
    ksd_kwota_ma_wyceny         DECIMAL(18,2) NULL,
    ksd_wa_id_wyceny            INT           NULL,
    ksd_kwota_wn_bazowa         DECIMAL(18,2) NULL,
    ksd_kwota_ma_bazowa         DECIMAL(18,2) NULL,
    ksd_wa_id                   INT           NULL,
    ksd_ksksub_id               INT           NULL,
    mod_date                    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_ksiegowanie_dekret  PRIMARY KEY (ksd_id),
    CONSTRAINT FK_ksd_ksiegowanie     FOREIGN KEY (ksd_ks_id)        REFERENCES dbo.ksiegowanie       (ks_id),
    CONSTRAINT FK_ksd_dokument        FOREIGN KEY (ksd_do_id)        REFERENCES dbo.dokument          (do_id),
    CONSTRAINT FK_ksd_ksk             FOREIGN KEY (ksd_ksk_id)       REFERENCES dbo.ksiegowanie_konto (ksk_id),
    CONSTRAINT FK_ksd_sprawa          FOREIGN KEY (ksd_sp_id)        REFERENCES dbo.sprawa            (sp_id),
    CONSTRAINT FK_ksd_waluta_wyceny   FOREIGN KEY (ksd_wa_id_wyceny) REFERENCES dbo.waluta           (wa_id),
    CONSTRAINT FK_ksd_waluta          FOREIGN KEY (ksd_wa_id)        REFERENCES dbo.waluta           (wa_id)
);

CREATE TABLE dbo.mail (
    ma_id               INT          NOT NULL,
    ma_dl_id            INT          NOT NULL,
    ma_adres_mailowy    VARCHAR(50)  NULL,
    ma_data_od          DATETIME     NULL,
    ma_data_do          DATETIME     NULL,
    mod_date            DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_mail PRIMARY KEY (ma_id),
    CONSTRAINT FK_mail_dluznik FOREIGN KEY (ma_dl_id) REFERENCES dbo.dluznik (dl_id)
);

CREATE TABLE dbo.operacja (
    oper_id                          INT           NOT NULL,
    oper_wi_id                       INT           NULL,
    oper_waluta                      VARCHAR(3)    NULL,
    oper_rejestr_kod                 VARCHAR(20)   NULL,
    oper_typ_dekretu                 VARCHAR(20)   NULL,
    oper_opis_dekretu                VARCHAR(500)  NULL,
    oper_dokument_typ_prod_id        INT           NULL,
    oper_dokument_podtyp_prod_id     INT           NULL,
    oper_dokument_typ_prod_opis      VARCHAR(200)  NULL,
    oper_dokument_podtyp_prod_opis   VARCHAR(200)  NULL,
    oper_dokument_prod_id            INT           NULL,
    oper_opis_slowny                 VARCHAR(500)  NULL,
    oper_opis                        VARCHAR(500)  NULL,
    oper_strona                      VARCHAR(10)   NULL,
    oper_kwota                       DECIMAL(18,2) NULL,
    oper_kwota_dekretu               DECIMAL(18,2) NULL,
    oper_kwota_kapitalu              DECIMAL(18,2) NULL,
    oper_kwota_odsetek               DECIMAL(18,2) NULL,
    oper_kowta_odsetek_karnych       DECIMAL(18,2) NULL,
    oper_kwota_oplaty                DECIMAL(18,2) NULL,
    oper_kwota_prowizji              DECIMAL(18,2) NULL,
    oper_kwota_w_pln                 DECIMAL(18,2) NULL,
    oper_kwota_dekretu_w_pln         DECIMAL(18,2) NULL,
    oper_kwota_kapitalu_w_pln        DECIMAL(18,2) NULL,
    oper_kwota_odsetek_w_pln         DECIMAL(18,2) NULL,
    oper_kowta_odsetek_karnych_w_pln DECIMAL(18,2) NULL,
    oper_kwota_oplaty_w_pln          DECIMAL(18,2) NULL,
    oper_kwota_prowizji_w_pln        DECIMAL(18,2) NULL,
    oper_data_waluty                 DATE          NULL,
    oper_data_danych                 DATE          NULL,
    oper_data_dekretu                DATE          NULL,
    oper_data_ksiegowania            DATE          NULL,
    oper_beneficjent_nazwa           VARCHAR(500)  NULL,
    oper_remitter_nazwa              VARCHAR(500)  NULL,
    oper_konto                       VARCHAR(50)   NULL,
    oper_do_id                       INT           NULL,
    mod_date                         DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_operacja PRIMARY KEY (oper_id),
    CONSTRAINT FK_operacja_wierzytelnosc    FOREIGN KEY (oper_wi_id)                REFERENCES dbo.wierzytelnosc (wi_id),
    CONSTRAINT FK_operacja_dokument_typ     FOREIGN KEY (oper_dokument_typ_prod_id) REFERENCES dbo.dokument_typ  (dot_id),
    CONSTRAINT FK_operacja_dokument         FOREIGN KEY (oper_dokument_prod_id)     REFERENCES dbo.dokument      (do_id),
    CONSTRAINT FK_operacja_dokument_do      FOREIGN KEY (oper_do_id)                REFERENCES dbo.dokument      (do_id)
);

CREATE TABLE dbo.sprawa_rola (
    spr_id      INT      NOT NULL IDENTITY(1,1),
    spr_sp_id   INT      NOT NULL,
    spr_dl_id   INT      NOT NULL,
    spr_sprt_id INT      NOT NULL,
    mod_date    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_sprawa_rola PRIMARY KEY (spr_id),
    CONSTRAINT FK_sprawa_rola_sprawa          FOREIGN KEY (spr_sp_id)   REFERENCES dbo.sprawa          (sp_id),
    CONSTRAINT FK_sprawa_rola_dluznik         FOREIGN KEY (spr_dl_id)   REFERENCES dbo.dluznik         (dl_id),
    CONSTRAINT FK_sprawa_rola_sprawa_rola_typ FOREIGN KEY (spr_sprt_id) REFERENCES dbo.sprawa_rola_typ (sprt_id)
);

CREATE TABLE dbo.telefon (
    tn_id       INT          NOT NULL,
    tn_dl_id    INT          NOT NULL,
    tn_numer    VARCHAR(50)  NULL,
    tn_tt_id    INT          NOT NULL,
    tn_data_od  DATETIME     NULL,
    tn_data_do  DATETIME     NULL,
    mod_date    DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_telefon PRIMARY KEY (tn_id),
    CONSTRAINT FK_telefon_dluznik     FOREIGN KEY (tn_dl_id) REFERENCES dbo.dluznik    (dl_id),
    CONSTRAINT FK_telefon_telefon_typ FOREIGN KEY (tn_tt_id) REFERENCES dbo.telefon_typ (tt_id)
);

-- ============================================================
-- Wlasciwosc entity + join tables
-- (after dluznik, adres, mail, telefon — FK dependencies)
-- ============================================================

CREATE TABLE dbo.wlasciwosc (
    wl_id           INT      NOT NULL,
    wl_wtpd_id      INT      NOT NULL,
    wl_aktywny_od   DATETIME NOT NULL,
    wl_aktywny_do   DATETIME NULL,
    mod_date        DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc PRIMARY KEY (wl_id),
    CONSTRAINT FK_wlasciwosc_wtpd FOREIGN KEY (wl_wtpd_id) REFERENCES dbo.wlasciwosc_typ_podtyp_dziedzina (wtpd_id)
);

CREATE TABLE dbo.wlasciwosc_dluznik (
    wd_id       INT      NOT NULL,
    wd_wl_id    INT      NOT NULL,
    wd_dl_id    INT      NOT NULL,
    mod_date    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc_dluznik PRIMARY KEY (wd_id),
    CONSTRAINT FK_wd_wl FOREIGN KEY (wd_wl_id) REFERENCES dbo.wlasciwosc (wl_id),
    CONSTRAINT FK_wd_dl FOREIGN KEY (wd_dl_id) REFERENCES dbo.dluznik    (dl_id)
);

CREATE TABLE dbo.wlasciwosc_adres (
    wa_id       INT      NOT NULL,
    wa_wl_id    INT      NOT NULL,
    wa_ad_id    INT      NOT NULL,
    mod_date    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc_adres PRIMARY KEY (wa_id),
    CONSTRAINT FK_wa_wl FOREIGN KEY (wa_wl_id) REFERENCES dbo.wlasciwosc (wl_id),
    CONSTRAINT FK_wa_ad FOREIGN KEY (wa_ad_id) REFERENCES dbo.adres      (ad_id)
);

CREATE TABLE dbo.wlasciwosc_email (
    we_id       INT      NOT NULL,
    we_wl_id    INT      NOT NULL,
    we_ma_id    INT      NOT NULL,
    mod_date    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc_email PRIMARY KEY (we_id),
    CONSTRAINT FK_we_wl FOREIGN KEY (we_wl_id) REFERENCES dbo.wlasciwosc (wl_id),
    CONSTRAINT FK_we_ma FOREIGN KEY (we_ma_id) REFERENCES dbo.mail       (ma_id)
);

CREATE TABLE dbo.wlasciwosc_telefon (
    wt_id       INT      NOT NULL,
    wt_wl_id    INT      NOT NULL,
    wt_tn_id    INT      NOT NULL,
    mod_date    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wlasciwosc_telefon PRIMARY KEY (wt_id),
    CONSTRAINT FK_wt_wl FOREIGN KEY (wt_wl_id) REFERENCES dbo.wlasciwosc (wl_id),
    CONSTRAINT FK_wt_tn FOREIGN KEY (wt_tn_id) REFERENCES dbo.telefon    (tn_id)
);

CREATE TABLE dbo.wierzytelnosc_rola (
    wir_id      INT      NOT NULL IDENTITY(1,1),
    wir_sp_id   INT      NOT NULL,
    wir_wi_id   INT      NOT NULL,
    wir_rl_id   INT      NOT NULL,
    mod_date    DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_wierzytelnosc_rola PRIMARY KEY (wir_id),
    CONSTRAINT FK_wierzytelnosc_rola_sprawa        FOREIGN KEY (wir_sp_id) REFERENCES dbo.sprawa        (sp_id),
    CONSTRAINT FK_wierzytelnosc_rola_wierzytelnosc FOREIGN KEY (wir_wi_id) REFERENCES dbo.wierzytelnosc (wi_id)
);

CREATE TABLE dbo.zabezpieczenie (
    zab_id                  INT           NOT NULL,
    zab_wi_id               INT           NULL,
    zab_dl_id               INT           NULL,
    zab_relacja             VARCHAR(200)  NULL,
    zab_opis                VARCHAR(200)  NULL,
    zab_procent_zm_rez      DECIMAL(18,2) NULL,
    zab_klasyfikacja        VARCHAR(1)    NULL,
    zab_rodzaj              VARCHAR(4)    NULL,
    zab_rodzaj_opis         VARCHAR(62)   NULL,
    zab_typ_zabezpieczenia  VARCHAR(2)    NULL,
    zab_wartosc_zab         DECIMAL(18,2) NULL,
    zab_wartosc_zm_rez      DECIMAL(18,2) NULL,
    zab_podstawa            DECIMAL(18,2) NULL,
    zab_data_ustanowienia   DATE          NULL,
    zab_data_zwolnienia     DATE          NULL,
    zab_data_waznosci       DATE          NULL,
    zab_wartosc_rynkowa     DECIMAL(18,2) NULL,
    zab_waluta_wyceny       VARCHAR(3)    NULL,
    zab_wartosc_bank_hip    DECIMAL(18,2) NULL,
    zab_waluta_kw           VARCHAR(3)    NULL,
    zab_wpis_kw             DECIMAL(18,2) NULL,
    zab_priorytet           VARCHAR(2)    NULL,
    mod_date                DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_zabezpieczenie PRIMARY KEY (zab_id),
    CONSTRAINT FK_zabezpieczenie_dluznik       FOREIGN KEY (zab_dl_id)  REFERENCES dbo.dluznik       (dl_id),
    CONSTRAINT FK_zabezpieczenie_wierzytelnosc FOREIGN KEY (zab_wi_id)  REFERENCES dbo.wierzytelnosc (wi_id)
);


-- ============================================================
-- log schema (pre-migration validation + migration execution logging)
-- ============================================================

CREATE TABLE log.migration_run (
    run_id           INT IDENTITY(1,1) NOT NULL,
    run_type         VARCHAR(20)       NOT NULL,  -- PRE_CHECK / MIGRATION
    migration_stage  INT               NOT NULL,
    run_by           NVARCHAR(128)     NOT NULL,
    status           VARCHAR(20)       NOT NULL,  -- RUNNING / COMPLETED / FAILED
    run_date         DATETIME          NOT NULL DEFAULT GETDATE(),
    duration_seconds INT               NULL,
    records_total    INT               NULL,
    records_success  INT               NULL,
    records_failed   INT               NULL,
    notes            NVARCHAR(MAX)     NULL,
    CONSTRAINT PK_migration_run PRIMARY KEY (run_id)
);

CREATE TABLE log.migration_table_summary (
    id               INT IDENTITY(1,1) NOT NULL,
    run_id           INT               NOT NULL,
    table_name       VARCHAR(100)      NOT NULL,
    records_attempted INT              NOT NULL DEFAULT 0,
    records_inserted  INT              NOT NULL DEFAULT 0,
    records_skipped   INT              NOT NULL DEFAULT 0,
    records_failed    INT              NOT NULL DEFAULT 0,
    CONSTRAINT PK_migration_table_summary PRIMARY KEY (id),
    CONSTRAINT FK_mts_run FOREIGN KEY (run_id) REFERENCES log.migration_run (run_id)
);

CREATE TABLE log.migration_error (
    id            INT IDENTITY(1,1) NOT NULL,
    run_id        INT               NOT NULL,
    table_name    VARCHAR(100)      NOT NULL,
    staging_pk    VARCHAR(100)      NULL,
    error_type    VARCHAR(30)       NOT NULL,  -- REFERENTIAL / TECHNICAL / BUSINESS_RULE / FORMAT / SYSTEM
    error_code    VARCHAR(50)       NULL,
    error_message NVARCHAR(MAX)     NULL,
    error_data    NVARCHAR(MAX)     NULL,
    CONSTRAINT PK_migration_error PRIMARY KEY (id),
    CONSTRAINT FK_err_run FOREIGN KEY (run_id) REFERENCES log.migration_run (run_id)
);

CREATE TABLE log.validation_result (
    id             INT IDENTITY(1,1) NOT NULL,
    run_id         INT               NULL,       -- NULL allowed for ad-hoc runs
    check_name     VARCHAR(100)      NOT NULL,
    check_type     VARCHAR(30)       NOT NULL,   -- REFERENTIAL / TECHNICAL / BUSINESS_RULE / FORMAT
    severity       VARCHAR(10)       NOT NULL,   -- BLOCKING / WARNING / INFO
    affected_count INT               NOT NULL DEFAULT 0,
    sample_ids     VARCHAR(500)      NULL,
    detail         NVARCHAR(MAX)     NULL,
    logged_at      DATETIME          NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_validation_result PRIMARY KEY (id),
    CONSTRAINT FK_vr_run FOREIGN KEY (run_id) REFERENCES log.migration_run (run_id)
);

CREATE TABLE log.postmigration_check (
    check_id       INT IDENTITY(1,1) NOT NULL,
    run_id         INT               NOT NULL,
    kpi_name       VARCHAR(100)      NOT NULL,
    kpi_type       VARCHAR(20)       NOT NULL,  -- COUNT / SUM / ANOMALY
    expected_value NVARCHAR(200)     NULL,
    actual_value   NVARCHAR(200)     NULL,
    delta          NVARCHAR(200)     NULL,
    pass           BIT               NOT NULL DEFAULT 0,
    note           NVARCHAR(MAX)     NULL,
    checked_at     DATETIME          NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_postmigration_check PRIMARY KEY (check_id),
    CONSTRAINT FK_pmc_run FOREIGN KEY (run_id) REFERENCES log.migration_run (run_id)
);

CREATE TABLE log.configuration (
    id            INT IDENTITY(1,1) NOT NULL,
    setting_name  VARCHAR(100)      NOT NULL,
    setting_value NVARCHAR(500)     NOT NULL,
    CONSTRAINT PK_log_configuration PRIMARY KEY (id),
    CONSTRAINT UQ_log_configuration_name UNIQUE (setting_name)
);

-- system_admin_user_id: ID of the system user in dm_data_web_pipeline.dbo.GE_USER
-- used as *_tworzacy_us_id for adres, mail, telefon, wlasciwosc inserts.
-- Value must exist in prod GE_USER table (FK enforced on wlasciwosc).
-- Update this value to match the actual system admin user ID in prod before running migration.
INSERT INTO log.configuration (setting_name, setting_value) VALUES ('system_admin_user_id', '5');

-- ============================================================
-- Shared migration helper procedures (used by iter2-9 scripts)
-- ============================================================
GO

-- Resolves the active migration run and returns common variables.
-- Called at the top of each iter script to replace the duplicated header block.
CREATE OR ALTER PROCEDURE log.usp_resolve_run
    @p_stage                INT,
    @p_run_id               INT OUTPUT,
    @p_system_admin_user_id INT OUTPUT,
    @p_aud_now              DATETIME OUTPUT,
    @p_aud_login            VARCHAR(200) OUTPUT
AS
SET NOCOUNT ON;
    SET @p_aud_now = GETUTCDATE();
    SET @p_aud_login = 'admin';

    SELECT TOP 1 @p_run_id = run_id
    FROM log.migration_run WITH (NOLOCK)
    WHERE status = 'RUNNING'
      AND run_type = 'MIGRATION'
      AND migration_stage = @p_stage
    ORDER BY run_id DESC;

    IF @p_run_id IS NULL
        THROW 50010, 'No active MIGRATION run found. Run 00_pre_check.sql first.', 1;

    SELECT @p_system_admin_user_id = CAST(setting_value AS INT)
    FROM log.configuration WITH (NOLOCK)
    WHERE setting_name = 'system_admin_user_id';

    IF @p_system_admin_user_id IS NULL
        THROW 50011, 'system_admin_user_id not found in log.configuration.', 1;
GO

-- Logs a successful table migration section.
CREATE OR ALTER PROCEDURE log.usp_log_success
    @p_run_id     INT,
    @p_table      VARCHAR(100),
    @p_attempted  INT,
    @p_inserted   INT,
    @p_updated    INT = 0
AS
SET NOCOUNT ON;
    DECLARE @skipped INT = @p_attempted - @p_inserted - @p_updated;
    IF @skipped < 0 SET @skipped = 0;
    INSERT INTO log.migration_table_summary
        (run_id, table_name, records_attempted, records_inserted, records_skipped, records_failed)
    VALUES (@p_run_id, @p_table, @p_attempted, @p_inserted, @skipped, 0);
    PRINT '  ' + @p_table + ': attempted=' + CAST(@p_attempted AS VARCHAR)
        + ' inserted=' + CAST(@p_inserted AS VARCHAR)
        + CASE WHEN @p_updated > 0 THEN ' updated=' + CAST(@p_updated AS VARCHAR) ELSE '' END;
GO

-- Logs a failed table migration section. Call from CATCH block with ERROR_MESSAGE().
-- Note: ERROR_MESSAGE() must be captured BEFORE calling this proc (it resets in proc scope).
CREATE OR ALTER PROCEDURE log.usp_log_error
    @p_run_id      INT,
    @p_table       VARCHAR(100),
    @p_attempted   INT,
    @p_err         NVARCHAR(MAX),
    @p_error_code  VARCHAR(50) = NULL
AS
SET NOCOUNT ON;
    INSERT INTO log.migration_error
        (run_id, table_name, staging_pk, error_type, error_code, error_message, error_data)
    VALUES (@p_run_id, @p_table, NULL, 'SYSTEM', @p_error_code, @p_err, NULL);
    INSERT INTO log.migration_table_summary
        (run_id, table_name, records_attempted, records_inserted, records_skipped, records_failed)
    VALUES (@p_run_id, @p_table, ISNULL(@p_attempted, 0), 0, 0, ISNULL(@p_attempted, 0));
    PRINT '   ERROR in ' + @p_table + ': ' + @p_err;
GO

-- ============================================================
-- Configuration schema (tunable thresholds)
-- ============================================================

CREATE TABLE configuration.threshold_config (
    cfg_id    INT IDENTITY(1,1) NOT NULL,
    cfg_key   VARCHAR(100)      NOT NULL,
    cfg_value VARCHAR(100)      NOT NULL,
    cfg_note  VARCHAR(500)      NULL,
    CONSTRAINT PK_threshold_config  PRIMARY KEY (cfg_id),
    CONSTRAINT UQ_threshold_cfg_key UNIQUE      (cfg_key)
);

INSERT INTO configuration.threshold_config (cfg_key, cfg_value, cfg_note) VALUES
    ('max_phones_per_dluznik',          '10',  'Flag dluznik records with more than N phone numbers'),
    ('max_adresy_per_dluznik',          '10',  'Flag dluznik records with more than N addresses'),
    ('max_akcje_per_sprawa',            '200', 'Flag sprawa records with more than N akcja entries'),
    ('max_dokumenty_per_wierzytelnosc', '20',  'Flag wierzytelnosc records with more than N dokument entries'),
    ('phone_min_digits',                '9',   'Minimum digit count for a valid phone number after stripping spaces/dashes/plus');

-- ============================================================
-- Migration infrastructure: ext_id columns on staging tables
-- (stores prod PK after MERGE/INSERT for downstream FK resolution)
-- Re-runnable: all ALTER TABLE guarded by IF NOT EXISTS.
-- ============================================================
GO

-- Lookup table ext_id columns
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.adres_typ')        AND name = 'at_ext_id')
    ALTER TABLE dbo.adres_typ        ADD at_ext_id   INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.dluznik_typ')       AND name = 'dt_ext_id')
    ALTER TABLE dbo.dluznik_typ      ADD dt_ext_id   INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.telefon_typ')       AND name = 'tt_ext_id')
    ALTER TABLE dbo.telefon_typ      ADD tt_ext_id   INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.dokument_typ')      AND name = 'dot_ext_id')
    ALTER TABLE dbo.dokument_typ     ADD dot_ext_id  INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ksiegowanie_konto') AND name = 'ksk_ext_id')
    ALTER TABLE dbo.ksiegowanie_konto ADD ksk_ext_id INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ksiegowanie_typ')   AND name = 'kst_ext_id')
    ALTER TABLE dbo.ksiegowanie_typ  ADD kst_ext_id  INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.sprawa_rola_typ')   AND name = 'sprt_ext_id')
    ALTER TABLE dbo.sprawa_rola_typ  ADD sprt_ext_id INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.sprawa_typ')        AND name = 'spt_ext_id')
    ALTER TABLE dbo.sprawa_typ       ADD spt_ext_id  INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.atrybut_dziedzina') AND name = 'atd_ext_id')
    ALTER TABLE dbo.atrybut_dziedzina ADD atd_ext_id INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.atrybut_rodzaj')    AND name = 'atr_ext_id')
    ALTER TABLE dbo.atrybut_rodzaj   ADD atr_ext_id  INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.atrybut_typ')       AND name = 'att_ext_id')
    ALTER TABLE dbo.atrybut_typ      ADD att_ext_id  INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.akcja_typ')         AND name = 'akt_ext_id')
    ALTER TABLE dbo.akcja_typ        ADD akt_ext_id  VARCHAR(50) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.rezultat_typ')      AND name = 'ret_ext_id')
    ALTER TABLE dbo.rezultat_typ     ADD ret_ext_id  VARCHAR(50) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.sprawa_etap')       AND name = 'spe_ext_id')
    ALTER TABLE dbo.sprawa_etap      ADD spe_ext_id  INT NULL;

-- Wlasciwosc lookup ext_id columns
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.zrodlo_pochodzenia_informacji') AND name = 'zpi_ext_id')
    ALTER TABLE dbo.zrodlo_pochodzenia_informacji ADD zpi_ext_id INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.wlasciwosc_typ_walidacji')     AND name = 'wtw_ext_id')
    ALTER TABLE dbo.wlasciwosc_typ_walidacji      ADD wtw_ext_id INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.wlasciwosc_dziedzina')         AND name = 'wdzi_ext_id')
    ALTER TABLE dbo.wlasciwosc_dziedzina          ADD wdzi_ext_id INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.wlasciwosc_podtyp')            AND name = 'wpt_ext_id')
    ALTER TABLE dbo.wlasciwosc_podtyp             ADD wpt_ext_id INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.wlasciwosc_typ')               AND name = 'wt_ext_id')
    ALTER TABLE dbo.wlasciwosc_typ                ADD wt_ext_id  INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.wlasciwosc_typ_podtyp_dziedzina') AND name = 'wtpd_ext_id')
    ALTER TABLE dbo.wlasciwosc_typ_podtyp_dziedzina ADD wtpd_ext_id INT NULL;

-- Entity table ext_id columns
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.adres')   AND name = 'ad_ext_id')
    ALTER TABLE dbo.adres   ADD ad_ext_id INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.mail')    AND name = 'ma_ext_id')
    ALTER TABLE dbo.mail    ADD ma_ext_id INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.telefon') AND name = 'tn_ext_id')
    ALTER TABLE dbo.telefon ADD tn_ext_id INT NULL;

-- umowa_kontrahent: IDENTITY mapping column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.umowa_kontrahent') AND name = 'uko_id_migracja')
    ALTER TABLE dbo.umowa_kontrahent ADD uko_id_migracja INT NULL;

-- ============================================================
-- Shared procedure: migrate atrybut_wartosc by domain
-- Used by iter2 (att_atd_id=3, dluznik), iter4 (att_atd_id=4, sprawa),
-- iter6 (att_atd_id=2, wierzytelnosc), and iter7 (att_atd_id=1, dokument).
-- Caller MUST create #atw_mapping (staging_at_id INT, prod_atw_id INT) before calling.
-- ============================================================
GO
CREATE OR ALTER PROCEDURE dbo.usp_migrate_atrybut_wartosc
    @att_atd_id     INT,
    @aud_now        DATETIME2,
    @aud_login      VARCHAR(50),
    @attempted      INT OUTPUT,
    @inserted       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Count attempted
    SET @attempted = (
        SELECT COUNT(*)
        FROM dbo.atrybut stg WITH (NOLOCK)
        JOIN dbo.atrybut_typ stg_att WITH (NOLOCK) ON stg_att.att_id = stg.at_att_id
        WHERE stg_att.att_atd_id = @att_atd_id
    );

    -- Snapshot existing ext_ids
    SELECT atw_ext_id INTO #existing_atw
    FROM dm_data_web_pipeline.dbo.atrybut_wartosc WITH (NOLOCK)
    WHERE atw_ext_id IS NOT NULL;
    CREATE UNIQUE INDEX UX_existing_atw ON #existing_atw (atw_ext_id);

    -- INSERT new rows (OUTPUT into caller's #atw_mapping)
    INSERT INTO dm_data_web_pipeline.dbo.atrybut_wartosc WITH (TABLOCK) (
        atw_att_id, atw_wartosc, atw_ext_id, aud_data, aud_login
    )
    OUTPUT CAST(inserted.atw_ext_id AS INT), inserted.atw_id
    INTO #atw_mapping (staging_at_id, prod_atw_id)
    SELECT
        att.att_id,
        stg.at_wartosc,
        CAST(stg.at_id AS VARCHAR(100)),
        @aud_now,
        @aud_login
    FROM dbo.atrybut stg WITH (NOLOCK)
    JOIN dbo.atrybut_typ stg_att WITH (NOLOCK) ON stg_att.att_id = stg.at_att_id
    JOIN dm_data_web_pipeline.dbo.atrybut_typ att WITH (NOLOCK) ON att.att_id = stg_att.att_ext_id
    LEFT JOIN #existing_atw ex ON ex.atw_ext_id = CAST(stg.at_id AS VARCHAR(100))
    WHERE stg_att.att_atd_id = @att_atd_id
      AND ex.atw_ext_id IS NULL;

    SET @inserted = @@ROWCOUNT;

    -- Backfill mapping for prior-run rows
    INSERT INTO #atw_mapping (staging_at_id, prod_atw_id)
    SELECT CAST(atw.atw_ext_id AS INT), atw.atw_id
    FROM dm_data_web_pipeline.dbo.atrybut_wartosc atw WITH (NOLOCK)
    JOIN dbo.atrybut stg WITH (NOLOCK) ON atw.atw_ext_id = CAST(stg.at_id AS VARCHAR(100))
    JOIN dbo.atrybut_typ stg_att WITH (NOLOCK) ON stg_att.att_id = stg.at_att_id
    LEFT JOIN #atw_mapping am ON am.staging_at_id = CAST(atw.atw_ext_id AS INT)
    WHERE stg_att.att_atd_id = @att_atd_id
      AND am.staging_at_id IS NULL;

    DROP TABLE IF EXISTS #existing_atw;
END;
GO

-- ============================================================
-- Shared procedure for wlasciwosc domain migration.
-- Used by iter2 (dluznik) and iter3 (adres, email, telefon).
-- Handles counting, idempotency snapshot, MERGE into wlasciwosc,
-- INSERT into domain-specific join table, and logging.
--
-- Two FK resolution modes:
--   MAPPING  — entity FK resolved via a mapping table (e.g. mapowanie.dodani_dluznicy)
--   EXT_ID   — entity FK resolved via prod entity table with ext_id column
-- ============================================================
GO
CREATE OR ALTER PROCEDURE dbo.usp_migrate_wlasciwosc_domain
    @p_run_id                  INT,
    @p_dziedzina_id            INT,            -- 1=telefon, 2=adres, 3=email, 4=dluznik
    @p_domain_label            VARCHAR(50),     -- e.g. 'dluznik', 'adres', 'email', 'telefon'
    @p_stg_join_table          VARCHAR(100),    -- e.g. 'wlasciwosc_dluznik'
    @p_stg_join_wl_fk          VARCHAR(100),    -- e.g. 'wd_wl_id' (FK to staging wlasciwosc)
    @p_stg_join_entity_fk      VARCHAR(100),    -- e.g. 'wd_dl_id' (FK to staging entity)
    @p_prod_join_wl_fk         VARCHAR(100),    -- e.g. 'wd_wl_id' (prod join table FK to wlasciwosc)
    @p_prod_join_entity_fk     VARCHAR(100),    -- e.g. 'wd_dl_id' (prod join table FK to entity)
    @p_fk_mode                 VARCHAR(10),     -- 'MAPPING' or 'EXT_ID'
    -- MAPPING mode params (used when @p_fk_mode = 'MAPPING')
    @p_mapping_table           VARCHAR(200)  = NULL, -- e.g. 'mapowanie.dodani_dluznicy'
    @p_mapping_staging_col     VARCHAR(100)  = NULL, -- e.g. 'staging_dl_id'
    @p_mapping_prod_col        VARCHAR(100)  = NULL, -- e.g. 'prod_dl_id'
    -- EXT_ID mode params (used when @p_fk_mode = 'EXT_ID')
    @p_prod_entity_table       VARCHAR(200)  = NULL, -- e.g. 'adres' (in dm_data_web_pipeline.dbo)
    @p_prod_entity_id_col      VARCHAR(100)  = NULL, -- e.g. 'ad_id'
    @p_prod_entity_ext_id_col  VARCHAR(100)  = NULL, -- e.g. 'ad_ext_id'
    -- Audit params
    @p_system_admin_user_id    INT,
    @p_aud_now                 DATETIME,
    @p_aud_login               VARCHAR(200),
    -- Error code for CATCH (NULL = default)
    @p_error_code              VARCHAR(100)  = NULL,
    -- Output
    @p_attempted               INT           OUTPUT,
    @p_inserted                INT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql       NVARCHAR(MAX);
    DECLARE @log_name  VARCHAR(100) = 'wlasciwosc[' + @p_domain_label + ']';

    -- Step 1: Count staging rows for this domain
    SET @sql = N'
        SELECT @cnt = COUNT(*)
        FROM dbo.wlasciwosc stg_wl WITH (NOLOCK)
        JOIN dbo.' + QUOTENAME(@p_stg_join_table) + N' stg_j WITH (NOLOCK)
            ON stg_j.' + QUOTENAME(@p_stg_join_wl_fk) + N' = stg_wl.wl_id
        JOIN dbo.wlasciwosc_typ_podtyp_dziedzina stg_wtpd WITH (NOLOCK)
            ON stg_wtpd.wtpd_id = stg_wl.wl_wtpd_id
        JOIN dbo.wlasciwosc_dziedzina stg_dzi WITH (NOLOCK)
            ON stg_dzi.wdzi_id = stg_wtpd.wtpd_dzi_id
        WHERE stg_dzi.wdzi_id = @dzi_id;';

    EXEC sp_executesql @sql,
        N'@cnt INT OUTPUT, @dzi_id INT',
        @cnt = @p_attempted OUTPUT,
        @dzi_id = @p_dziedzina_id;

    -- Step 2: Skip if zero
    IF @p_attempted = 0
    BEGIN
        SET @p_inserted = 0;
        PRINT '   ' + @log_name + ': 0 staging rows -- skipped.';
        EXEC log.usp_log_success @p_run_id, @log_name, 0, 0;
        RETURN;
    END;

    -- Step 3: Snapshot existing idempotency pairs into #wl_exist
    CREATE TABLE #wl_exist (entity_id INT, wtpd_id INT);

    SET @sql = N'
        INSERT INTO #wl_exist (entity_id, wtpd_id)
        SELECT jt.' + QUOTENAME(@p_prod_join_entity_fk) + N', wl.wl_wtpd_id
        FROM dm_data_web_pipeline.dbo.' + QUOTENAME(@p_stg_join_table) + N' jt WITH (NOLOCK)
        JOIN dm_data_web_pipeline.dbo.wlasciwosc wl WITH (NOLOCK)
            ON wl.wl_id = jt.' + QUOTENAME(@p_prod_join_wl_fk) + N';';

    EXEC sp_executesql @sql;

    -- Step 4: MERGE into wlasciwosc (always INSERT via ON 1=0)
    CREATE TABLE #wl_map (staging_wl_id INT, prod_wl_id INT);

    DECLARE @fk_join   NVARCHAR(500);
    DECLARE @fk_filter NVARCHAR(500);
    DECLARE @prod_eid  NVARCHAR(200);

    IF @p_fk_mode = 'MAPPING'
    BEGIN
        SET @fk_join = N'
        JOIN ' + @p_mapping_table + N' fk WITH (NOLOCK)
            ON fk.' + QUOTENAME(@p_mapping_staging_col) + N' = stg_j.' + QUOTENAME(@p_stg_join_entity_fk);
        SET @fk_filter = N'
        LEFT JOIN #wl_exist ex ON ex.entity_id = fk.' + QUOTENAME(@p_mapping_prod_col)
            + N' AND ex.wtpd_id = stg_wtpd.wtpd_ext_id';
        SET @prod_eid = N'fk.' + QUOTENAME(@p_mapping_prod_col);
    END
    ELSE
    BEGIN
        SET @fk_join = N'
        JOIN dm_data_web_pipeline.dbo.' + QUOTENAME(@p_prod_entity_table) + N' fk WITH (NOLOCK)
            ON fk.' + QUOTENAME(@p_prod_entity_ext_id_col) + N' = stg_j.' + QUOTENAME(@p_stg_join_entity_fk);
        SET @fk_filter = N'
        LEFT JOIN #wl_exist ex ON ex.entity_id = fk.' + QUOTENAME(@p_prod_entity_id_col)
            + N' AND ex.wtpd_id = stg_wtpd.wtpd_ext_id';
        SET @prod_eid = N'fk.' + QUOTENAME(@p_prod_entity_id_col);
    END;

    SET @sql = N'
    MERGE dm_data_web_pipeline.dbo.wlasciwosc WITH (TABLOCK) AS tgt
    USING (
        SELECT
            stg_wl.wl_id              AS staging_wl_id,
            stg_wtpd.wtpd_ext_id      AS prod_wtpd_id,
            stg_wl.wl_aktywny_od,
            stg_wl.wl_aktywny_do,
            ' + @prod_eid + N'        AS prod_entity_id
        FROM dbo.wlasciwosc stg_wl WITH (NOLOCK)
        JOIN dbo.' + QUOTENAME(@p_stg_join_table) + N' stg_j WITH (NOLOCK)
            ON stg_j.' + QUOTENAME(@p_stg_join_wl_fk) + N' = stg_wl.wl_id
        JOIN dbo.wlasciwosc_typ_podtyp_dziedzina stg_wtpd WITH (NOLOCK)
            ON stg_wtpd.wtpd_id = stg_wl.wl_wtpd_id
        JOIN dbo.wlasciwosc_dziedzina stg_dzi WITH (NOLOCK)
            ON stg_dzi.wdzi_id = stg_wtpd.wtpd_dzi_id'
        + @fk_join
        + @fk_filter + N'
        WHERE stg_dzi.wdzi_id = @dzi_id
          AND stg_wtpd.wtpd_ext_id IS NOT NULL
          AND ex.entity_id IS NULL
    ) AS src ON 1 = 0
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (wl_wtpd_id, wl_aktywny_od, wl_aktywny_do,
                wl_tworzacy_us_id, wl_dezaktywujacy_us_id, wl_zpi_id,
                aud_data, aud_login)
        VALUES (src.prod_wtpd_id, src.wl_aktywny_od, src.wl_aktywny_do,
                @admin_id, NULL, 2,
                @anow, @alogin)
    OUTPUT src.staging_wl_id, INSERTED.wl_id
    INTO #wl_map (staging_wl_id, prod_wl_id);

    SET @ins = @@ROWCOUNT;';

    DECLARE @ins INT = 0;

    EXEC sp_executesql @sql,
        N'@dzi_id INT, @admin_id INT, @anow DATETIME, @alogin VARCHAR(200), @ins INT OUTPUT',
        @dzi_id   = @p_dziedzina_id,
        @admin_id = @p_system_admin_user_id,
        @anow     = @p_aud_now,
        @alogin   = @p_aud_login,
        @ins      = @ins OUTPUT;

    SET @p_inserted = @ins;

    -- Step 5: INSERT into domain-specific join table
    IF @p_fk_mode = 'MAPPING'
    BEGIN
        SET @sql = N'
        INSERT INTO dm_data_web_pipeline.dbo.' + QUOTENAME(@p_stg_join_table) + N' WITH (TABLOCK)
            (' + QUOTENAME(@p_prod_join_wl_fk) + N', ' + QUOTENAME(@p_prod_join_entity_fk) + N', aud_data, aud_login)
        SELECT
            m.prod_wl_id,
            fk.' + QUOTENAME(@p_mapping_prod_col) + N',
            @anow,
            @alogin
        FROM dbo.' + QUOTENAME(@p_stg_join_table) + N' stg_j WITH (NOLOCK)
        JOIN #wl_map m ON m.staging_wl_id = stg_j.' + QUOTENAME(@p_stg_join_wl_fk) + N'
        JOIN ' + @p_mapping_table + N' fk WITH (NOLOCK)
            ON fk.' + QUOTENAME(@p_mapping_staging_col) + N' = stg_j.' + QUOTENAME(@p_stg_join_entity_fk) + N';';
    END
    ELSE
    BEGIN
        SET @sql = N'
        INSERT INTO dm_data_web_pipeline.dbo.' + QUOTENAME(@p_stg_join_table) + N' WITH (TABLOCK)
            (' + QUOTENAME(@p_prod_join_wl_fk) + N', ' + QUOTENAME(@p_prod_join_entity_fk) + N', aud_data, aud_login)
        SELECT
            m.prod_wl_id,
            fk.' + QUOTENAME(@p_prod_entity_id_col) + N',
            @anow,
            @alogin
        FROM dbo.' + QUOTENAME(@p_stg_join_table) + N' stg_j WITH (NOLOCK)
        JOIN #wl_map m ON m.staging_wl_id = stg_j.' + QUOTENAME(@p_stg_join_wl_fk) + N'
        JOIN dm_data_web_pipeline.dbo.' + QUOTENAME(@p_prod_entity_table) + N' fk WITH (NOLOCK)
            ON fk.' + QUOTENAME(@p_prod_entity_ext_id_col) + N' = stg_j.' + QUOTENAME(@p_stg_join_entity_fk) + N';';
    END;

    EXEC sp_executesql @sql,
        N'@anow DATETIME, @alogin VARCHAR(200)',
        @anow   = @p_aud_now,
        @alogin = @p_aud_login;

    -- Step 6: Log success
    EXEC log.usp_log_success @p_run_id, @log_name, @p_attempted, @p_inserted;

    -- Cleanup
    DROP TABLE IF EXISTS #wl_exist;
    DROP TABLE IF EXISTS #wl_map;
END;
GO

-- ============================================================
-- R4: Shared procedure to disable/rebuild non-clustered indexes
-- on prod tables before/after bulk inserts.
-- Used by iter5, iter7, iter8 (replaces duplicated dynamic SQL blocks).
-- @table_csv: comma-separated table names (e.g. 'dokument' or 'ksiegowanie,ksiegowanie_dekret')
-- @action:    'DISABLE' or 'REBUILD'
-- ============================================================
GO
CREATE OR ALTER PROCEDURE dbo.usp_manage_prod_ncis
    @table_csv NVARCHAR(500),
    @action    NVARCHAR(10)  -- 'DISABLE' or 'REBUILD'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX) = N'';
    DECLARE @is_disabled BIT = CASE WHEN @action = 'REBUILD' THEN 1 ELSE 0 END;

    SELECT @sql = @sql + N'ALTER INDEX ' + QUOTENAME(i.name)
        + N' ON dm_data_web_pipeline.' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name)
        + N' ' + @action + N'; '
    FROM dm_data_web_pipeline.sys.indexes i
    JOIN dm_data_web_pipeline.sys.tables t ON i.object_id = t.object_id
    JOIN dm_data_web_pipeline.sys.schemas s ON t.schema_id = s.schema_id
    JOIN STRING_SPLIT(@table_csv, ',') ss ON LTRIM(RTRIM(ss.value)) = t.name
    WHERE s.name = 'dbo'
      AND i.type = 2              -- non-clustered
      AND i.is_unique = 0
      AND i.is_primary_key = 0
      AND i.is_unique_constraint = 0
      AND i.is_disabled = @is_disabled
      AND t.is_ms_shipped = 0;

    IF LEN(@sql) > 0
    BEGIN
        EXEC dm_data_web_pipeline.dbo.sp_executesql @sql;
        PRINT '   >> ' + @action + ' NCIs on ' + @table_csv;
    END
END;
GO

PRINT 'staging.sql complete.';
GO
