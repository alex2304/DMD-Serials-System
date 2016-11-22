from flask import render_template

from . import statistics


@statistics.route('statistics/')
def process_statistics():

    return render_template('statistics.html')
