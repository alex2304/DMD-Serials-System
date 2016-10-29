from flask import render_template

from . import main


@main.route('/')
def index():
    return render_template('index.html')


@main.route('/serial/<int:serial_id>')
def serial(serial_id):
    serial_info = serial_id  # TODO: need to retrieve serial information form DB
    return render_template('serial.html', serial_info=serial_info)