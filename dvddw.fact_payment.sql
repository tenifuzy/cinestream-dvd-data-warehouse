CREATE TABLE dvddw.fact_payment (
    payment_fact_id SERIAL PRIMARY KEY,
    payment_id INT NOT NULL UNIQUE,      -- Original source payment ID
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    staff_key INT NOT NULL,
    rental_id INT,                       -- Link back to original rental
    amount NUMERIC(5,2) NOT NULL,

    -- Foreign keys
    FOREIGN KEY (date_key) REFERENCES dvddw.dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dvddw.dim_customer(customer_key),
    FOREIGN KEY (staff_key) REFERENCES dvddw.dim_staff(staff_key)
);

INSERT INTO dvddw.fact_payment (
    payment_id,
    date_key,
    customer_key,
    staff_key,
    rental_id,
    amount
)
SELECT
    p.payment_id,
    -- Convert payment_date to date_key format (YYYYMMDD)
    TO_CHAR(p.payment_date, 'YYYYMMDD')::INT AS date_key,
    c.customer_key,
    s.staff_key,
    p.rental_id,
    p.amount
FROM
    public.payment p
JOIN
    dvddw.dim_customer c ON p.customer_id = c.customer_id
JOIN
    dvddw.dim_staff s ON p.staff_id = s.staff_id;