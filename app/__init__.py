import os

from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine

"""
    Building the app, registering blueprints
"""

db = SQLAlchemy()
db_engine = None


def build_app(default_config_name):

    app = Flask(__name__)

    # Applying config
    default_config_filename = os.path.join(os.getcwd(), 'config', default_config_name + '.py')
    app.config.from_pyfile(default_config_filename)     # Set default config
    loaded = app.config.from_envvar('FLASK_CONFIG', silent=True)    # Override by config from ENVIRONMENT variable
    if loaded:
        print("Config from ENVIRONMENT loaded")

    # Register instruments
    db.init_app(app)
    global db_engine
    db_engine = create_engine(app.config['SQLALCHEMY_DATABASE_URI'])

    # Register blueprints
    from .serials import serials as serials_blueprint
    app.register_blueprint(serials_blueprint, url_prefix='/')
    from .persons import persons as persons_blueprint
    app.register_blueprint(persons_blueprint, url_prefix='/persons')

    return app
