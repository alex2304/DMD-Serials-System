"""
    Main application of the system
"""

from flask import Blueprint

statistics = Blueprint(name='statistics', import_name=__name__, template_folder='templates')

from . import routes
