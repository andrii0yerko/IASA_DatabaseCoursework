from flask import abort, render_template, request, flash, redirect
from flask_login import login_required

from application import app, db
from .queries_info import table_names, queries, id_param_map


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/table/<string:table_name>')
def select_table(table_name):
    if table_name not in table_names:
        abort(404)
    
    select_params = {'table_name': table_name}
    if 'order' in request.args:
        select_params['order_column'] = request.args['order']
    
    records, columns = db.select_table(**select_params)
        
    return render_template('select.html', table=records, columns=columns,
                           title=table_name.replace('_', ' ').title(), id_first=True)


@app.route('/table/<string:table_name>/insert', methods=['GET', 'POST'])
@login_required
def insert(table_name):
    if table_name not in table_names:
        abort(404)
        
    query_name = table_name + '_insert_or_update'
    id_name = id_param_map[table_name]
    
    if request.method == 'GET':
        record = ['' for _ in queries[query_name]]
        return render_template('content_form.html', title='Insert '+table_name.replace('_', ' ').title(),
                               form_data=list(zip(record, queries[query_name]))[1:],
                               button_text='Add')
        
    if request.method == 'POST':
        _, args = parse_args("form", query_name)
        records, _ = db.run_pgfunc(query_name, args, commit=True)
        if len(records) > 0:
            flash("Successfully added")
        return redirect(f'/table/{table_name}/insert')


@app.route('/table/<string:table_name>/edit', methods=['GET', 'POST'])
@login_required
def edit(table_name):
    if table_name not in table_names:
        abort(404)
    
    query_name = table_name + '_insert_or_update'
    id_name = id_param_map[table_name]
    
    if request.method == 'GET':
        arg = ''
        record = []
        if id_name in request.args:
            arg = request.args[id_name]
            if arg.isnumeric():
                id_val = int(arg)
                record = db.get_by_id(table_name, id_val)
            else:
                flash(f"Enter the correct {id_name.replace('_', ' ').title()} value")
        
        return render_template('content_form_id.html', title='Edit '+table_name.replace('_', ' ').title(),
                               id_name=id_name, id_val=arg, form_data=list(zip(record, queries[query_name])),
                               button_text='Save')
        
    if request.method == 'POST':
        _, args = parse_args("form", query_name)
        records, _ = db.run_pgfunc(query_name, args, commit=True)
        if len(records) > 0:
            flash("Successfully updated")
        return redirect(f'/table/{table_name}/edit?{id_name}={args[id_name]}')
        


@app.route('/table/<string:table_name>/delete', methods=['GET', 'POST'])
@login_required
def delete(table_name):
    if table_name not in table_names:
        abort(404)
    
    query_name = table_name + '_insert_or_update'
    id_name = id_param_map[table_name]
    
    if request.method == 'GET':
        arg = ''
        record = []
        if id_name in request.args:
            arg = request.args[id_name]
            if arg.isnumeric():
                id_val = int(arg)
                record = db.get_by_id(table_name, id_val)
                flash("Do you really want to delete this record?")
            else:
                flash(f"Enter the correct {id_name.replace('_', ' ').title()} value")
        return render_template('content_form_id.html', title='Delete '+table_name.replace('_', ' ').title(),
                               id_name=id_name, id_val=arg, form_data=list(zip(record, queries[query_name])),
                               button_text='Delete')
        
    if request.method == 'POST':
        if request.form[id_name] != request.args[id_name]:
            abort(500)
        id_val = request.form[id_name]
        db.delete_by_id(table_name, id_val)
        flash("Successfully deleted")
        return redirect(f'/table/{table_name}/delete')


@app.route('/query/<string:query_name>')
def query_page(query_name):
    if query_name not in queries:
        abort(404)
    
    records = []
    columns = []
    run_query, args = parse_args("url", query_name)
    order_col = args.pop('order', None)
    if run_query:
        records, columns = db.run_pgfunc(query_name, args, order_col)
    return render_template('form.html', form_data=queries[query_name], args=args,
                            table=records, columns=columns,
                            title=query_name.replace('_', ' ').title(),
                            id_first=False)


def parse_args(parse_from="url", query_name=None, order=True):
    args = dict()
    run_query = True
    
    if parse_from == 'url':
        request_args = request.args.to_dict()
    elif parse_from == 'form':
        request_args = request.form.to_dict()
    
    if query_name is None:
        return request_args
    
    if len(request_args) > 0:
        if order and 'order' in request_args:
            args['order'] = request_args['order']
        for key, argtype, nullable in queries[query_name]:
            if not nullable and (key not in request_args or request_args[key]==''):
                flash(key.replace('_', ' ').title() + " field is required")
                run_query = False
            elif key in request_args and request_args[key]!='':
                arg = request_args[key]
                if arg.isnumeric():
                    arg = int(arg)
                elif argtype == 'datetime-local':
                    arg = ' '.join(arg.split('T'))+':00'
                args[key] = arg
    else:
        run_query = False
        
    return run_query, args
