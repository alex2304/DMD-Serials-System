from flask import Response
from flask import abort
from flask import json
from flask import render_template
from flask import request

from app.persons.models import PersonsTypes
from app.persons.repositories import PersonsRepository
from . import persons


@persons.route('/actors/<int:actor_id>')
@persons.route('/actors')
def process_actors(actor_id=None):

    if actor_id:
        return process_person_page(actor_id, PersonsTypes.ACTOR, 'actor_info.html')

    person_name_part = request.args.get('person_name_part')
    if person_name_part:
        filtered_persons = PersonsRepository.get_filtered_persons(person_name_part, PersonsTypes.ACTOR)
        return Response(json.dumps(filtered_persons), mimetype='application/json')

    return render_template('actors.html')


@persons.route('/writers/<int:writer_id>')
@persons.route('/writers')
def process_writers(writer_id = None):
    if writer_id:
        return process_person_page(writer_id, PersonsTypes.WRITER, 'writer_info.html')

    return render_template('writers.html')


@persons.route('/directors/<int:director_id>')
@persons.route('/directors')
def process_directors(director_id = None):
    if director_id:
        return process_person_page(director_id, PersonsTypes.DIRECTOR, 'director_info.html')

    return render_template('directors.html')


def process_person_page(person_id, person_type, template_name):
    person_info = PersonsRepository.get_person_by_id(int(person_id), person_type)
    episodes_info = PersonsRepository.get_top_episodes_of(int(person_id), person_type)

    if person_info:
        return render_template(template_name, person_info=person_info, episodes_info=episodes_info)
    else:
        abort(404)