--------------------------------------- 11 ---------------------------------------
-- Отримати дані про рентабельність торговельної точки: співвідношення обсягу   --
-- продажів до накладних витрат (сумарна заробітна плата продавців + платежі за --
-- оренду, комунальні послуги) за вказаний період.                              --
----------------------------------------------------------------------------------

--drop function get_outlet_profitability
CREATE OR REPLACE FUNCTION get_outlet_profitability (
    after_date date,
    before_date date
)
    RETURNS TABLE (
            "retail_outlet_id" int,
            "income" money,
            "salary" money,
            "rent" money,
            "utility" money,
            "total" money
)
    LANGUAGE plpgsql
    AS $$
DECLARE
    months_num int;
BEGIN
    months_num := extract(month FROM age(before_date, after_date));
    RETURN query WITH cte_salary AS (
        SELECT
            w2.retail_outlet_id,
            sum(w2.salary) AS salary
        FROM
            worker w2
        GROUP BY
            w2.retail_outlet_id
    ),
    cte_income AS (
        SELECT
            p2.retail_outlet_id,
            sum(total_price) AS income
        FROM
            purchase p2
        WHERE
            p2.purchase_time BETWEEN after_date AND before_date
        GROUP BY
            p2.retail_outlet_id
    )
    SELECT
        r.retail_outlet_id,
        i.income,
        s.salary * months_num,
        r.rent * months_num,
        r.utility * months_num,
        i.income - months_num * (s.salary + r.rent + r.utility)
    FROM
        retail_outlet r
        JOIN cte_salary s ON r.retail_outlet_id = s.retail_outlet_id
        JOIN cte_income i ON r.retail_outlet_id = i.retail_outlet_id;
END;
$$


-- examples
--SELECT * FROM get_outlet_profitability ('2021-04-01'::date, '2021-05-01'::date)
