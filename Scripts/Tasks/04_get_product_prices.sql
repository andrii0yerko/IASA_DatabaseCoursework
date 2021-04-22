--------------------------------------- 4 ---------------------------------------
-- Отримати відомості про обсяг і ціни на зазначений товар по всіх торгових    --
-- точках, по торговим точкам заданого типу, по конкретній торговій точці.     --
---------------------------------------------------------------------------------
--drop function get_product_prices;
CREATE OR REPLACE FUNCTION get_product_prices (
    product int,
    _outlet_type varchar DEFAULT NULL
)
    RETURNS TABLE (
            outlet_id int,
            amount int,
            price money
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
        pa.retail_outlet_id,
        pa.amount,
        pa.price
    FROM
        products_availability pa
    WHERE
        product_id = product
        AND (pa.retail_outlet_id IN (
                SELECT
                    id
                FROM
                    outlets)
                OR pa.retail_outlet_id IN (
                    SELECT retail_outlet_id
                    FROM retail_outlet
                    WHERE
                        part_of IN (
                            SELECT id
                            FROM outlets)));
END;
$$

-- examples
--SELECT (get_product_prices (30)).*;
--SELECT (get_product_prices (30, 'Store')).*;

