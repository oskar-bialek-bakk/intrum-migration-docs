-- ============================================================
-- staging_cross_db_objects.sql
--
-- Cross-database stored procedures extracted from staging.sql.
-- These procs reference dm_data_web_pipeline.dbo.* in static T-SQL
-- (procs 1 and 3) or via dynamic SQL (proc 2). They CANNOT be created
-- on an Azure SQL Database instance that does not host dm_data_web_pipeline.
--
-- Run order:
--   1. staging.sql                       (creates dm_staging structure)
--   2. create_staging_indexes.sql
--   3. staging_column_descriptions.sql
--   4. staging_cross_db_objects.sql      <-- THIS FILE, deferred until
--                                            both DBs are visible from
--                                            the same connection (e.g.
--                                            Managed Instance).
--
-- Procedures defined:
--   - dbo.usp_migrate_atrybut_wartosc    (static cross-DB refs)
--   - dbo.usp_migrate_wlasciwosc_domain  (dynamic SQL only)
--   - dbo.usp_manage_prod_ncis           (static cross-DB refs)
-- ============================================================

USE dm_staging;
GO

-- ============================================================
-- Shared procedure: migrate atrybut_wartosc by domain
-- Used by iter2 (att_atd_id=3, dluznik), iter4 (att_atd_id=4, sprawa),
-- iter6 (att_atd_id=2, wierzytelnosc), and iter7 (att_atd_id=1, dokument).
-- Caller MUST create #atw_mapping (staging_at_id BIGINT, prod_atw_id INT) before calling.
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
    OUTPUT CAST(inserted.atw_ext_id AS BIGINT), inserted.atw_id
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
    SELECT CAST(atw.atw_ext_id AS BIGINT), atw.atw_id
    FROM dm_data_web_pipeline.dbo.atrybut_wartosc atw WITH (NOLOCK)
    JOIN dbo.atrybut stg WITH (NOLOCK) ON atw.atw_ext_id = CAST(stg.at_id AS VARCHAR(100))
    JOIN dbo.atrybut_typ stg_att WITH (NOLOCK) ON stg_att.att_id = stg.at_att_id
    LEFT JOIN #atw_mapping am ON am.staging_at_id = CAST(atw.atw_ext_id AS BIGINT)
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
    @p_prod_entity_table       VARCHAR(200)  = NULL, -- e.g. 'adres' (in baza źródłowa, dbo)
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
    CREATE TABLE #wl_exist (entity_id BIGINT, wtpd_id INT);

    SET @sql = N'
        INSERT INTO #wl_exist (entity_id, wtpd_id)
        SELECT jt.' + QUOTENAME(@p_prod_join_entity_fk) + N', wl.wl_wtpd_id
        FROM dm_data_web_pipeline.dbo.' + QUOTENAME(@p_stg_join_table) + N' jt WITH (NOLOCK)
        JOIN dm_data_web_pipeline.dbo.wlasciwosc wl WITH (NOLOCK)
            ON wl.wl_id = jt.' + QUOTENAME(@p_prod_join_wl_fk) + N';';

    EXEC sp_executesql @sql;

    -- Step 4: MERGE into wlasciwosc (always INSERT via ON 1=0)
    CREATE TABLE #wl_map (staging_wl_id BIGINT, prod_wl_id INT);

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

PRINT 'staging_cross_db_objects.sql complete.';
GO
