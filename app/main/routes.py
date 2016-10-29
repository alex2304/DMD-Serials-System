from flask import render_template

from . import main


@main.route('/')
def index():
    return render_template('serials.html')


@main.route('serials/')
@main.route('serials/<int:serial_id>')
def serials(serial_id=None):
    serial_info = serial_id  # TODO: need to retrieve serial information form DB
    if serial_id is not None:
        return render_template('serial_info.html', serial_info=serial_info)

    return render_template('serials.html')


