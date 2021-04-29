--------------------------------------- 12 ---------------------------------------
-- отримати відомості про поставки товарів за вказаним номером замовлення.      --
----------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_supply_by_request (
    request_id int
)
    RETURNS TABLE (
            "request_date" date,
            "request_comment" text,
            "requested_amount" int,
            "destination_outlet" int,
            "supplier" varchar,
            "supply_date" date,
            "supply_amount" int,
            "total_price" money,
            "supply_comment" text
)
    LANGUAGE plpgsql
    AS $$
DECLARE
    is_open bool;
BEGIN
    is_open := (
        SELECT
            NOT sr2.is_completed
        FROM
            supply_request sr2
        WHERE
            sr2.supply_request_id = request_id);
    IF is_open THEN
        RETURN query
        SELECT
            sr.request_date,
            sr.request_comment,
            sr.amount,
            sr.retail_outlet_id,
            'still open'::varchar,
            NULL::date,
            NULL::int,
            NULL::money,
            NULL::text
        FROM
            supply_request sr
        WHERE
            sr.supply_request_id = request_id;
    ELSE
        RETURN query
        SELECT
            sr.request_date,
            sr.request_comment,
            sr.amount,
            sr.retail_outlet_id,
            s.supplier,
            s.supply_date,
            s.amount,
            s.total_price,
            s.supply_comment
        FROM
            supply_request sr
            JOIN supply s ON sr.completed_by = s.supply_id
        WHERE
            sr.supply_request_id = request_id;
    END IF;
END;
$$;


-- examples
--SELECT (get_supply_by_request (9)).*;

