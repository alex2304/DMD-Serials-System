import os

from flask import Flask

"""
    Building the app, registering blueprints
"""


def build_app(default_config_name):

    app = Flask(__name__)

    # Applying config
    default_config_filename = os.path.join(os.getcwd(), 'config', default_config_name + '.py')
    app.config.from_pyfile(default_config_filename)     # Set default config
    loaded = app.config.from_envvar('FLASK_CONFIG', silent=True)    # Override by config from ENVIRONMENT variable
    if loaded:
        print("Config from ENVIRONMENT loaded")

    # Register blueprints
    from .main import main as main_blueprint
    app.register_blueprint(main_blueprint, url_prefix='/')

    return app
