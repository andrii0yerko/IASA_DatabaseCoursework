--------------------------------------- 13 ---------------------------------------
-- Отримати відомості про покупців зазначеного товару по заданому періоду, або  --
-- за весь період, по всіх торгових точках, по торговим точкам зазначеного типу,--
-- по даній торговій точці.                                                     --
----------------------------------------------------------------------------------
--DROP FUNCTION get_product_buyers_by_outlet

-- for specific outlet
CREATE OR REPLACE FUNCTION get_product_buyers_by_outlet (
    product int,
    outlet int,
    after_date date DEFAULT earliest_date('purchase_time', 'purchase'),
    before_date date DEFAULT latest_date('purchase_time', 'purchase')
)
    RETURNS TABLE (
            customer_id int,
            customer_name varchar,
            customer_phone varchar
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query SELECT DISTINCT
        p.customer_id,
        c.full_name,
        c.phone
    FROM
        purchase p
        JOIN customer c ON p.customer_id = c.customer_id
    WHERE
        p.purchase_time BETWEEN after_date AND before_date
        AND product_id = product
        AND (p.retail_outlet_id = outlet
            OR p.retail_outlet_id IN (
                SELECT ro.retail_outlet_id
                FROM retail_outlet ro
                WHERE ro.part_of = outlet)
            );
END;
$$

-- for specific outlet type
CREATE OR REPLACE FUNCTION get_product_buyers_by_outlet (
    product int,
    outlet varchar,
    after_date date DEFAULT earliest_date('purchase_time', 'purchase'),
    before_date date DEFAULT latest_date('purchase_time', 'purchase')
)
    RETURNS TABLE (
            customer_id int,
            customer_name varchar,
            customer_phone varchar
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query SELECT DISTINCT
        p.customer_id,
        c.full_name,
        c.phone
    FROM
        purchase p
        JOIN customer c ON p.customer_id = c.customer_id
        JOIN retail_outlet ro ON ro.retail_outlet_id = p.retail_outlet_id
    WHERE
        p.purchase_time BETWEEN after_date AND before_date
        AND product_id = product
        AND ro.outlet_type = outlet;
END;
$$

-- examples
--SELECT (get_product_buyers_by_outlet(2, 2)).*;
--SELECT (get_product_buyers_by_outlet(2, 'Mart Section')).*;