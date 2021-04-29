--------------------------------------- 4 ---------------------------------------
-- Отримати відомості про обсяг і ціни на зазначений товар по всіх торгових    --
-- точках, по торговим точкам заданого типу, по конкретній торговій точці.     --
---------------------------------------------------------------------------------

--drop function get_product_prices(int, varchar);

--for specific outlet type
CREATE OR REPLACE FUNCTION get_product_prices (
    product int,
    outlet varchar
)
    RETURNS TABLE (
            outlet_id int,
            amount int,
            price money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query SELECT DISTINCT
        pa.retail_outlet_id,
        pa.amount,
        pa.price
    FROM
        products_availability pa
        JOIN retail_outlet ro ON ro.retail_outlet_id = pa.retail_outlet_id
    WHERE
        product_id = product
        AND ro.outlet_type = outlet;
END;
$$;

-- for specific outlet
CREATE OR REPLACE FUNCTION get_product_prices (
    product int,
    outlet int
)
    RETURNS TABLE (
            amount int,
            price money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query SELECT
        pa.amount,
        pa.price
    FROM
        products_availability pa
    WHERE
        pa.product_id = product
        AND pa.retail_outlet_id = outlet;
END;
$$;

-- for all outlets
CREATE OR REPLACE FUNCTION get_product_prices (
    product int
)
    RETURNS TABLE (
            outlet_id int,
            amount int,
            price money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query SELECT DISTINCT
        pa.retail_outlet_id,
        pa.amount,
        pa.price
    FROM
        products_availability pa
    WHERE
        product_id = product;
END;
$$;

-- examples
--SELECT (get_product_prices (30)).*;
--SELECT (get_product_prices (30, 'Store')).*;
--SELECT * FROM get_product_prices(30, 5);
