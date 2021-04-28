# Database Coursework
Coursework on databases: simple retail organization database implementation. IASA, KPI, 2021.

Made with [PostreSQL]("https://www.postgresql.org/") and [Flask]("https://flask.palletsprojects.com/") + [Bootstrap](https://getbootstrap.com/) for Web UI.

## Database preparing
_SQL Scripts are Postgres-specific, and won't run in other DBMS_

All database-related scripts are placed in the `Scripts` folder.

Run `Utils/create_tables.sql` first and then all the scripts from `Tasks` in order of numbering.

In case you need some data for demonstration, then tables can be filled by calling scripts from `Utils/Inserts` (generated with [Mockaroo](https://www.mockaroo.com/)) and then `Utils/generators.sql` for filling tables that use related data (notice, that it uses random for generation, so results may differ from run to run)

## Web UI installation
The website is implemented with `Python`, so make sure you have it installed.

_The following instruction is for Unix-like systems. For Windows it will be similar, but with differences in venv activation and environmental variables declaration._

Switch to `WebUI` directory
```bash
cd ./WebUI
```
_(optionally)_ Create and activate a venv
```bash
python3 -m venv env
source env/bin/activate 
```
Then install dependencies with
```bash
pip3 install -r requirements.txt
```

The application requires some environmental variables defined:
```bash
# username of your Postgres user
export ADMIN_USERNAME="username"
# password for your Postgres user
export ADMIN_PASSWORD="password"
# name of database you are going to use
export DATABASE_NAME="postgres"
# url of your database server
export DATABASE_URL="localhost"
```

Now you can run application with:
```bash
python3 main.py
```