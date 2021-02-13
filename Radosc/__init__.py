from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt #for encrypting passwords
from flask_login import LoginManager #for logging in and out

from sqlalchemy import create_engine

engine = create_engine('postgresql://postgres@localhost:5432/postgres') #port/database_name
print(str(engine))
#the above engine creates a Dialec object as wel as Pool object
#which establish DBAPI connection at localhost:5432

app = Flask(__name__)
app.config['SECRET_KEY'] = '853263c31078c2bbd672377ef14c39b0'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///site.db'
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'
login_manager.login_message_category = 'info'

from Radosc import routes
