"""
    Main application of the system
"""

from flask import Blueprint

serials = Blueprint(name='serials', import_name=__name__, template_folder='templates')

from . import routes
