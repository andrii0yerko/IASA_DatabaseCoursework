--------------------------------------- 15 ---------------------------------------
-- Отримати дані про товарообіг торгової точки, або всіх торгових точок певної  --
-- групи за вказаний період.                                                    --
----------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_product_turnover (
    after_date date,
    before_date date
)
    RETURNS TABLE (
        "retail_outlet_id" int,
        "product_id" int,
        "bought_amount" int,
        "supplied_amount" int,
        "left_amount" int 
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    WITH purchase_aggregated AS (
        SELECT
            p2.retail_outlet_id,
            p2.product_id,
            sum(p2.amount) as amount
        FROM 
            purchase p2
        WHERE
            p2.purchase_time BETWEEN after_date AND before_date
        GROUP BY
            p2.retail_outlet_id, p2.product_id 
    ), supply_aggregated AS (
        SELECT
            sr.retail_outlet_id,
            sr.product_id,
            sum(s2.amount) as amount
        FROM
            supply_request sr
            JOIN supply s2 ON sr.completed_by = s2.supply_id
        WHERE
            s2.supply_date BETWEEN after_date AND before_date
        GROUP BY
            sr.retail_outlet_id, sr.product_id 
    )
    
    SELECT
        CASE
            WHEN p.retail_outlet_id IS NOT NULL THEN p.retail_outlet_id
            WHEN s.retail_outlet_id IS NOT NULL THEN s.retail_outlet_id
            WHEN pa.retail_outlet_id IS NOT NULL THEN pa.retail_outlet_id
        END AS outlet,
        CASE
            WHEN p.product_id IS NOT NULL THEN p.product_id
            WHEN s.product_id IS NOT NULL THEN s.product_id
            WHEN pa.product_id IS NOT NULL THEN pa.product_id
        END AS product,
        p.amount::int,
        s.amount::int,
        pa.amount::int
    FROM 
        purchase_aggregated p
        FULL OUTER JOIN supply_aggregated s ON
            p.retail_outlet_id = s.retail_outlet_id
            AND p.product_id = s.product_id
        LEFT OUTER JOIN products_availability pa ON (
            CASE WHEN p.retail_outlet_id IS NOT NULL THEN
                p.retail_outlet_id
            WHEN s.retail_outlet_id IS NOT NULL THEN
                s.retail_outlet_id
            END) = pa.retail_outlet_id
            AND (
                CASE WHEN p.product_id IS NOT NULL THEN
                    p.product_id
                WHEN s.product_id IS NOT NULL THEN
                    s.product_id
                END) = pa.product_id
    ORDER BY
        outlet, product;
END;
$$


-- examples
--SELECT * FROM get_product_turnover ('2021-01-01'::date, '2021-05-01'::date);
--SELECT * FROM get_product_turnover ('2021-04-28'::date, '2021-05-01'::date);