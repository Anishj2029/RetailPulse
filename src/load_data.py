import pandas as pd
from sqlalchemy import create_engine
from pathlib import Path


# =====================================================
# CONFIGURATION
# =====================================================

BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DATA_DIR = BASE_DIR / "data" / "raw"

DB_USER = "root"
DB_PASSWORD = "123456789"
DB_HOST = "localhost"
DB_PORT = "3306"
DB_NAME = "retailpulse"

DATABASE_URL = (
    f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

engine = create_engine(DATABASE_URL)


# =====================================================
# HELPER FUNCTION
# =====================================================

def load_csv(filename):
    file_path = RAW_DATA_DIR / filename
    print(f"Reading {filename}...")
    return pd.read_csv(file_path)


# =====================================================
# LOAD DATA IN FOREIGN-KEY ORDER
# =====================================================

def main():

    print("Starting RetailPulse ETL pipeline...\n")

    customers = load_csv("olist_customers_dataset.csv")

    products = load_csv("olist_products_dataset.csv")

    # Fix column name spelling differences between CSV and MySQL
    products.rename(columns={
        "product_name_lenght": "product_name_length",
        "product_description_lenght": "product_description_length"
    }, inplace=True)

    sellers = load_csv("olist_sellers_dataset.csv")

    orders = load_csv("olist_orders_dataset.csv")

    order_items = load_csv("olist_order_items_dataset.csv")

    order_payments = load_csv("olist_order_payments_dataset.csv")

    category_translation = load_csv(
        "product_category_name_translation.csv"
    )

    print("\nCSV files loaded successfully.")

    # Convert date columns
    date_columns = [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ]

    for column in date_columns:
        orders[column] = pd.to_datetime(
            orders[column],
            errors="coerce"
        )

    order_items["shipping_limit_date"] = pd.to_datetime(
        order_items["shipping_limit_date"],
        errors="coerce"
    )

    # Insert into MySQL
    print("\nLoading customers...")
    customers.to_sql(
        "customers",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )

    print("Loading products...")
    products.to_sql(
        "products",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )

    print("Loading sellers...")
    sellers.to_sql(
        "sellers",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )

    print("Loading orders...")
    orders.to_sql(
        "orders",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )

    print("Loading order items...")
    order_items.to_sql(
        "order_items",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )

    print("Loading payments...")
    order_payments.to_sql(
        "order_payments",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )

    print("Loading category translations...")
    category_translation.to_sql(
        "product_category_translation",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )

    print("\nETL pipeline completed successfully!")


if __name__ == "__main__":
    main()