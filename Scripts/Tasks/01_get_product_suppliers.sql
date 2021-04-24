--------------------------------------- 1 ---------------------------------------
-- Отримати перелік і загальне число постачальників, що поставляють вказаний   --
-- вид товару, або деякий товар в обсязі, не менше заданого, за весь період    --
-- співпраці, або за вказаний період.                                          --
---------------------------------------------------------------------------------

--drop function get_product_suppliers(int, int, date, date)
CREATE OR REPLACE FUNCTION get_product_suppliers (
    product int,
    minimal_amount int DEFAULT 0,
    after_date date DEFAULT earliest_date('supply_date', 'supply'),
    before_date date DEFAULT latest_date('supply_date', 'supply')
)
    RETURNS TABLE (
            supplier varchar,
            most_recent_supply date
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    SELECT
        s.supplier,
        max(s.supply_date)
    FROM
        supply s
    WHERE
        product_id = product
        AND supply_date BETWEEN after_date
        AND before_date
        AND amount > minimal_amount
    GROUP BY
        s.supplier;
END;
$$


--examples
--SELECT (get_product_suppliers (19, 300)).*;
--SELECT (get_product_suppliers (19, 300, '2021-01-30')).*;
--SELECT (get_product_suppliers (after_date => '2021-01-30', product => 19)).*;