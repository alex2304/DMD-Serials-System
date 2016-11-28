import os

import psycopg2

from app import build_app


def drop_create_db(_app):
    def connect_db():
        """Connects to the database."""
        rv = psycopg2.connect(_app.config['SQLALCHEMY_DATABASE_URI'])
        return rv

    connection = connect_db()
    with _app.open_resource('../sql/drop_tables.sql', mode='r') as f:
        # try:
        connection.cursor().execute(f.read())
        # except:
        #     pass
    with _app.open_resource('../sql/create_tables_with_data.sql', mode='r') as f:
        # try:
        connection.cursor().execute(f.read())
        # except:
        #     pass
    with _app.open_resource('../sql/stored_functions.sql', mode='r') as f:
        connection.cursor().execute(f.read())

    with _app.open_resource('../sql/stored_functions_statistics.sql', mode='r') as f:
        connection.cursor().execute(f.read())

    with _app.open_resource('../sql/test.sql', mode='r') as f:
        connection.cursor().execute(f.read())

    connection.commit()
    print(' * Database has been successfully recreated')
    connection.close()

if __name__ == '__main__':

    # Resolving config name
    # If you need not default config - just set environment variable FLASK_CONFIG to 'production'
    # os.environ['FLASK_CONFIG'] = 'production'
    config_name = os.getenv('FLASK_CONFIG', 'development')
    print(" * Loading configuration %s" % config_name)

    # Building and run the Flask application
    app = build_app(config_name)
    if config_name.lower() == 'development':
        drop_create_db(app)
    app.run()
