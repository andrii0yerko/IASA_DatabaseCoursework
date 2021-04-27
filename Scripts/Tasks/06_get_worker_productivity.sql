--------------------------------------- 6 ---------------------------------------
-- Отримати дані про продуктивність окремо взятого продавця окремо взятої      --
-- торговельної точки за вказаний період.                                      --
---------------------------------------------------------------------------------

--DROP FUNCTION get_worker_productivity
CREATE OR REPLACE FUNCTION get_worker_productivity (
    _worker_id int,
    _outlet_id int DEFAULT NULL,
    after_date date DEFAULT earliest_date('purchase_time', 'purchase'),
    before_date date DEFAULT latest_date('purchase_time', 'purchase')
)
    RETURNS TABLE (
            worker_name varchar,
            number_of_sales int
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    
    IF _outlet_id IS NULL THEN
        _outlet_id := (
            SELECT
                retail_outlet_id
            FROM
                worker
            WHERE
                worker_id = _worker_id);
    END IF;
    RETURN query
    SELECT
        s.worker_name,
        s.number_of_sales
    FROM
        get_workers_productivity(NULL, after_date, before_date) AS s
    WHERE
        s.worker = _worker_id
        AND s.outlet_id = _outlet_id;
END;
$$

get_workers_productivity(NULL,)
-- examples
--SELECT (get_worker_productivity (15)).*;

