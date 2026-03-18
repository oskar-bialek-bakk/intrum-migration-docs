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

-- sprawa_rola: REF_01, REF_02, BIZ_01
CREATE INDEX IX_sprawa_rola_sp_id   ON dbo.sprawa_rola (spr_sp_id);
CREATE INDEX IX_sprawa_rola_dl_id   ON dbo.sprawa_rola (spr_dl_id);

-- wierzytelnosc_rola: REF_04, REF_05, BIZ_01, BIZ_02b
CREATE INDEX IX_wierzytelnosc_rola_wi_id ON dbo.wierzytelnosc_rola (wir_wi_id);
CREATE INDEX IX_wierzytelnosc_rola_sp_id ON dbo.wierzytelnosc_rola (wir_sp_id);

-- wierzytelnosc: REF_06; critical for migration JOIN chain (wi_sp_id)
CREATE INDEX IX_wierzytelnosc_sp_id ON dbo.wierzytelnosc (wi_sp_id);

-- dokument: REF_07, REF_08, BIZ_02b
CREATE INDEX IX_dokument_wi_id  ON dbo.dokument (do_wi_id);
CREATE INDEX IX_dokument_dot_id ON dbo.dokument (do_dot_id);

-- adres: REF_09
CREATE INDEX IX_adres_dl_id ON dbo.adres (ad_dl_id);

-- telefon: REF_11
CREATE INDEX IX_telefon_dl_id ON dbo.telefon (tn_dl_id);

-- mail: REF_13
CREATE INDEX IX_mail_dl_id ON dbo.mail (ma_dl_id);

-- akcja: REF_14, REF_32, BIZ_08
CREATE INDEX IX_akcja_sp_id  ON dbo.akcja (ak_sp_id);
CREATE INDEX IX_akcja_akt_id ON dbo.akcja (ak_akt_id);

-- rezultat: REF_33, REF_34, BIZ_08
CREATE INDEX IX_rezultat_ak_id  ON dbo.rezultat (re_ak_id);
CREATE INDEX IX_rezultat_ret_id ON dbo.rezultat (re_ret_id);

-- atrybut: REF_15, REF_16-19, REF_28
-- Composite (at_atd_id, at_ob_id) covers per-domain NOT IN checks directly
CREATE INDEX IX_atrybut_atd_ob ON dbo.atrybut (at_atd_id, at_ob_id);
CREATE INDEX IX_atrybut_att_id ON dbo.atrybut (at_att_id);

-- ksiegowanie_dekret: REF_20, REF_21, REF_22, BIZ_02b, BIZ_05, BIZ_06
CREATE INDEX IX_ksd_ks_id  ON dbo.ksiegowanie_dekret (ksd_ks_id);
CREATE INDEX IX_ksd_ksk_id ON dbo.ksiegowanie_dekret (ksd_ksk_id);
CREATE INDEX IX_ksd_do_id  ON dbo.ksiegowanie_dekret (ksd_do_id);

-- operacja: REF_23, REF_27
CREATE INDEX IX_operacja_wi_id  ON dbo.operacja (oper_wi_id);
CREATE INDEX IX_operacja_waluta ON dbo.operacja (oper_waluta);

-- harmonogram: migration iter9 JOIN on hr_wi_id
CREATE INDEX IX_harmonogram_wi_id ON dbo.harmonogram (hr_wi_id);

-- waluta: REF_27 lookup by ISO currency code (wa_nazwa_skrocona is not PK)
CREATE INDEX IX_waluta_nazwa_skrocona ON dbo.waluta (wa_nazwa_skrocona);

PRINT '>> All 23 staging indexes created.';
