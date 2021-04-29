import os

from flask import Flask
from flask_login import LoginManager
import psycopg2

from .queries_info import table_names, queries, dropdown_queries

app = Flask(__name__, static_folder='static')
app.config['SECRET_KEY'] = os.environ['SECRET_KEY']

login = LoginManager(app)

# connection_params = {
#     'dbname': os.environ['DATABASE_NAME'],
#     'host': os.environ['DATABASE_URL'],
#     'user': os.environ['ADMIN_USERNAME'],
#     'user': os.environ['ADMIN_PASSWORD']
# }
conn = psycopg2.connect(
    # **connection_params
    os.environ['DATABASE_URL']
    )


def generate_dropdown(argname):
    if 'is' in argname.split('_'):
        return [('True',''), ('False','')]
    
    records = []
    if argname == 'outlet':
        records += generate_dropdown('_outlet_type')
        records += generate_dropdown('_outlet_id')
    elif argname == '_part_of':
        argname = 'outlet_id'
    elif argname == '_manager_id':
        argname = '_worker_id'
    elif argname == '_completed_by':
        argname = '_supply_id'
    if argname in dropdown_queries:
         with conn.cursor() as cursor:
             cursor.execute(dropdown_queries[argname])
             records = cursor.fetchall()
    return records

app.jinja_env.globals.update(dropdown=generate_dropdown)

from application import handlers
from application import routes
from application import admin