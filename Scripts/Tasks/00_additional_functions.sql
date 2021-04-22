--DROP FUNCTION earliest_date;
CREATE OR REPLACE FUNCTION earliest_date (column_name text, table_name text) RETURNS date
LANGUAGE plpgsql
AS $$
DECLARE
    min_date date;
BEGIN 
    EXECUTE format('SELECT MIN(%s) FROM %s', column_name, table_name) INTO min_date;
    RETURN min_date;
END;
$$

--DROP FUNCTION latest_date;
CREATE OR REPLACE FUNCTION latest_date (column_name text, table_name text) RETURNS date
LANGUAGE plpgsql
AS $$
DECLARE
    min_date date;
BEGIN 
    EXECUTE format('SELECT MAX(%s) FROM %s', column_name, table_name) INTO min_date;
    RETURN min_date;
END;
$$


--examples

--SELECT earliest_date('supply_date', 'supply'), latest_date('supply_date', 'supply');
--SELECT earliest_date('purchase_time', 'purchase'), latest_date('purchase_time', 'purchase');