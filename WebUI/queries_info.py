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
            ('outlet', 'number', True),
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
            ('_outlet_type', 'text', True),
        ],
    'get_products_in_outlet': [
            ('outlet', 'number', False),
        ],
    'get_product_buyers': [
            ('product', 'number', False),
            ('minimal_amount', 'number', False),
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
