import os

from app import build_app

if __name__ == '__main__':

    # Resolving config name
    # If you need not default config - just set environment variable FLASK_CONFIG to 'production'
    # os.environ['FLASK_CONFIG'] = 'production'
    config_name = os.getenv('FLASK_CONFIG', 'development')
    print(" * Loading configuration %s" % config_name)

    # Building and run the Flask application
    app = build_app(config_name)
    app.run()
