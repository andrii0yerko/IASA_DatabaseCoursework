--------------------------------------- 5 ---------------------------------------
-- Отримати дані про продуктивність одного продавця за вказаний період по всіх --
-- торгових точках, по торговим точкам заданого типу.                          --
---------------------------------------------------------------------------------

--drop function get_workers_productivity;
CREATE OR REPLACE FUNCTION get_workers_productivity (
    _outlet_type varchar DEFAULT NULL,
    after_date date DEFAULT earliest_date('purchase_time', 'purchase'),
    before_date date DEFAULT latest_date('purchase_time', 'purchase')
)
    RETURNS TABLE (
            outlet_id int,
            worker int,
            worker_name varchar,
            number_of_sales int
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DROP TABLE IF EXISTS outlets;
    CREATE TEMPORARY TABLE outlets (
        id int
    );
    IF _outlet_type IS NOT NULL THEN
        INSERT INTO outlets
        SELECT
            retail_outlet_id
        FROM
            retail_outlet ro
        WHERE
            ro.outlet_type = _outlet_type;
    ELSE
        INSERT INTO outlets
        SELECT
            retail_outlet_id
        FROM
            retail_outlet;
    END IF;
    RETURN query SELECT DISTINCT
        p.retail_outlet_id,
        p.worker_id,
        w.full_name,
        count(p.purchase_id)::int
    FROM
        purchase p
        JOIN worker w ON p.worker_id = w.worker_id
    WHERE
        p.purchase_time BETWEEN after_date AND before_date
        AND worker_position IN ('Seller', 'Consultant')
    GROUP BY
        p.worker_id, p.retail_outlet_id, w.full_name
    HAVING (p.retail_outlet_id IN (
            SELECT id
            FROM outlets
            )
            OR p.retail_outlet_id IN (
                SELECT retail_outlet_id
                FROM retail_outlet
                WHERE
                    part_of IN (
                        SELECT id
                        FROM outlets
                    )));
END;
$$

-- examples
--SELECT (get_workers_productivity ()).*;
--SELECT (get_workers_productivity ('Kiosk')).*;
