--------------------------------------- 14 ---------------------------------------
-- Отримати відомості про найбільш активних покупців по всіх торгових точках,   --
-- по торговим точкам зазначеного типу, по даній торговій точці.                --
----------------------------------------------------------------------------------

-- for all outlets
CREATE OR REPLACE FUNCTION get_buyers_activity ()
    RETURNS TABLE (
            customer_id int,
            customer_name varchar,
            customer_phone varchar,
            purchase_number int,
            money_spent money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query SELECT
        c.customer_id,
        c.full_name,
        c.phone,
        count(p.purchase_id)::int,
        sum(total_price) AS money_spent
    FROM
        purchase p
        JOIN customer c ON p.customer_id = c.customer_id
    GROUP BY
        c.customer_id, c.full_name, c.phone
    ORDER BY
        money_spent DESC;
END;
$$

-- for specific outlet
CREATE OR REPLACE FUNCTION get_buyers_activity (outlet int)
    RETURNS TABLE (
            customer_id int,
            customer_name varchar,
            customer_phone varchar,
            purchase_number int,
            money_spent money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query SELECT
        c.customer_id,
        c.full_name,
        c.phone,
        count(p.purchase_id)::int,
        sum(total_price) AS money_spent
    FROM
        purchase p
        JOIN customer c ON p.customer_id = c.customer_id
    WHERE
        p.retail_outlet_id = outlet
        OR p.retail_outlet_id IN (
            SELECT ro.retail_outlet_id
            FROM retail_outlet ro
            WHERE ro.part_of = outlet)
    GROUP BY
        c.customer_id, c.full_name, c.phone
    ORDER BY
        money_spent DESC;
END;
$$

-- for specific outlet type
CREATE OR REPLACE FUNCTION get_buyers_activity (_outlet_type varchar)
    RETURNS TABLE (
            customer_id int,
            customer_name varchar,
            customer_phone varchar,
            purchase_number int,
            money_spent money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query SELECT
        c.customer_id,
        c.full_name,
        c.phone,
        count(p.purchase_id)::int,
        sum(total_price) AS money_spent
    FROM
        purchase p
        JOIN customer c ON p.customer_id = c.customer_id
        JOIN retail_outlet ro ON ro.retail_outlet_id = p.retail_outlet_id 
    WHERE
        ro.outlet_type = _outlet_type
    GROUP BY
        c.customer_id, c.full_name, c.phone
    ORDER BY
        money_spent DESC;
END;
$$

-- examples
--SELECT (get_buyers_activity()).*;
--SELECT (get_buyers_activity(5)).*;
--SELECT (get_buyers_activity('Mart Section')).*;