"""
    Main application of the system
"""

from flask import Blueprint

persons = Blueprint(name='persons', import_name=__name__, template_folder='templates')

from . import routes
