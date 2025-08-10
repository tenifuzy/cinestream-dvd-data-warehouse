CREATE TABLE dvddw.fact_daily_inventory_snapshot (
    inventory_snapshot_fact_id SERIAL PRIMARY KEY,
    date_key INT NOT NULL,
    store_key INT NOT NULL,
    film_key INT NOT NULL,
    inventory_id INT NOT NULL,
    quantity_in_stock SMALLINT NOT NULL,
    quantity_rented SMALLINT NOT NULL,
    -- Foreign keys
    FOREIGN KEY (date_key) REFERENCES dvddw.dim_date(date_key),
    FOREIGN KEY (store_key) REFERENCES dvddw.dim_store(store_key),
    FOREIGN KEY (film_key) REFERENCES dvddw.dim_film(film_key)
);

INSERT INTO dvddw.fact_daily_inventory_snapshot (
    date_key, store_key, film_key, inventory_id, quantity_in_stock, quantity_rented
)
SELECT
    dd.date_key,
    ds.store_key,
    df.film_key,
    i.inventory_id,
    -- Quantity in stock: total inventory - rented items not yet returned
    COUNT(i.inventory_id) 
        - SUM(CASE WHEN r.return_date IS NULL OR r.return_date::date > dd.full_date
                   THEN 1 ELSE 0 END) AS quantity_in_stock,
    -- Quantity rented: rented and not returned by snapshot date
    SUM(CASE WHEN r.rental_date::date <= dd.full_date 
              AND (r.return_date IS NULL OR r.return_date::date > dd.full_date)
             THEN 1 ELSE 0 END) AS quantity_rented
FROM
    dvddw.dim_date dd
CROSS JOIN public.inventory i
JOIN dvddw.dim_store ds ON i.store_id = ds.store_id
JOIN dvddw.dim_film df ON i.film_id = df.film_id
LEFT JOIN public.rental r ON i.inventory_id = r.inventory_id
    AND r.rental_date::date <= dd.full_date
GROUP BY
    dd.date_key, ds.store_key, df.film_key, i.inventory_id;

