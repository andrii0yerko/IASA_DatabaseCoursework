import psycopg2
import os

class Database():
    '''
    Wrapper around Postgres psycopg2 connector
    '''
    def __init__(self, url=None):
        if url is None:
            url = os.environ['DATABASE_URL']
        self.conn = psycopg2.connect(url)
    
    def execute(self, sql, params=None, fetch='all', commit=False):
        with self.conn.cursor() as cursor:
            cursor.execute(sql, params)
            
            if fetch == 'all':
                records = cursor.fetchall()
                columns = [desc[0] for desc in cursor.description]
            elif fetch == 'one':
                records = cursor.fetchone()
                columns = [desc[0] for desc in cursor.description]
            elif fetch:
                raise ValueError("`fetch` must be one of 'all', 'one' or can be interpreted as False")
            
        if commit:
            self.conn.commit()
        if not fetch:
            return
        return records, columns
    
    def select_table(self, table_name, order_column=None):
        sql = 'SELECT * FROM {}'.format(table_name)
        if order_column:
            sql += ' ORDER BY ' + order_column
        return self.execute(sql)
    
    def get_by_id(self, table_name, id):
        pk_name, _ = self.execute("SELECT table_pk(%s)", [table_name], fetch='one')
        sql = f"SELECT * FROM {table_name} WHERE {pk_name[0]} = %s"
        record, _ = self.execute(sql, [id], fetch='one')
        return record
    
    def delete_by_id(self, table_name, id):
        record = self.get_by_id(table_name, id)
        pk_name, _ = self.execute("SELECT table_pk(%s)", [table_name], fetch='one')
        sql = f"DELETE FROM {table_name} WHERE {pk_name[0]} = %s"
        self.execute(sql, [id], fetch=False, commit=True)
        return record
    
    def run_pgfunc(self, query_name, args, order_column=None, **kwargs):
        format_list = [key+r' => %s' for key in args.keys()]
        format_string = ', '.join(format_list)
        
        params = list(args.values())
        sql = f"SELECT * FROM {query_name}({format_string})"
        if order_column:
            sql += ' ORDER BY ' + order_column
        return self.execute(sql, params, **kwargs)

            