--------------------------------------- 3 ---------------------------------------
-- Отримати номенклатуру і обсяг товарів у зазначеній торговельній точці.      --
---------------------------------------------------------------------------------

--drop function get_products_in_outlet;
CREATE OR REPLACE FUNCTION get_products_in_outlet (
    outlet_id int
)
    RETURNS TABLE (
            product int,
            product_name varchar,
            category varchar,
            amount int
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query SELECT DISTINCT
        pa.product_id,
        pd.product_name,
        pd.category,
        pa.amount
    FROM
        products_availability pa
        JOIN products_description pd ON pa.product_id = pd.product_id
    WHERE
        pa.retail_outlet_id = outlet_id
        OR pa.retail_outlet_id IN (
            SELECT
                retail_outlet_id
            FROM
                retail_outlet
            WHERE
                part_of = outlet_id);
END;
$$


-- examples
--SELECT (get_products_in_outlet (1)).*;
--SELECT (get_products_in_outlet (2)).*;

