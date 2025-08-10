CREATE TABLE dvddw.dim_film (
    film_key SERIAL PRIMARY KEY,
    film_id INT NOT NULL UNIQUE,  -- Original source ID
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year SMALLINT,
    language VARCHAR(28) NOT NULL,
    rental_duration SMALLINT NOT NULL,
    rental_rate NUMERIC(4,2) NOT NULL,
    length SMALLINT,
    replacement_cost NUMERIC(5,2) NOT NULL,
    rating VARCHAR(26),
    special_features TEXT,
    category_name VARCHAR(25) NOT NULL
);

-- Populate dvddw.dim_film
INSERT INTO dvddw.dim_film (
    film_id, title, description, release_year, language, rental_duration,
    rental_rate, length, replacement_cost, rating, special_features, category_name
)
SELECT
    f.film_id,
    f.title,
    f.description,
    f.release_year,
    l.name AS language,
    f.rental_duration,
    f.rental_rate,
    f.length,
    f.replacement_cost,
    f.rating::VARCHAR(20) AS rating,  -- Cast ENUM to VARCHAR
    f.special_features,
    c.name AS category_name
FROM
    public.film AS f
JOIN
    public.language AS l ON f.language_id = l.language_id
JOIN
    public.film_category AS fc ON f.film_id = fc.film_id
JOIN
    public.category AS c ON fc.category_id = c.category_id;
