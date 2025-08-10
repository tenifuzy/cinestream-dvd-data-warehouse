# CineStream DVD Data Warehouse

A PostgreSQL-based dimensional data warehouse for CineStream DVD rental business, implementing star schema design to transform transactional data into actionable business insights.

## Overview

This project transforms a normalized DVD rental database into a dimensional data warehouse optimized for analytics and reporting. The warehouse enables analysis of customer behavior, inventory management, rental patterns, and store performance through fact and dimension tables following Kimball methodology.

## Architecture

### Dimensional Model
The data warehouse implements a **star schema** with the following components:

#### Dimension Tables
- **dim_customer** - Customer demographics and location information
- **dim_film** - Movie catalog with ratings, categories, and rental details
- **dim_staff** - Employee information with store assignments
- **dim_store** - Store locations with manager details
- **dim_date** - Time dimension with calendar attributes (2005-2030)

#### Fact Tables
- **fact_rental** - Core rental transactions with duration and overdue metrics
- **fact_payment** - Payment transactions linked to rentals
- **fact_daily_customer_activity** - Daily aggregated customer rental and payment activity
- **fact_daily_inventory_snapshot** - Daily inventory levels and availability by store/film

## Features

- **Dimensional Modeling**: Star schema design for optimal query performance
- **Data Transformation**: ETL processes converting normalized OLTP to dimensional OLAP
- **Time Intelligence**: Comprehensive date dimension with calendar hierarchies
- **Business Metrics**: Pre-calculated KPIs including rental duration, overdue tracking, and daily aggregations
- **Data Quality**: Foreign key constraints ensuring referential integrity
- **Scalable Design**: Supports historical data analysis and trend reporting

## Database Schema

```
dvddw (Data Warehouse Schema)
├── Dimensions
│   ├── dim_customer (Customer demographics)
│   ├── dim_film (Movie catalog)
│   ├── dim_staff (Employee data)
│   ├── dim_store (Store locations)
│   └── dim_date (Time dimension)
└── Facts
    ├── fact_rental (Rental transactions)
    ├── fact_payment (Payment records)
    ├── fact_daily_customer_activity (Daily customer metrics)
    └── fact_daily_inventory_snapshot (Daily inventory levels)
```

## Prerequisites

- PostgreSQL 12+
- Source DVD rental database (public schema)
- Database user with CREATE/INSERT privileges

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/cinestream-dvd-data-warehouse.git
   cd cinestream-dvd-data-warehouse
   ```

2. **Create data warehouse schema**
   ```sql
   CREATE SCHEMA dvddw;
   ```

3. **Execute dimension tables** (in order)
   ```bash
   psql -d your_database -f dvddw.dim_date.sql
   psql -d your_database -f dvddw.dim_customer.sql
   psql -d your_database -f dvddw.dim_film.sql
   psql -d your_database -f dvddw.dim_staff.sql
   psql -d your_database -f dvddw.dim_store.sql
   ```

4. **Execute fact tables** (after dimensions)
   ```bash
   psql -d your_database -f dvddw.fact_rental.sql
   psql -d your_database -f dvddw.fact_payment.sql
   psql -d your_database -f dvddw.fact_daily_customer_activity.sql
   psql -d your_database -f dvddw.fact_daily_inventory_snapshot.sql
   ```

## Usage Examples

### Customer Analysis
```sql
-- Top customers by rental activity
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    COUNT(f.rental_id) AS total_rentals,
    SUM(f.rental_amount) AS total_spent
FROM dvddw.fact_rental f
JOIN dvddw.dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, customer_name, c.city
ORDER BY total_rentals DESC;
```

### Inventory Management
```sql
-- Daily inventory levels by store
SELECT 
    s.city AS store_location,
    f.title,
    i.quantity_in_stock,
    i.quantity_rented
FROM dvddw.fact_daily_inventory_snapshot i
JOIN dvddw.dim_store s ON i.store_key = s.store_key
JOIN dvddw.dim_film f ON i.film_key = f.film_key
WHERE i.date_key = 20240115;
```

### Revenue Analysis
```sql
-- Monthly revenue trends
SELECT 
    d.year,
    d.month_name,
    SUM(p.amount) AS monthly_revenue,
    COUNT(p.payment_id) AS transaction_count
FROM dvddw.fact_payment p
JOIN dvddw.dim_date d ON p.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
```

## Key Business Metrics

- **Rental Duration**: Actual vs. expected rental periods
- **Overdue Tracking**: Days beyond return date
- **Customer Activity**: Daily rental and payment patterns
- **Inventory Utilization**: Stock levels and rental rates
- **Revenue Analysis**: Payment trends and store performance

## Data Lineage

The warehouse sources data from the public schema tables:
- `customer`, `address`, `city`, `country` → `dim_customer`
- `film`, `language`, `category`, `film_category` → `dim_film`
- `staff`, `store` → `dim_staff`
- `store`, `address`, `city`, `country` → `dim_store`
- Generated series → `dim_date`
- `rental`, `payment`, `inventory` → `fact_rental`
- `payment` → `fact_payment`
- Aggregated rentals/payments → `fact_daily_customer_activity`
- Inventory snapshots → `fact_daily_inventory_snapshot`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with sample data
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Olafusi Teniola** - Data Engineer

---

*This data warehouse enables CineStream to make data-driven decisions about inventory management, customer retention, and business growth through comprehensive analytics and reporting capabilities.*