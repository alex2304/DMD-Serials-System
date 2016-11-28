from flask import render_template

from . import persons


@persons.route('/actors/<int:actor_id>')
@persons.route('/actors')
def process_actors(actor_id = None):

    if actor_id:
        return render_template('actor_info.html')

    return render_template('actors.html')



@persons.route('/writers/<int:writer_id>')
@persons.route('/writers')
def process_writers(writer_id = None):
    if writer_id:
        return render_template('writer_info.html')

    return render_template('writers.html')

@persons.route('/directors/<int:director_id>')
@persons.route('/directors')
def process_directors(director_id = None):
    if director_id:
        return render_template('director_info.html')

    return render_template('directors.html')
