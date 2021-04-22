--------------------------------------- 7 ---------------------------------------
-- Отримати дані про обсяг продажів зазначеного товару за певний період по     --
-- всіх торгових точках, по торговим точкам заданого типу, по конкретній       --
-- торговій точці.                                                             --
---------------------------------------------------------------------------------
--drop function get_product_sales(int, varchar, date, date);


-- for specific outlet type
CREATE OR REPLACE FUNCTION get_product_sales (
    product int,
    _outlet_type varchar,
    after_date date DEFAULT earliest_date('purchase_time', 'purchase'),
    before_date date DEFAULT latest_date('purchase_time', 'purchase')
)
    RETURNS TABLE (
            total_amount int,
            total_revenues money,
            avg_amount_in_purchase numeric,
            avg_price money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    SELECT
        sum(p.amount)::int,
        sum(p.total_price),
        round(avg(p.amount), 2),
        sum(p.total_price) / sum(p.amount)
    FROM
        purchase p
        JOIN retail_outlet ro ON p.retail_outlet_id = ro.retail_outlet_id
    WHERE
        p.purchase_time BETWEEN after_date AND before_date
        AND p.product_id = product
        AND ro.outlet_type = _outlet_type;
END;
$$


-- for specific outlet
CREATE OR REPLACE FUNCTION get_product_sales (
    product int,
    outlet int,
    after_date date DEFAULT earliest_date('purchase_time', 'purchase'),
    before_date date DEFAULT latest_date('purchase_time', 'purchase')
)
    RETURNS TABLE (
            total_amount int,
            total_revenues money,
            avg_amount_in_purchase numeric,
            avg_price money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    SELECT
        sum(p.amount)::int,
        sum(p.total_price),
        round(avg(p.amount), 2),
        sum(p.total_price) / sum(p.amount)
    FROM
        purchase p
    WHERE
        p.purchase_time BETWEEN after_date AND before_date
        AND p.product_id = product
        AND (p.retail_outlet_id = outlet
            OR p.retail_outlet_id IN (
                SELECT ro.retail_outlet_id
                FROM retail_outlet ro
                WHERE ro.part_of = outlet));
END;
$$


-- for all outlets
CREATE OR REPLACE FUNCTION get_product_sales (
    product int,
    after_date date DEFAULT earliest_date('purchase_time', 'purchase'),
    before_date date DEFAULT latest_date('purchase_time', 'purchase')
)
    RETURNS TABLE (
            total_amount int,
            total_revenues money,
            avg_amount_in_purchase numeric,
            avg_price money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    SELECT
        sum(p.amount)::int,
        sum(p.total_price),
        round(avg(p.amount), 2),
        sum(p.total_price) / sum(p.amount)
    FROM
        purchase p
    WHERE
        p.purchase_time BETWEEN after_date AND before_date
        AND p.product_id = product;
END;
$$

-- examples
--SELECT (get_product_sales (2, 'Kiosk')).*;
--SELECT (get_product_sales (2, 'Mart Section')).*;
--SELECT (get_product_sales (2, 1)).*;
--SELECT (get_product_sales (2)).*;

