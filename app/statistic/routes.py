from flask import render_template

from . import statistics


@statistics.route('statistic/')
def process_actors():

    return render_template('serials.html')
