import os

from flask import Flask
from flask_login import LoginManager
import psycopg2

from .queries_info import table_names, queries, dropdown_queries
from .database import Database

app = Flask(__name__, static_folder='static')
app.config['SECRET_KEY'] = os.environ['SECRET_KEY']

login = LoginManager(app)

db = Database()


def generate_dropdown(argname):
    if 'is' in argname.split('_'):
        return [('True',''), ('False','')]
    
    records = []
    if argname == 'outlet':
        records += generate_dropdown('_outlet_type')
        records += generate_dropdown('_outlet_id')
    elif argname == '_part_of':
        argname = '_outlet_id'
    elif argname == '_manager_id':
        argname = '_worker_id'
    elif argname == '_completed_by':
        argname = '_supply_id'
        
    if argname in dropdown_queries:
        records, _ = db.execute(dropdown_queries[argname])
    return records

def make_form_value(value, formtype):
    if value is None:
        return ''
    elif formtype == 'datetime-local':
        return value.strftime('%Y-%m-%dT%H:%M')
    return value

app.jinja_env.globals.update(dropdown=generate_dropdown)
app.jinja_env.globals.update(make_form_value=make_form_value)

from application import handlers
from application import routes
from application import admin