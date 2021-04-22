--------------------------------------- 6 ---------------------------------------
-- Отримати дані про продуктивність окремо взятого продавця окремо взятої      --
-- торговельної точки за вказаний період.                                      --
---------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_worker_productivity (
    _worker_id int,
    outlet int DEFAULT NULL,
    after_date date DEFAULT NULL,
    before_date date DEFAULT NULL
)
    RETURNS TABLE (
            worker_name varchar,
            number_of_sales int
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF outlet IS NULL THEN
        outlet := (
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
        (SELECT (get_workers_productivity (NULL, after_date, before_date)).*) AS s
    WHERE
        s.worker = _worker_id
        AND s.outlet_id = outlet;
END;
$$

-- examples
--SELECT (get_worker_productivity (15)).*;

