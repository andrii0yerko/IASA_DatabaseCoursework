import os

from flask import abort, Flask, render_template, request
import psycopg2

from queries_info import table_names, queries

app = Flask(__name__)

conn = psycopg2.connect(dbname='postgres', user='postgres', 
                        password='password', host='localhost')
# cursor = conn.cursor()


@app.route('/select/<string:table_name>')
def select_table(table_name, istable=True):
    if istable and table_name not in table_names:
        abort(404)
        
    with conn.cursor() as cursor:
        cursor.execute('SELECT * FROM {} ORDER BY 1'.format(table_name))
        columns = [desc[0].replace('_', ' ').title() for desc in cursor.description]
        records = cursor.fetchall()
    
    if not istable:
        table_name = table_name.replace('()', '')
        
    return render_template('table.html', table=records, columns=columns,
                           title=table_name.replace('_', ' ').title(), id_first=True)


@app.route('/query/<string:query_name>')
def run_query(query_name):
    if query_name not in queries:
        print('404', query_name)
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
                if argtype == 'number':
                    arg = int(arg)
                args[key] = arg
            
        format_string = ', '.join(format_list)
    else:
        run_query = False
    
    if run_query:
        print(args)
        with conn.cursor() as cursor:
            cursor.execute(f"SELECT * FROM {query_name}({format_string})", list(args.values()))
            columns = [desc[0].replace('_', ' ').title() for desc in cursor.description]
            records = cursor.fetchall()
    else:
        columns = []
        records = []
        
    return render_template('form.html', form_data=queries[query_name], args=args,
                           table=records, columns=columns,
                           title=query_name.replace('_', ' ').title(),
                           id_first=False)


if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=2000
        )