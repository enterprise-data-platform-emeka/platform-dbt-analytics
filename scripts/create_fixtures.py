"""
Create minimal Silver Parquet fixtures for CI.

Each Silver table gets one row of valid data so that dbt can resolve
read_parquet() sources and execute all staging/intermediate/mart models
without needing a real Glue run or AWS credentials.

Uses DuckDB (installed as part of dbt-duckdb) — no extra dependencies.

Usage:
    python scripts/create_fixtures.py
"""

import pathlib
import duckdb

ROOT = pathlib.Path("data/silver")

TABLES = {
    "dim_customer": """
        SELECT
            1::BIGINT        AS customer_id,
            'Alice'          AS first_name,
            'Smith'          AS last_name,
            'alice@example.com' AS email,
            'Germany'        AS country,
            '+49123456789'   AS phone,
            DATE '2022-01-28' AS signup_date
    """,
    "dim_product": """
        SELECT
            1::BIGINT        AS product_id,
            'Widget A'       AS name,
            'Electronics'    AS category,
            'BrandX'         AS brand,
            29.99::DOUBLE    AS unit_price,
            100::BIGINT      AS stock_qty
    """,
    "fact_orders": """
        SELECT
            1::BIGINT        AS order_id,
            1::BIGINT        AS customer_id,
            DATE '2022-01-28' AS order_date,
            'delivered'      AS order_status,
            2022::INTEGER    AS order_year,
            1::INTEGER       AS order_month
    """,
    "fact_order_items": """
        SELECT
            1::BIGINT        AS order_item_id,
            1::BIGINT        AS order_id,
            1::BIGINT        AS product_id,
            2::BIGINT        AS quantity,
            29.99::DOUBLE    AS unit_price,
            59.98::DOUBLE    AS line_total,
            2022::INTEGER    AS order_year,
            1::INTEGER       AS order_month
    """,
    "fact_payments": """
        SELECT
            1::BIGINT        AS payment_id,
            1::BIGINT        AS order_id,
            'credit_card'    AS method,
            59.98::DOUBLE    AS amount,
            'completed'      AS status,
            DATE '2022-01-28' AS payment_date,
            2022::INTEGER    AS payment_year,
            1::INTEGER       AS payment_month
    """,
    "fact_shipments": """
        SELECT
            1::BIGINT        AS shipment_id,
            1::BIGINT        AS order_id,
            'DHL'            AS carrier,
            'delivered'      AS delivery_status,
            DATE '2022-01-28' AS shipped_date,
            DATE '2022-01-31' AS delivered_date,
            3::INTEGER       AS delivery_days,
            2022::INTEGER    AS shipped_year,
            1::INTEGER       AS shipped_month
    """,
}


def main() -> None:
    con = duckdb.connect()
    for table_name, query in TABLES.items():
        dest = ROOT / table_name
        dest.mkdir(parents=True, exist_ok=True)
        out = str(dest / "fixture.parquet")
        con.execute(f"COPY ({query}) TO '{out}' (FORMAT PARQUET)")
        print(f"  wrote {out}")
    con.close()
    print("All fixtures created.")


if __name__ == "__main__":
    main()
