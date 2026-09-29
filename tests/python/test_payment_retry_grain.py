"""Exercise the real model SQL when an order has a failed payment retry."""
from pathlib import Path
import unittest

import duckdb
from jinja2 import Environment


class PaymentGrainTest(unittest.TestCase):
    def test_retry_does_not_duplicate_revenue(self):
        with duckdb.connect() as db:
            db.execute("""
                CREATE TABLE stg_orders AS SELECT 1 order_id, 1 customer_id,
                    DATE '2026-08-01' order_date, 'delivered' order_status,
                    2026 order_year, 8 order_month;
                CREATE TABLE stg_customers AS SELECT 1 customer_id, 'A' first_name,
                    'B' last_name, 'a@example.invalid' email, 'Germany' country;
                CREATE TABLE stg_payments AS SELECT * FROM (VALUES
                    (1, 1, 'card', 100, 'failed', DATE '2026-08-01'),
                    (2, 1, 'card', 100, 'completed', DATE '2026-08-02')
                ) AS p(payment_id, order_id, payment_method, amount, payment_status, payment_date);
                CREATE TABLE stg_shipments AS SELECT 1 order_id, 1 shipment_id,
                    'DHL' carrier, 'delivered' delivery_status,
                    DATE '2026-08-02' shipped_date, DATE '2026-08-04' delivered_date,
                    2 delivery_days;
            """)
            root = Path(__file__).resolve().parents[2]
            sql = Environment().from_string(
                (root / 'models/intermediate/int_orders_enriched.sql').read_text()
            ).render(ref=lambda name: name)
            result = db.execute(sql).fetchall()
            columns = [col[0] for col in db.description]
            self.assertEqual(len(result), 1)
            row = dict(zip(columns, result[0]))
            self.assertEqual(row['payment_id'], 2)
            self.assertEqual(row['payment_amount'], 100)
            self.assertEqual(row['payment_status'], 'completed')


if __name__ == '__main__':
    unittest.main()
