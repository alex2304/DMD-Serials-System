from flask import render_template

from . import persons


@persons.route('actors/')
def process_actors():

    return render_template('serials.html')
