--------------------------------------- 10 ---------------------------------------
-- Отримати дані про ставлення обсягу продажів до обсягу торгових площ, або до  --
-- числа торгових залів, або до числа прилавків по торговим точкам зазначеного  --
-- типу, про вироблення окремо взятого продавця торгової точки, для даної       --
-- торгової точки.                                                              --
----------------------------------------------------------------------------------

-- drop function get_sales_square_ratio

CREATE OR REPLACE FUNCTION get_sales_square_ratio (
    after_date date DEFAULT earliest_date('purchase_time', 'purchase'),
    before_date date DEFAULT latest_date('purchase_time', 'purchase')
)
    RETURNS TABLE (
    "retail_outlet_id" int,
    "income" money,
    "square" float,
    "income_per_m2" money
)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN query
  WITH purchase_aggregated AS (
        SELECT
            p2.retail_outlet_id,
            sum(p2.total_price) as income
        FROM 
            purchase p2
        WHERE
            p2.purchase_time BETWEEN after_date AND before_date
        GROUP BY
            p2.retail_outlet_id
    )
    SELECT 
        ro.retail_outlet_id,
        p.income,
        ro.square,
        p.income / ro.square
    FROM 
        retail_outlet ro 
        JOIN purchase_aggregated p ON ro.retail_outlet_id = p.retail_outlet_id;
END;
$$;


-- examples
--SELECT * FROM get_sales_square_ratio('2021-01-30'::date, '2021-05-01'::date);
--SELECT * FROM get_sales_square_ratio()