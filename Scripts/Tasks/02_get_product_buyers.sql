--------------------------------------- 2 ---------------------------------------
-- Отримати перелік і загальне число покупців, що купили зазначений вид товару --
-- за певний період або зробили покупку товару в обсязі, не менше заданого.    --
---------------------------------------------------------------------------------

--drop function get_product_buyers(int, int, date, date)
CREATE OR REPLACE FUNCTION get_product_buyers (
    product int,
    minimal_amount int DEFAULT 0,
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
        product_id = product
        AND p.purchase_time BETWEEN after_date AND before_date
        AND amount > minimal_amount;
END;
$$;

--examples
--SELECT (get_product_buyers (19)).*;
--SELECT (get_product_buyers (19, 2)).*;
