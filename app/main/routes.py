from flask import render_template

from app.main.repositories import SerialsRepository
from . import main


@main.route('/')
def serials():
    all_serials = SerialsRepository.get_all_serials()
    return render_template('main.html', serials=all_serials)
