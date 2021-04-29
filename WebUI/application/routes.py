from flask import abort, render_template, request, flash, redirect
from flask_login import login_required

from application import app, conn
from .queries_info import table_names, queries, id_param_map


@app.route('/table/<string:table_name>')
def select_table(table_name):
    if table_name not in table_names:
        abort(404)
        
    with conn.cursor() as cursor:
        sql = 'SELECT * FROM {}'.format(table_name)
        if 'order' in request.args:
            sql += ' ORDER BY ' + request.args['order'].split()[0]
        cursor.execute(sql)
        columns = [desc[0] for desc in cursor.description]
        records = cursor.fetchall()
        
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
        args, records, _ = run_pgfunc(query_name, parse_args="form", commit=True)
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
                with conn.cursor() as cursor:
                    cursor.execute("SELECT table_pk(%s)", [table_name])
                    pk_name, *_ = cursor.fetchone()
                    sql = f"SELECT * FROM {table_name} WHERE {pk_name} = %s"
                    cursor.execute(sql, [id_val])
                    record = cursor.fetchone()
            else:
                flash(f"Enter the correct {id_name.replace('_', ' ').title()} value")
        
        return render_template('content_form_id.html', title='Edit '+table_name.replace('_', ' ').title(),
                               id_name=id_name, id_val=arg, form_data=list(zip(record, queries[query_name])),
                               button_text='Save')
        
    if request.method == 'POST':
        args, records, _ = run_pgfunc(query_name, parse_args="form", commit=True)
        print(records)
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
                with conn.cursor() as cursor:
                    cursor.execute("SELECT table_pk(%s)", [table_name])
                    pk_name, *_ = cursor.fetchone()
                    sql = f"SELECT * FROM {table_name} WHERE {pk_name} = %s"
                    cursor.execute(sql, [id_val])
                    record = cursor.fetchone()
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
        with conn.cursor() as cursor:
            cursor.execute("SELECT table_pk(%s)", [table_name])
            pk_name, *_ = cursor.fetchone()
            sql = f"DELETE FROM {table_name} WHERE {pk_name} = %s"
            cursor.execute(sql, [id_val])
            conn.commit()
        flash("Successfully deleted")
        return redirect(f'/table/{table_name}/delete')


@app.route('/query/<string:query_name>')
def query_page(query_name):
    if query_name not in queries:
        abort(404)
    args, records, columns = run_pgfunc(query_name)
    return render_template('form.html', form_data=queries[query_name], args=args,
                        table=records, columns=columns,
                        title=query_name.replace('_', ' ').title(),
                        id_first=False)


def run_pgfunc(query_name, parse_args="url", commit=False):
    args = dict()
    format_list = []
    
    run_query = True
    
    if parse_args == 'url':
        request_args = request.args
    elif parse_args == 'form':
        request_args = request.form
    else:
        request_args = []
    
    if len(request_args) > 0: 
        for key, argtype, nullable in queries[query_name]:
            if key not in request_args or request_args[key]=='':
                arg = None
            else:
                arg = request_args[key]
            
            if arg is None and not nullable:
                flash(key.replace('_', ' ').title() + " field is required")
                run_query = False
            
            if arg:
                format_list.append(key+r' => %s')
                if arg.isnumeric():
                    arg = int(arg)
                args[key] = arg
        format_string = ', '.join(format_list)
    else:
        run_query = False
    
    if run_query:
        with conn.cursor() as cursor:
            sql = f"SELECT * FROM {query_name}({format_string})"
            if 'order' in request.args:
                sql += ' ORDER BY ' + request.args['order'].split()[0]
            cursor.execute(sql, list(args.values()))
            columns = [desc[0] for desc in cursor.description]
            records = cursor.fetchall()
            if commit:
                conn.commit()
    else:
        columns = []
        records = []
        
    return args, records, columns
        

@app.route('/')
def index():
    return render_template('index.html', title="Welcome to TorgOrg Database GUI!")