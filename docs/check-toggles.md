# Toggle Configuration

## What this is

Each migration run reads a JSON file that controls which validation and KPI checks are active for *your* migration. By default, every check runs. You opt out of specific checks by editing the JSON via PR.

## File location

`config/check_toggles.json` in this repository (intrum-migration-docs).

## Editing workflow

1. Open a PR on this repo modifying `config/check_toggles.json`.
2. Wait for review and merge.
3. The next migration run picks up your edits automatically (the pipeline fetches this file at run time).

## JSON shape

The file is a JSON object. Keys are short check IDs (e.g. `REF_01`, `KPI_SUM_02`). Values are objects with at minimum an `enabled` boolean.

```json
{
  "REF_01":     { "enabled": false, "reason": "client X accepts known orphan sprawa_rola rows; cleanup planned post-migration" },
  "KPI_SUM_02": { "enabled": false, "reason": "FX rounding tolerance exceeds proportional 0.001% threshold; reviewed and accepted" },
  "KPI_ANO_03": { "enabled": false }
}
```

- **Default:** every check is enabled. The empty object `{}` means "all checks run."
- **`enabled: true`** is allowed but redundant.
- **Missing key** = enabled (same as `enabled: true`).
- **Unknown key** = warning, ignored (probably a stale entry after a check rename).

## The reason field

Some checks require a non-empty `reason` to disable. Specifically:

- **BLOCKING validations** (REF_*, most STR_*, most BIZ_*) — disabling requires a reason because these protect against data integrity violations that would normally halt the migration.
- **CRITICAL KPIs** (KPI_CNT_*, KPI_SUM_*) — disabling requires a reason because these confirm the migration produced the expected counts and totals.
- **INFO-severity checks** (KPI_ANO_*, some FMT_* and STR_*) — no reason required, though it's good practice to explain.

If you try to disable a BLOCKING/CRITICAL check without a reason, the pipeline will refuse to start. Fix the JSON and re-run.

## How skipped checks appear in reports

Disabled checks are NOT silently omitted. They appear in:

- `log.validation_result` rows with `affected_count IS NULL` and `detail` starting with `'SKIPPED: <your reason>'`.
- `log.postmigration_check` rows with `pass IS NULL` and `note` starting with `'SKIPPED: <your reason>'`.
- The post-migration report cursor renders them as `SKIP` (vs `PASS`/`FAIL`).

This means an audit can always answer "was this check actually run, or was it intentionally skipped?"

## Audit trail

Every migration run records:

- The SHA-256 hash of the JSON file actually used (`log.migration_run.toggle_config_hash`).
- When it was fetched (`toggle_config_fetched_at`).
- Where it came from (`toggle_config_source`: `remote` / `file` / `env` / `cache`).

To reproduce or audit a past run, find that hash, then `git log -p config/check_toggles.json` in this repo and find the commit whose file body matches the hash.

## Catalog of available checks

See [check-toggles-catalog.md](check-toggles-catalog.md) for the full list of `short_id`s, their kind, severity, and one-line description.
