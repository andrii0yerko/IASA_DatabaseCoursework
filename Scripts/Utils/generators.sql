-- I came here to chew bubblegum and write generators with sql, but im all out of bubblegum

-- Some horrible data generators that will fill tables with consistent data are placed below.
-- Tables worker, retail_outlet, products_description, products_availability and customer should be alreby filled using insert scripts
-- Also, there is some hard-code stuff, so if you'll use it (I hope you won't), be carefull 




-- generating data for public.purchase table 
 WITH tmp AS (
    -- Sonic says... if you want to create more data, use union all!
    SELECT
        product_id,
        retail_outlet_id,
        floor(random() * 5 + 1)::int AS amount,
        price,
        (date '2021-04-01' + random() * INTERVAL '1 month') :: date AS purchase_date,
        floor(random() * 100 + 1)::int AS random_col
        -- used for adding customer_id using join
    
        FROM products_availability
    WHERE
        retail_outlet_id <= 6
        -- supposing that id's <= 6 are not kiosks, and >6 are. According to the task, kiosks cannot receive customer info
    UNION ALL
    SELECT
        product_id,
        retail_outlet_id,
        floor(random() * 5 + 1)::int AS amount,
        price,
        (timestamp '2021-04-01 00:00' + random() * INTERVAL '1 month') :: timestamp AS purchase_date,
        floor(random() * 100 + 1)::int AS random_col
    FROM
        products_availability
    WHERE
        retail_outlet_id <= 6
    UNION ALL
    SELECT
        product_id,
        retail_outlet_id,
        floor(random() * 5 + 1)::int AS amount,
        price,
        (timestamp '2021-04-01 00:00' + random() * INTERVAL '1 month') :: timestamp AS purchase_date,
        0 AS random_col
    FROM
        products_availability
    WHERE
        retail_outlet_id >= 6
    UNION ALL
    SELECT
        product_id,
        retail_outlet_id,
        floor(random() * 5 + 1)::int AS amount,
        price,
        (timestamp '2021-04-01 00:00' + random() * INTERVAL '1 month') :: timestamp AS purchase_date,
        0 AS random_col
    FROM
        products_availability
    WHERE
        retail_outlet_id >= 6
    UNION ALL
    SELECT
        product_id,
        retail_outlet_id,
        floor(random() * 5 + 1)::int AS amount,
        price,
        (timestamp '2021-04-01 00:00' + random() * INTERVAL '1 month') :: timestamp AS purchase_date,
        0 AS random_col
    FROM
        products_availability
    WHERE
        retail_outlet_id >= 6 ),
tmp_customers AS (
    -- just customer_id with random int
    SELECT
        customer_id,
        floor(random() * 30 + 2)::int AS random_col
    FROM
        customer )
INSERT
    INTO
    public.purchase(product_id,
    amount,
    total_price,
    purchase_time,
    customer_id,
    retail_outlet_id,
    worker_id)
SELECT
    product_id,
    amount,
    amount*price::NUMERIC::money AS total_price,
    purchase_date,
    customer_id,
    t.retail_outlet_id,
    worker_id
FROM
    (tmp
LEFT JOIN tmp_customers ON
    tmp.random_col = tmp_customers.random_col) t
JOIN worker ON
    t.retail_outlet_id = worker.retail_outlet_id
WHERE
    worker_id > 5
    AND random() < 0.1
    -- supposing id>5 are not managers, random is just to reduce the number of rows
    ORDER BY purchase_date;






-- generating data for public.supply table

DROP TABLE IF EXISTS temp_supplier_names;
CREATE TEMPORARY TABLE temp_supplier_names (
	id int,
    supplier_name varchar
);
INSERT INTO temp_supplier_names (id, supplier_name) VALUES (1, 'Flatley, Zulauf and Sawayn');
INSERT INTO temp_supplier_names (id, supplier_name) VALUES (2, 'Upton LLC');
INSERT INTO temp_supplier_names (id, supplier_name) VALUES (3, 'Raynor Group');
INSERT INTO temp_supplier_names (id, supplier_name) VALUES (4, 'Paucek-Homenick');
INSERT INTO temp_supplier_names (id, supplier_name) VALUES (5, 'VonRueden LLC');
INSERT INTO temp_supplier_names (id, supplier_name) VALUES (6, 'Yundt and Sons');


-- sums product amounts in purchase and products_availability tables, and counting an average price
 WITH purchase_sum AS (
    SELECT
        product_id,
        SUM(amount) AS amount,
        SUM(total_price::NUMERIC::float8) / SUM(amount) AS price
    FROM
        purchase
    GROUP BY
        product_id ),
availibilty_sum AS (
    SELECT
        product_id,
        SUM(amount) AS amount
    FROM
        products_availability
    GROUP BY
        product_id )
SELECT
    p.product_id,
    p.amount + a.amount AS "amount",
    ROUND((p.price * 0.8) ::NUMERIC,
    2) AS price
INTO
    temp_amount_price
FROM
    purchase_sum p
JOIN availibilty_sum a ON
    p.product_id = a.product_id;

WITH cte_amount_price AS (
    -- divide each product supply into two equal parts to make table bigger
    SELECT
        product_id,
        ROUND(amount / 2) AS amount,
        price,
        floor(random() * 6 + 1)::int AS supplier_id
    FROM
        temp_amount_price
    UNION ALL
    SELECT
        product_id,
        ROUND((amount + 1)/ 2),
        price,
        floor(random() * 6 + 1)::int
    FROM
        temp_amount_price )
INSERT
    INTO
    public.supply (manager_id,
    supplier,
    product_id,
    amount,
    total_price,
    supply_date)
SELECT
    floor(random() * 4 + 1)::int AS manager_id ,
    sn.supplier_name AS supplier ,
    product_id ,
    amount ,
    amount*price::NUMERIC::money AS total_price ,
    (date '2020-10-10' + random() * INTERVAL '5 month') :: date AS supply_date
FROM
    cte_amount_price
JOIN temp_supplier_names AS sn ON
    cte_amount_price.supplier_id = sn.id
ORDER BY
    supply_date;

DROP TABLE IF EXISTS temp_amount_price;






-- generating data for public.supply_request table

-- reducing amount and taking earlier date for each record in supply table
    WITH cte AS (
    SELECT
        retail_outlet_id,
        s.product_id,
        ROUND(s.amount / 10)* 10 AS amount,
        (supply_date - random() * INTERVAL '2 week') :: date AS request_date,
        TRUE AS is_completed,
        s.supply_id AS completed_by
    FROM
        supply s
    JOIN products_availability pa ON
        s.product_id = pa.product_id )
INSERT
    INTO
    supply_request(worker_id,
    retail_outlet_id,
    product_id,
    amount,
    request_date,
    is_completed,
    completed_by)
SELECT
    (
        SELECT worker_id
        FROM worker
        WHERE retail_outlet_id = cte.retail_outlet_id
        ORDER BY random()
        LIMIT 1
    ) AS worker_id,
    cte.*
FROM
    cte
ORDER BY
    request_date;