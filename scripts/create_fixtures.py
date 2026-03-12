"""
Create minimal Silver Parquet fixtures for CI.

Each Silver table gets one row of valid data so that dbt can resolve
read_parquet() sources and execute all staging/intermediate/mart models
without needing a real Glue run or AWS credentials.

Usage:
    python scripts/create_fixtures.py
"""

import pathlib
import pyarrow as pa
import pyarrow.parquet as pq

ROOT = pathlib.Path("data/silver")

FIXTURES = {
    "dim_customer": (
        pa.schema([
            pa.field("customer_id", pa.int64()),
            pa.field("first_name", pa.string()),
            pa.field("last_name", pa.string()),
            pa.field("email", pa.string()),
            pa.field("country", pa.string()),
            pa.field("phone", pa.string()),
            pa.field("signup_date", pa.date32()),
        ]),
        {
            "customer_id": [1],
            "first_name": ["Alice"],
            "last_name": ["Smith"],
            "email": ["alice@example.com"],
            "country": ["Germany"],
            "phone": ["+49123456789"],
            "signup_date": [19000],  # 2022-01-28 as days since epoch
        },
    ),
    "dim_product": (
        pa.schema([
            pa.field("product_id", pa.int64()),
            pa.field("name", pa.string()),
            pa.field("category", pa.string()),
            pa.field("brand", pa.string()),
            pa.field("unit_price", pa.float64()),
            pa.field("stock_qty", pa.int64()),
        ]),
        {
            "product_id": [1],
            "name": ["Widget A"],
            "category": ["Electronics"],
            "brand": ["BrandX"],
            "unit_price": [29.99],
            "stock_qty": [100],
        },
    ),
    "fact_orders": (
        pa.schema([
            pa.field("order_id", pa.int64()),
            pa.field("customer_id", pa.int64()),
            pa.field("order_date", pa.date32()),
            pa.field("order_status", pa.string()),
            pa.field("order_year", pa.int32()),
            pa.field("order_month", pa.int32()),
        ]),
        {
            "order_id": [1],
            "customer_id": [1],
            "order_date": [19000],
            "order_status": ["delivered"],
            "order_year": [2022],
            "order_month": [1],
        },
    ),
    "fact_order_items": (
        pa.schema([
            pa.field("order_item_id", pa.int64()),
            pa.field("order_id", pa.int64()),
            pa.field("product_id", pa.int64()),
            pa.field("quantity", pa.int64()),
            pa.field("unit_price", pa.float64()),
            pa.field("line_total", pa.float64()),
            pa.field("order_year", pa.int32()),
            pa.field("order_month", pa.int32()),
        ]),
        {
            "order_item_id": [1],
            "order_id": [1],
            "product_id": [1],
            "quantity": [2],
            "unit_price": [29.99],
            "line_total": [59.98],
            "order_year": [2022],
            "order_month": [1],
        },
    ),
    "fact_payments": (
        pa.schema([
            pa.field("payment_id", pa.int64()),
            pa.field("order_id", pa.int64()),
            pa.field("method", pa.string()),
            pa.field("amount", pa.float64()),
            pa.field("status", pa.string()),
            pa.field("payment_date", pa.date32()),
            pa.field("payment_year", pa.int32()),
            pa.field("payment_month", pa.int32()),
        ]),
        {
            "payment_id": [1],
            "order_id": [1],
            "method": ["credit_card"],
            "amount": [59.98],
            "status": ["completed"],
            "payment_date": [19000],
            "payment_year": [2022],
            "payment_month": [1],
        },
    ),
    "fact_shipments": (
        pa.schema([
            pa.field("shipment_id", pa.int64()),
            pa.field("order_id", pa.int64()),
            pa.field("carrier", pa.string()),
            pa.field("delivery_status", pa.string()),
            pa.field("shipped_date", pa.date32()),
            pa.field("delivered_date", pa.date32()),
            pa.field("delivery_days", pa.int32()),
            pa.field("shipped_year", pa.int32()),
            pa.field("shipped_month", pa.int32()),
        ]),
        {
            "shipment_id": [1],
            "order_id": [1],
            "carrier": ["DHL"],
            "delivery_status": ["delivered"],
            "shipped_date": [19000],
            "delivered_date": [19003],
            "delivery_days": [3],
            "shipped_year": [2022],
            "shipped_month": [1],
        },
    ),
}


def main() -> None:
    for table_name, (schema, data) in FIXTURES.items():
        dest = ROOT / table_name
        dest.mkdir(parents=True, exist_ok=True)
        table = pa.table(data, schema=schema)
        pq.write_table(table, dest / "fixture.parquet")
        print(f"  wrote {dest}/fixture.parquet  ({table.num_rows} row)")

    print("All fixtures created.")


if __name__ == "__main__":
    main()
