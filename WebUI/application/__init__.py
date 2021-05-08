import os

from flask import Flask
from flask_login import LoginManager

from .database import Database

app = Flask(__name__, static_folder='static')
app.config['SECRET_KEY'] = os.environ['SECRET_KEY']

login = LoginManager(app)
db = Database()

from . import handlers
from . import routes
from . import admin
from . import jinja_globals
