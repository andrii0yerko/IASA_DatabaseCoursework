--------------------------------------- 9 ---------------------------------------
-- Отримати відомості про поставки певного товару зазначеним постачальником за --
-- весь час поставок, або за деякий період.                                    --
---------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_product_supply (
    product int,
    supplier_name varchar,
    after_date date DEFAULT earliest_date('supply_date', 'supply'),
    before_date date DEFAULT latest_date('supply_date', 'supply')
)
    RETURNS TABLE (
            "supply_date" date,
            "supply_amount" int,
            "total_price" money,
            "supply_comment" text,
            "request_id" int,
            "request_date" date,
            "request_comment" text,
            "requested_amount" int,
            "destination_outlet" int
)
    LANGUAGE plpgsql
    AS $$
BEGIN

    RETURN query
    SELECT
        s.supply_date,
        s.amount,
        s.total_price,
        s.supply_comment,
        sr.supply_request_id,
        sr.request_date,
        sr.request_comment,
        sr.amount,
        sr.retail_outlet_id
    FROM
        supply s
        LEFT JOIN supply_request sr ON s.supply_id = sr.completed_by
    WHERE
        s.product_id = product
        AND s.supplier = supplier_name
        AND s.supply_date BETWEEN after_date AND before_date;
END;
$$

-- examples
--SELECT (get_product_supply (9, 'Yundt and Sons')).*;

