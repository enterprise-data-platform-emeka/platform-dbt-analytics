# Makefile for platform-dbt-analytics
#
# All dbt commands run inside Docker so no local Python environment is required.
# Two services are defined in docker-compose.yml:
#   dbt-local  — DuckDB, reads Silver Parquet from ../platform-glue-jobs/data/silver/
#   dbt-aws    — Athena, reads from Glue Catalog, writes to S3 Gold bucket
#
# Usage examples:
#   make setup                  Build the Docker image
#   make run-local              Run dbt models against DuckDB
#   make test-local             Run dbt tests against DuckDB
#   make docs-local             Generate and serve dbt docs at http://localhost:8080
#   make deploy ENV=dev         Run dbt models against AWS Athena (dev environment)
#   make test-aws ENV=staging   Run dbt tests against AWS Athena (staging environment)
#   make clean                  Remove compiled artifacts and DuckDB database file

.PHONY: setup run-local test-local docs-local deploy test-aws clean

# Build the Docker image. Re-run this after changing requirements.txt or Dockerfile.
setup:
	docker compose build

# ---------------------------------------------------------------------------
# Local (DuckDB) targets
# ---------------------------------------------------------------------------

# Run all dbt models against DuckDB using the local Silver Parquet files.
# Downloads dbt packages first (dbt_utils, dbt_expectations) if not cached.
run-local:
	docker compose run --rm dbt-local \
		bash -c "dbt deps --profiles-dir profiles --profile edp_analytics --target local \
		         && dbt run --profiles-dir profiles --profile edp_analytics --target local"

# Run all dbt tests against DuckDB.
test-local:
	docker compose run --rm dbt-local \
		bash -c "dbt deps --profiles-dir profiles --profile edp_analytics --target local \
		         && dbt test --profiles-dir profiles --profile edp_analytics --target local"

# Generate dbt documentation and serve it at http://localhost:8080.
# Open your browser at http://localhost:8080 after this command starts.
docs-local:
	docker compose run --rm --service-ports dbt-local \
		bash -c "dbt deps --profiles-dir profiles --profile edp_analytics --target local \
		         && dbt docs generate --profiles-dir profiles --profile edp_analytics --target local \
		         && dbt docs serve --profiles-dir profiles --port 8080"

# ---------------------------------------------------------------------------
# AWS (Athena) targets
# ---------------------------------------------------------------------------

# Run dbt models against AWS Athena. Default ENV=dev. Pass ENV=staging or ENV=prod to override.
# Requires ATHENA_RESULTS_BUCKET to be set in your environment.
# Example: ATHENA_RESULTS_BUCKET=edp-dev-123456789-athena-results make deploy ENV=dev
deploy:
	ENV=$(or $(ENV),dev) docker compose run --rm dbt-aws \
		bash -c "dbt deps --profiles-dir profiles --profile edp_analytics --target $(or $(ENV),dev) \
		         && dbt run --profiles-dir profiles --profile edp_analytics --target $(or $(ENV),dev)"

# Run dbt tests against AWS Athena.
test-aws:
	ENV=$(or $(ENV),dev) docker compose run --rm dbt-aws \
		bash -c "dbt deps --profiles-dir profiles --profile edp_analytics --target $(or $(ENV),dev) \
		         && dbt test --profiles-dir profiles --profile edp_analytics --target $(or $(ENV),dev)"

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

# Remove dbt compiled artifacts, package cache, and the local DuckDB file.
clean:
	rm -rf target/ dbt_packages/ logs/
	rm -f /tmp/edp_analytics.duckdb /tmp/edp_analytics.duckdb.wal
	docker compose down --remove-orphans
