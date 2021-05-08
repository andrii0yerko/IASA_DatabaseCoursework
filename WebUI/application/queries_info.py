TABLE_NAMES = ['worker', 'retail_outlet', 'customer', 'supply', 'supply_request', 'products_description', 'purchase', 'products_availability']


# pg_func_name: [
#     (argument_name, argument type (in web-form notation), is optional), #arg1
#     (...) #arg2
#     ...
# ]
QUERIES = {
    'get_product_turnover': [
            ('after_date', 'date', False),
            ('before_date', 'date', False)
        ],
    'get_buyers_activity': [
            ('outlet', 'text', True)
        ],
    'get_product_buyers_by_outlet': [
            ('product', 'number', False),
            ('outlet', 'text', False),
            ('after_date', 'date', True),
            ('before_date', 'date', True),
        ],
    'get_supply_by_request': [
            ('request_id', 'number', False)
        ],
    'get_outlet_profitability': [
            ('after_date', 'date', False),
            ('before_date', 'date', False)
        ],
    'get_sales_square_ratio': [
            ('after_date', 'date', True),
            ('before_date', 'date', True),
        ],
    'get_product_supply': [
            ('product', 'number', False),
            ('supplier_name', 'text', False),
            ('after_date', 'date', True),
            ('before_date', 'date', True),
        ],
    'get_salaries': [
            ('outlet', 'text', True),
        ],
    'get_product_sales': [
            ('product', 'number', False),
            ('outlet', 'text', True),
            ('after_date', 'date', True),
            ('before_date', 'date', True),
        ],
    'get_worker_productivity': [
            ('_worker_id', 'number', False),
            ('_outlet_id', 'number', True),
            ('after_date', 'date', True),
            ('before_date', 'date', True),
        ],
    'get_workers_productivity': [
            ('_outlet_type', 'text', True),
            ('after_date', 'date', True),
            ('before_date', 'date', True),
        ],
    'get_product_prices': [
            ('product', 'number', False),
            ('outlet', 'text', True),
        ],
    'get_products_in_outlet': [
            ('_outlet_id', 'number', False),
        ],
    'get_product_buyers': [
            ('product', 'number', False),
            ('minimal_amount', 'number', True),
            ('after_date', 'date', True),
            ('before_date', 'date', True),
        ],
    'get_product_suppliers': [
            ('product', 'number', False),
            ('minimal_amount', 'number', True),
            ('after_date', 'date', True),
            ('before_date', 'date', True),
        ],
    'retail_outlet_insert_or_update': [
            ('_outlet_id', 'hidden', True),
            ('_outlet_type', 'text', False),
            ('_address', 'text', False),
            ('_rent', 'text', False),
            ('_utility', 'text', False),
            ('_square', 'number', True),
            ('_is_open', 'text', False),
            ('_part_of', 'number', True)
        ],
    'worker_insert_or_update': [
            ('_worker_id', 'hidden', True),
            ('_full_name', 'text', False),
            ('_worker_position', 'text', False),
            ('_salary', 'text', False),
            ('_birthdate', 'date', False),
            ('_employment_date', 'date', False),
            ('_outlet_id', 'number', False)
        ],
    'customer_insert_or_update': [
            ('_customer_id', 'hidden', True),
            ('_full_name', 'text', False),
            ('_birthdate', 'date', True),
            ('_gender', 'text', True),
            ('_phone', 'text', False),
            ('_email', 'text', True),
            ('_club_member', 'text', True)
        ],
    'products_description_insert_or_update': [
            ('product', 'hidden', True),
            ('_product_name', 'text', False),
            ('_category', 'text', False),
            ('_description', 'text', True),
            ('_is_available', 'text', True)
        ],
    'products_availability_insert_or_update': [
            ('_availability_id', 'hidden', True),
            ('product', 'number', False),
            ('_outlet_id', 'number', False),
            ('_amount', 'number', False),
            ('_price', 'text', False),
            ('_discount', 'number', True)
        ],
    'supply_insert_or_update': [
            ('_supply_id', 'hidden', True),
            ('_manager_id', 'number', True),
            ('supplier_name', 'text', False),
            ('product', 'number', False),
            ('_amount', 'number', False),
            ('_total_price', 'text', False),
            ('_supply_date', 'date', False),
            ('_supply_comment', 'text', True)
        ],
    'supply_request_insert_or_update': [
            ('request_id', 'hidden', True),
            ('_worker_id', 'number', False),
            ('_outlet_id', 'number', False),
            ('product', 'number', False),
            ('_amount', 'number', False),
            ('_request_date', 'date', False),
            ('_request_comment', 'text', True),
            ('_is_completed', 'text', False),
            ('_completed_by', 'number', True)
        ],
    'purchase_insert_or_update': [
            ('_purchase_id', 'hidden', True),
            ('product', 'number', False),
            ('_amount', 'number', True),
            ('_total_price', 'text', False),
            ('_purchase_time', 'datetime-local', False),
            ('_customer_id', 'number', True),
            ('_outlet_id', 'number', False),
            ('_same_purchase', 'number', True),
            ('_worker_id', 'number', False)
    ]
}


DROPDOWN_QUERIES = {
    'product': '''
        SELECT DISTINCT
            product_id,
            product_name
        FROM
            products_description
        WHERE
            is_available = True
        ORDER BY
            product_id;
    ''',
    
    '_worker_id': '''
        SELECT DISTINCT
            worker_id,
            CONCAT(full_name, ', ', worker_position)
        FROM
            worker
        ORDER BY
            worker_id;
    ''',
    
    'supplier_name': '''
        SELECT DISTINCT
            supplier,
            ''
        FROM supply
        ORDER BY supplier;
    ''',
    
    'request_id': '''
        SELECT
            supply_request_id,
            CONCAT(pd.product_name, ' to ', ro.address, ', ', sr.request_date)
            
        FROM supply_request sr
             JOIN products_description pd ON sr.product_id = pd.product_id
             JOIN retail_outlet ro ON ro.retail_outlet_id = sr.retail_outlet_id
        ORDER BY
            sr.request_date DESC;
    ''',
    
    '_outlet_id': '''
        SELECT
            ro.retail_outlet_id,
            CONCAT(ro.outlet_type, ' at ', ro.address)
        FROM
            retail_outlet ro
        ORDER BY
            ro.retail_outlet_id;
    ''',
    
    '_outlet_type': '''
        SELECT DISTINCT
            ro.outlet_type,
            CONCAT('All of the ', ro.outlet_type, ' type')
        FROM
            retail_outlet ro;
    ''',
    
    '_customer_id': '''
        SELECT
            c.customer_id,
            c.full_name
        FROM
            customer c
        ORDER BY
            c.customer_id;
    ''',
        
    '_availability_id': '''
        SELECT
            pa.availability_id,
            CONCAT(pd.product_name, ' (', pa.product_id, ') ', ' at ', ro.address)
        FROM
            products_availability pa
            JOIN products_description pd ON pa.product_id = pd.product_id
            JOIN retail_outlet ro ON ro.retail_outlet_id = pa.retail_outlet_id
        ORDER BY
            pa.availability_id;
    ''',
    
    '_supply_id': '''
        SELECT
            s.supply_id,
            CONCAT(pd.product_name, ' by ', s.supplier, ', ', s.supply_date)
        FROM
            supply s
            JOIN products_description pd ON s.product_id = pd.product_id
        ORDER BY
            supply_id;
    '''
}

ID_PARAM_MAP = {
    'retail_outlet': '_outlet_id',
    'products_description': 'product',
    'worker': '_worker_id',
    'customer': '_customer_id',
    'supply': '_supply_id',
    'supply_request': 'request_id',
    'products_availability': '_availability_id',
    'purchase': '_purchase_id'
}