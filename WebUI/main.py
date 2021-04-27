import os

from flask import abort, Flask, render_template, request
import psycopg2

from queries_info import table_names, queries, dropdown_queries

app = Flask(__name__)
conn = psycopg2.connect(dbname='postgres', user='postgres', 
                        password='password', host='localhost')


@app.route('/select/<string:table_name>')
def select_table(table_name, is_table=True):
    if is_table and table_name not in table_names:
        abort(404)
        
    with conn.cursor() as cursor:
        sql = 'SELECT * FROM {}'.format(table_name)
        if 'order' in request.args:
            sql += ' ORDER BY ' + request.args['order'].split()[0]
        cursor.execute(sql)
        columns = [desc[0] for desc in cursor.description]
        records = cursor.fetchall()
    
    if not is_table:
        table_name = table_name.replace('()', '')
        
    return render_template('table.html', table=records, columns=columns,
                           title=table_name.replace('_', ' ').title(), id_first=True)


@app.route('/query/<string:query_name>')
def run_query(query_name):
    if query_name not in queries:
        abort(404)
    
    if len(queries[query_name]) == 0:  # if the query cannot have parameters, run it as a simple select
        query = f'{query_name}()'
        return select_table(query, False)

    args = dict()
    format_list = []
    
    run_query = True
    
    if len(request.args) > 0: 
        for key, argtype, nullable in queries[query_name]:
            arg = request.args[key] if request.args[key]!='' else None
            
            if arg is None and not nullable:
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
    else:
        columns = []
        records = []
        
    return render_template('form.html', form_data=queries[query_name], args=args,
                           table=records, columns=columns,
                           title=query_name.replace('_', ' ').title(),
                           id_first=False)

@app.route('/')
def index():
    return render_template('table.html', columns=[],
                           title="Welcome to TorgOrg Database GUI!" )


def generate_dropdown(argname):
    records = []
    if argname == 'outlet':
        records += generate_dropdown('_outlet_type')
        records += generate_dropdown('outlet_id')
    if argname in dropdown_queries:
         with conn.cursor() as cursor:
             cursor.execute(dropdown_queries[argname])
             records = cursor.fetchall()
    return records

app.jinja_env.globals.update(dropdown=generate_dropdown)

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=2000
        )