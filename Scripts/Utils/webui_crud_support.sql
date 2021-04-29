-- functions that help perform CRUD on Web UI 


CREATE OR REPLACE FUNCTION table_pk(table_name varchar)
RETURNS varchar
LANGUAGE plpgsql
AS $$
BEGIN 
    RETURN (SELECT string_agg(a.attname, ', ') AS pk
    FROM
        pg_constraint AS c
        CROSS JOIN LATERAL UNNEST(c.conkey) AS cols(colnum) -- conkey is a list of the columns of the constraint; so we split it into rows so that we can join all column numbers onto their names in pg_attribute
        INNER JOIN pg_attribute AS a ON a.attrelid = c.conrelid AND cols.colnum = a.attnum
    WHERE
        c.contype = 'p' -- p = primary key constraint
        AND c.conrelid = CONCAT('public.', table_name)::REGCLASS -- regclass will type the name of the object to its internal oid
        );
end;
$$


--DROP FUNCTION retail_outlet_insert_or_update;
CREATE OR REPLACE FUNCTION retail_outlet_insert_or_update (
    _outlet_type varchar(30),
    _address varchar(200),
    _rent money,
    _utility money,
    _square float8 DEFAULT NULL,
    _is_open bool DEFAULT true,
    _part_of int4 DEFAULT NULL,
    _outlet_id int4 DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN 
    IF _outlet_id IS NULL THEN  -- INSERT
        _outlet_id := (
            SELECT max(ro.retail_outlet_id+1) FROM retail_outlet ro
        );
        INSERT INTO
            retail_outlet(retail_outlet_id, outlet_type, address, rent, utility, square, is_open, part_of)
        VALUES
            (_outlet_id, _outlet_type, _address, _rent, _utility, _square, _is_open, _part_of);
    ELSE  -- update
        UPDATE retail_outlet AS ro
        SET
            outlet_type = _outlet_type,
            address = _address,
            rent = _rent,
            utility = _utility,
            square = _square,
            is_open = _is_open,
            part_of = _part_of
        WHERE 
            ro.retail_outlet_id = _outlet_id; 
    END IF;
    RETURN _outlet_id;
END;
$$


--SELECT retail_outlet_insert_or_update(8, 'test'::varchar, 'doesnt matt213er'::varchar, 200::money, 200::money, 200, TRUE, NULL);
--SELECT * FROM retail_outlet ro 

--DROP FUNCTION worker_insert_or_update(int, varchar, varchar, money, date, date, int)
CREATE OR REPLACE FUNCTION worker_insert_or_update (
    _full_name varchar(100),
    _worker_position varchar(100),
    _salary money,
    _birthdate date,
    _employment_date date,
    _outlet_id int4,
    _worker_id int4 DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN 
    IF _worker_id IS NULL THEN  -- INSERT
        _worker_id := (
            SELECT max(w.worker_id+1) FROM worker w
        );
        INSERT INTO
            worker(worker_id , full_name, worker_position, salary, birthdate, employment_date, retail_outlet_id)
        VALUES
            (_worker_id, _full_name, _worker_position, _salary, _birthdate, _employment_date, _outlet_id);
    ELSE  -- update
        UPDATE worker AS w
        SET
            full_name = _full_name,
            worker_position = _worker_position,
            salary = _salary,
            birthdate = _birthdate,
            employment_date = _employment_date,
            retail_outlet_id = _outlet_id
        WHERE 
            w.worker_id = _worker_id; 
    END IF;
    RETURN _worker_id;
END;
$$

-- drop function customer_insert_or_update
CREATE OR REPLACE FUNCTION customer_insert_or_update (
    _full_name varchar(100),
    _phone varchar(20),
    _birthdate date DEFAULT NULL,
    _gender varchar(20) DEFAULT NULL,
    _email varchar(100) DEFAULT NULL,
    _club_member bool DEFAULT FALSE,
    _customer_id int4 DEFAULT NULL 
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN 
    IF _customer_id IS NULL THEN  -- INSERT
        _customer_id := (
            SELECT max(c.customer_id+1) FROM customer c
        );
        INSERT INTO
            customer(customer_id, full_name, birthdate, gender, phone, email, club_member)
        VALUES
            (_customer_id, _full_name, _birthdate, _gender, _phone, _email, _club_member);
    ELSE  -- update
        UPDATE customer AS c
        SET
            full_name = _full_name,
            birthdate = _birthdate,
            gender = _gender,
            phone = _phone,
            email = _email,
            club_member = _club_member
        WHERE 
            c.customer_id = _customer_id; 
    END IF;
    RETURN _customer_id;
END;
$$

--drop function products_description_insert_or_update
CREATE OR REPLACE FUNCTION products_description_insert_or_update (
    _product_name varchar(100),
    _category varchar(40),
    _description TEXT DEFAULT NULL ,
    _is_available bool DEFAULT TRUE,
    product int4 DEFAULT NULL 
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN 
    IF product IS NULL THEN  -- INSERT
        product := (
            SELECT max(p.product_id+1) FROM products_description p
        );
        INSERT INTO
            products_description(product_id, product_name, category, description, is_available)
        VALUES
            (product, _product_name, _category, _description, _is_available);
    ELSE  -- update
        UPDATE products_description AS p
        SET
            product_name = _product_name,
            category = _category,
            description = _description,
            is_available = _is_available
        WHERE 
            p.product_id = product; 
    END IF;
    RETURN product;
END;
$$

--drop function products_availability_insert_or_update
CREATE OR REPLACE FUNCTION products_availability_insert_or_update (
    product int4,
    _outlet_id int4,
    _amount int4,
    _price money,
    _discount float4 DEFAULT 0,
    _availability_id int4 DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN 
    IF _availability_id IS NULL THEN  -- INSERT
        _availability_id := (
            SELECT max(p.availability_id+1) FROM products_availability p
        );
        INSERT INTO
            products_availability(availability_id, product_id, retail_outlet_id, amount, price, discount)
        VALUES
            (_availability_id, product, _outlet_id, _amount, _price, _discount);
    ELSE  -- update
        UPDATE products_availability AS p
        SET
            product_id = product,
            retail_outlet_id = _outlet_id,
            amount = _amount,
            price = _price,
            discount = _discount
        WHERE 
            p.availability_id = _availability_id; 
    END IF;
    RETURN _availability_id;
END;
$$

--DROP FUNCTION supply__insert_or_update
CREATE OR REPLACE FUNCTION supply_insert_or_update (
    supplier_name varchar,
    product int4,
    _amount int4,
    _total_price money,
    _supply_date date,
    _supply_comment text DEFAULT NULL,
    _manager_id int4 DEFAULT NULL,
    _supply_id int4 DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN 
    IF _supply_id IS NULL THEN  -- INSERT
        _supply_id := (
            SELECT max(s.supply_id+1) FROM supply s
        );
        INSERT INTO
            supply(supply_id, manager_id, supplier, product_id, amount, total_price, supply_date, supply_comment)
        VALUES
            (_supply_id, _manager_id, supplier_name, product, _amount, _total_price, _supply_date, _supply_comment);
    ELSE  -- update
        UPDATE supply AS s
        SET
            manager_id = _manager_id,
            supplier = supplier_name,
            product_id = product,
            amount = _amount,
            total_price = _total_price,
            supply_date = _supply_date,
            supply_comment = _supply_comment
        WHERE 
            s.supply_id = _supply_id; 
    END IF;
    RETURN _supply_id;
END;
$$


--drop function supply_requests_availability_insert_or_update
CREATE OR REPLACE FUNCTION supply_request_insert_or_update (
    _worker_id int4,
    _outlet_id int4,
    product int4,
    _amount int4,
    _request_date date,
    _request_comment text DEFAULT NULL,
    _is_completed bool DEFAULT false,
    _completed_by int4 DEFAULT NULL,
    request_id int4 DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN 
    IF request_id IS NULL THEN  -- INSERT
        request_id := (
            SELECT max(s.supply_request_id+1) FROM supply_request s
        );
        INSERT INTO
            supply_request(supply_request_id, worker_id, retail_outlet_id, product_id, amount, request_date, request_comment, is_completed, completed_by)
        VALUES
            (request_id, _worker_id, _outlet_id, product, _amount, _request_date, _request_comment, _is_completed, _completed_by);
    ELSE  -- update
        UPDATE supply_request AS s
        SET
            worker_id = _worker_id,
            retail_outlet_id = _outlet_id,
            product_id = product,
            amount = _amount,
            request_date = _request_date,
            request_comment = _request_comment,
            is_completed = _is_completed,
            completed_by = _completed_by
        WHERE 
            s.supply_request_id = request_id; 
    END IF;
    RETURN request_id;
END;
$$