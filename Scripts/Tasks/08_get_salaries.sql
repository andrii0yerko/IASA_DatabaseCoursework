--------------------------------------- 8 ---------------------------------------
-- Отримати дані про заробітну плату продавців по всіх торгових точках, по     --
-- торговим точкам заданого типу, по конкретній торговій точці.                --
---------------------------------------------------------------------------------

-- drop function get_salaries()

-- for specific outlet
CREATE OR REPLACE FUNCTION get_salaries (outlet int)
    RETURNS TABLE (
            "worker_name" varchar,
            "position" varchar,
            "salary" money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    SELECT
        w.full_name,
        w.worker_position,
        w.salary
    FROM
        worker w
    WHERE
        w.retail_outlet_id = outlet
        OR w.retail_outlet_id IN (
            SELECT
                ro.retail_outlet_id
            FROM
                retail_outlet ro
            WHERE
                ro.part_of = outlet);
END;
$$

-- for specific outlet type
CREATE OR REPLACE FUNCTION get_salaries (outlet varchar)
    RETURNS TABLE (
            worker_name varchar,
            "position" varchar,
            "salary" money,
            "outlet_id" int
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    SELECT
        w.full_name,
        w.worker_position,
        w.salary,
        w.retail_outlet_id
    FROM
        worker w
        JOIN retail_outlet ro ON w.retail_outlet_id = ro.retail_outlet_id
    WHERE
        ro.outlet_type = outlet
        OR ro.part_of IN (
            SELECT
                ro2.retail_outlet_id
            FROM
                retail_outlet ro2
            WHERE
                ro2.outlet_type = outlet);
END;
$$

-- for all outlets
CREATE OR REPLACE FUNCTION get_salaries ()
    RETURNS TABLE (
            worker_name varchar,
            "position" varchar,
            "salary" money,
            "outlet_id" int
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    SELECT
        w.full_name,
        w.worker_position,
        w.salary,
        w.retail_outlet_id
    FROM
        worker w;
END;
$$


-- examples
--SELECT (get_salaries (1)).*;
--SELECT (get_salaries ('Mart')).*;
--SELECT (get_salaries ('Kiosk')).*;
--SELECT (get_salaries ()).*;

