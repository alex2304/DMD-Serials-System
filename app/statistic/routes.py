from flask import render_template

from . import statistics


@statistics.route('/')
def process_statistics():

    return render_template('statistics.html')
