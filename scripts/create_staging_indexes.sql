-- ============================================================
-- create_staging_indexes.sql
-- Creates all non-clustered indexes on dm_staging entity tables.
--
-- Run AFTER staging.sql + infrastructure + column descriptions.
-- For stress tests: disable_staging_indexes.sql runs next,
-- then seed, then rebuild_staging_indexes.sql.
-- ============================================================
SET NOCOUNT ON;
USE dm_staging;
GO

-- sprawa_rola: REF_01, REF_02, STR_01
CREATE INDEX IX_sprawa_rola_sp_id   ON dbo.sprawa_rola (spr_sp_id);
CREATE INDEX IX_sprawa_rola_dl_id   ON dbo.sprawa_rola (spr_dl_id);

-- wierzytelnosc_rola: REF_04, REF_05, STR_01, STR_03
CREATE INDEX IX_wierzytelnosc_rola_wi_id ON dbo.wierzytelnosc_rola (wir_wi_id);
CREATE INDEX IX_wierzytelnosc_rola_sp_id ON dbo.wierzytelnosc_rola (wir_sp_id);

-- wierzytelnosc: REF_06; critical for migration JOIN chain (wi_sp_id)
CREATE INDEX IX_wierzytelnosc_sp_id ON dbo.wierzytelnosc (wi_sp_id);

-- dokument: REF_07, REF_08, STR_03
CREATE INDEX IX_dokument_wi_id  ON dbo.dokument (do_wi_id);
CREATE INDEX IX_dokument_dot_id ON dbo.dokument (do_dot_id);

-- adres: REF_09
CREATE INDEX IX_adres_dl_id ON dbo.adres (ad_dl_id);

-- telefon: REF_11
CREATE INDEX IX_telefon_dl_id ON dbo.telefon (tn_dl_id);

-- mail: REF_13
CREATE INDEX IX_mail_dl_id ON dbo.mail (ma_dl_id);

-- akcja: REF_14, REF_32, STR_06
CREATE INDEX IX_akcja_sp_id  ON dbo.akcja (ak_sp_id);
CREATE INDEX IX_akcja_akt_id ON dbo.akcja (ak_akt_id);

-- rezultat: REF_33, REF_34, STR_06
CREATE INDEX IX_rezultat_ak_id  ON dbo.rezultat (re_ak_id);
CREATE INDEX IX_rezultat_ret_id ON dbo.rezultat (re_ret_id);

-- atrybut: REF_15, REF_16-19 (domain now resolved via atrybut_typ.att_atd_id JOIN)
CREATE INDEX IX_atrybut_att_id  ON dbo.atrybut (at_att_id);
CREATE INDEX IX_atrybut_ob_id   ON dbo.atrybut (at_ob_id);

-- ksiegowanie_dekret: REF_20, REF_21, REF_22, STR_03, STR_04, STR_05
-- ksd_sp_id: iter8 JOIN to resolve prod sprawa via sp_ext_id
-- ksd_ksksub_id: REF_35 validation
CREATE INDEX IX_ksd_ks_id     ON dbo.ksiegowanie_dekret (ksd_ks_id);
CREATE INDEX IX_ksd_ksk_id    ON dbo.ksiegowanie_dekret (ksd_ksk_id);
CREATE INDEX IX_ksd_do_id     ON dbo.ksiegowanie_dekret (ksd_do_id);
CREATE INDEX IX_ksd_sp_id     ON dbo.ksiegowanie_dekret (ksd_sp_id);
CREATE INDEX IX_ksd_ksksub_id ON dbo.ksiegowanie_dekret (ksd_ksksub_id);

-- operacja: REF_23 (oper_do_id → dokument), REF_27 (oper_waluta), iter8 JOIN
CREATE INDEX IX_operacja_wi_id  ON dbo.operacja (oper_wi_id);
CREATE INDEX IX_operacja_do_id  ON dbo.operacja (oper_do_id);
CREATE INDEX IX_operacja_waluta ON dbo.operacja (oper_waluta);

-- harmonogram: migration iter9 JOIN on hr_wi_id
CREATE INDEX IX_harmonogram_wi_id ON dbo.harmonogram (hr_wi_id);

-- waluta: REF_27 lookup by ISO currency code (wa_nazwa_skrocona is not PK)
CREATE INDEX IX_waluta_nazwa_skrocona ON dbo.waluta (wa_nazwa_skrocona);

-- wlasciwosc: FK to wlasciwosc_typ_podtyp_dziedzina
CREATE INDEX IX_wlasciwosc_wtpd ON dbo.wlasciwosc (wl_wtpd_id);

-- wlasciwosc_dluznik: FK joins
CREATE INDEX IX_wlasciwosc_dluznik_wl ON dbo.wlasciwosc_dluznik (wd_wl_id);
CREATE INDEX IX_wlasciwosc_dluznik_dl ON dbo.wlasciwosc_dluznik (wd_dl_id);

-- wlasciwosc_adres: FK joins
CREATE INDEX IX_wlasciwosc_adres_wl ON dbo.wlasciwosc_adres (wa_wl_id);
CREATE INDEX IX_wlasciwosc_adres_ad ON dbo.wlasciwosc_adres (wa_ad_id);

-- wlasciwosc_email: FK joins
CREATE INDEX IX_wlasciwosc_email_wl ON dbo.wlasciwosc_email (we_wl_id);
CREATE INDEX IX_wlasciwosc_email_ma ON dbo.wlasciwosc_email (we_ma_id);

-- wlasciwosc_telefon: FK joins
CREATE INDEX IX_wlasciwosc_telefon_wl ON dbo.wlasciwosc_telefon (wt_wl_id);
CREATE INDEX IX_wlasciwosc_telefon_tn ON dbo.wlasciwosc_telefon (wt_tn_id);

PRINT '>> All 37 staging indexes created.';
