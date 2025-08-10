CREATE TABLE dvddw.fact_daily_customer_activity (
    customer_activity_fact_id SERIAL PRIMARY KEY,
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    total_rentals_day INT NOT NULL DEFAULT 0,
    total_payments_day NUMERIC(5,2) NOT NULL DEFAULT 0.00,
    -- Foreign Keys
    FOREIGN KEY (date_key) REFERENCES dvddw.dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dvddw.dim_customer(customer_key),
	UNIQUE (date_key, customer_key)
);

-- Populate dvddw.fact_daily_customer_activity
INSERT INTO dvddw.fact_daily_customer_activity (
    date_key, customer_key, total_rentals_day, total_payments_day
)
SELECT 
    dd.date_key,
    dc.customer_key,
    COUNT(r.rental_id) AS total_rentals_day,
    COALESCE(SUM(p.amount), 0.00) AS total_payments_day
FROM public.rental AS r
JOIN dvddw.dim_customer AS dc 
    ON r.customer_id = dc.customer_id
JOIN dvddw.dim_date AS dd
    ON dd.full_date = DATE(r.rental_date)  -- link rental date to date dimension
LEFT JOIN public.payment AS p 
    ON r.rental_id = p.rental_id
    AND DATE(p.payment_date) = DATE(r.rental_date)
GROUP BY 
    dd.date_key, dc.customer_key
ORDER BY 
    dd.date_key, dc.customer_key;
