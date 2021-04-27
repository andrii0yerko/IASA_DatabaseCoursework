table_names = ['worker', 'retail_outlet', 'customer', 'supply', 'supply_request', 'products_description', 'purchase']


# pg_func_name: [
#     (argument_name, argument type (in web-form notation), is optional), #arg1
#     (...) #arg2
#     ...
# ]

queries = {
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
}


dropdown_queries = {
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
    '''
}