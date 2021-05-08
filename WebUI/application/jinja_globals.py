from . import app, db

from .queries_info import DROPDOWN_QUERIES

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
        
    if argname in DROPDOWN_QUERIES:
        records, _ = db.execute(DROPDOWN_QUERIES[argname])
    return records


def make_form_value(value, formtype):
    if value is None:
        return ''
    elif formtype == 'datetime-local':
        return value.strftime('%Y-%m-%dT%H:%M')
    return value


app.jinja_env.globals.update(dropdown=generate_dropdown)
app.jinja_env.globals.update(make_form_value=make_form_value)