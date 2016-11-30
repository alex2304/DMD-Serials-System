"""
Development configuration file
"""

DEBUG = True
SQLALCHEMY_DATABASE_URI = 'postgresql://dmduser:dmdpass@localhost/dmd'
SQLALCHEMY_TRACK_MODIFICATIONS = False      # This feature is not needed in our app, but default value raises warnings
