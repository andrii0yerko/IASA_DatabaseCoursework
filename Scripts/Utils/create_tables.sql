--
--DROP TABLE public.purchase;
--DROP TABLE public.supply_request;
--DROP TABLE public.supply;
--DROP TABLE public.products_availability;
--DROP TABLE public.worker;
--DROP TABLE public.products_description;
--DROP TABLE public.retail_outlet;
--DROP TABLE public.customer;


CREATE TABLE public.retail_outlet (
	retail_outlet_id int4 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
	outlet_type varchar(30) NOT NULL,
	address varchar(200) NOT NULL,
	rent money NOT NULL,
	utility money NOT NULL,
	square float8 NULL,
	is_open bool NOT NULL DEFAULT true,
	part_of int4 NULL,
	CONSTRAINT retail_outlet_pk PRIMARY KEY (retail_outlet_id),
	CONSTRAINT retail_outlet_fk FOREIGN KEY (part_of) REFERENCES retail_outlet(retail_outlet_id),
	CONSTRAINT retail_outlet_check CHECK ((utility >= 0::money) and (rent >= 0::money) and (square >= 0))

);


CREATE TABLE public.worker (
	worker_id int4 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
	full_name varchar(100) NOT NULL,
	worker_position varchar(100) NOT NULL,
	salary money NOT NULL,
	birthdate date NULL,
	employment_date date NOT NULL,
	retail_outlet_id int4 NULL,
	CONSTRAINT worker_pk PRIMARY KEY (worker_id),
	CONSTRAINT worker_check CHECK (salary >= 0::money)
);


ALTER TABLE public.worker ADD CONSTRAINT worker_fk FOREIGN KEY (retail_outlet_id) REFERENCES retail_outlet(retail_outlet_id);


CREATE TABLE public.customer (
	customer_id int4 NOT NULL,
	full_name varchar(100) NOT NULL,
	birthdate date NULL,
	gender varchar(20) NULL,
	phone varchar(20) NOT NULL,
	email varchar(100) NULL,
	club_member bool NOT NULL DEFAULT false,
	CONSTRAINT customer_pk PRIMARY KEY (customer_id)
);


CREATE TABLE public.products_description (
	product_id int4 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
	product_name varchar(100) NOT NULL,
	category varchar(40) NOT NULL,
	description text NOT NULL,
	is_available bool NOT NULL DEFAULT true,
	CONSTRAINT products_description_pk PRIMARY KEY (product_id)
);



-- DROP TABLE public.products_availability;

CREATE TABLE public.products_availability (
    availability_id int4 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    product_id int4 NOT NULL,
    retail_outlet_id int4 NOT NULL,
    amount int4 NOT NULL DEFAULT 0,
    price money NOT NULL,
    discount float4 NOT NULL DEFAULT 0,
    CONSTRAINT products_amount_check CHECK ((amount >= 0)),
    CONSTRAINT products_availability_pk PRIMARY KEY (availability_id),
    CONSTRAINT products_discount_check CHECK (((discount >= (0)::double precision) AND (discount < (1)::double precision))),
    CONSTRAINT products_availability_check CHECK (price >= 0::money);
);


-- public.products_availability foreign keys

ALTER TABLE public.products_availability ADD CONSTRAINT products_availability_fk FOREIGN KEY (retail_outlet_id) REFERENCES public.retail_outlet(retail_outlet_id);
ALTER TABLE public.products_availability ADD CONSTRAINT products_availability_fk_1 FOREIGN KEY (product_id) REFERENCES public.products_description(product_id);

-- public.purchase definition

-- Drop table

-- DROP TABLE public.purchase;

CREATE TABLE public.purchase (
	purchase_id int4 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
	product_id int4 NOT NULL,
	amount int4 NOT NULL DEFAULT 1,
	total_price money NOT NULL,
	purchase_time timestamp(0) NULL,
	customer_id int4 NULL,
	retail_outlet_id int4 NOT NULL,
	same_purchase int4 NULL,
	worker_id int4 NULL,
	CONSTRAINT purchase_pk PRIMARY KEY (purchase_id),
	CONSTRAINT purchase_check CHECK ((amount > 0) and (total_price >= 0::money))
);


-- public.purchase foreign keys

ALTER TABLE public.purchase ADD CONSTRAINT purchase_fk FOREIGN KEY (retail_outlet_id) REFERENCES retail_outlet(retail_outlet_id);
ALTER TABLE public.purchase ADD CONSTRAINT purchase_fk_1 FOREIGN KEY (product_id) REFERENCES products_description(product_id);
ALTER TABLE public.purchase ADD CONSTRAINT purchase_fk_2 FOREIGN KEY (customer_id) REFERENCES customer(customer_id);
ALTER TABLE public.purchase ADD CONSTRAINT purchase_fk_3 FOREIGN KEY (same_purchase) REFERENCES purchase(purchase_id);
ALTER TABLE public.purchase ADD CONSTRAINT purchase_fk_worker FOREIGN KEY (worker_id) REFERENCES worker(worker_id);


CREATE TABLE public.supply_request (
	supply_request_id int4 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
	worker_id int4 NOT NULL,
	retail_outlet_id int4 NOT NULL,
	product_id int4 NOT NULL,
	amount int4 NOT NULL,
	request_date date NOT NULL,
	request_comment text NULL,
	is_completed bool NOT NULL DEFAULT false,
	completed_by int4 NULL,
	CONSTRAINT supply_request_pk PRIMARY KEY (supply_request_id),
	CONSTRAINT supply_request_check CHECK (amount > 0)
);


-- public.supply_request foreign keys

ALTER TABLE public.supply_request ADD CONSTRAINT supply_request_fk FOREIGN KEY (worker_id) REFERENCES worker(worker_id);
ALTER TABLE public.supply_request ADD CONSTRAINT supply_request_fk_1 FOREIGN KEY (retail_outlet_id) REFERENCES retail_outlet(retail_outlet_id);
ALTER TABLE public.supply_request ADD CONSTRAINT supply_request_fk_2 FOREIGN KEY (product_id) REFERENCES products_description(product_id);


CREATE TABLE public.supply (
	supply_id int4 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
	manager_id int4 NULL,
	supplier varchar NOT NULL,
	product_id int4 NOT NULL,
	amount int4 NOT NULL,
	total_price money NOT NULL,
	supply_date date NOT NULL,
	supply_comment text NULL,
	CONSTRAINT supply_pk PRIMARY KEY (supply_id),
	CONSTRAINT supply_check CHECK ((amount > 0) and (total_price >= 0::money))

);



ALTER TABLE public.supply ADD CONSTRAINT supply_fk FOREIGN KEY (manager_id) REFERENCES worker(worker_id);
ALTER TABLE public.supply ADD CONSTRAINT supply_fk_1 FOREIGN KEY (product_id) REFERENCES products_description(product_id);
ALTER TABLE public.supply_request ADD CONSTRAINT supply_request_fk_3 FOREIGN KEY (completed_by) REFERENCES public.supply(supply_id);

