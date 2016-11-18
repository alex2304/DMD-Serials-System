from flask import abort
from flask import render_template
from flask import request

from app.serials.repositories import SerialsRepository
from . import serials


@serials.route('serials/', methods=['POST'])
def filter_serials():

    title_part = request.form['inputTitle']
    start_year, end_year = list(map(lambda x: int(x), request.form['inputYear'].split(',')))
    start_rating, end_rating = list(map(lambda x: int(x), request.form['inputRating'].split(',')))
    countries_list = request.form['inputCountry'].split(',') if request.form['inputCountry'] != '' else []
    actors_list = request.form['inputActor'].split(',') if request.form['inputActor'] != '' else []
    genres_list = request.form['inputGenre'].split(',') if request.form['inputGenre'] != '' else []

    filtered_serials = SerialsRepository.get_filtered_serials(title_part,
                                                              start_year, end_year,
                                                              start_rating, end_rating,
                                                              countries_list, actors_list, genres_list)

    return render_template('serials.html', serials_info=filtered_serials)


@serials.route('/')
def index():
    serials_info = SerialsRepository.get_all_serials()
    return render_template('serials.html', serials_info=serials_info)


@serials.route('serials/')
@serials.route('serials/<int:serial_id>')
def serials(serial_id=None):
    """
    Routes to the page with info about serial(s)
    :param serial_id: id of the serial which info it needs to show
    :return: renders template 'serials.html' with all serials, or template 'serial_info.html' for serial with serial_id
    """
    if serial_id is not None:
        episodes_of_serial = SerialsRepository.get_serial_episodes(serial_id)
        serial_info = SerialsRepository.get_serial_by_id(serial_id)
        if episodes_of_serial:
            return render_template('serial_info.html', serial_info=serial_info, episodes_info=episodes_of_serial)
        else:
            abort(404)

    serials_info = SerialsRepository.get_all_serials('title')
    return render_template('serials.html', serials_info=serials_info)


# @main.route('episodes/<int:episode_id>')
# def episodes(episode_id=None):
#     episode_info = episode_id  # TODO: need to retrieve serial information form DB
#     if episode_id is not None:
#         return render_template('episode_info.html', episode_info=episode_info)
#
#     return redirect(url_for('serials'))
#
#
# @main.route('actors/')
# @main.route('actors/<int:actor_id>')
# def actors(actor_id=None):
#     actor_info = actor_id  # TODO: need to retrieve actor information form DB
#     if actor_id is not None:
#         return render_template('actor_info.html', actor_info=actor_info)
#
#     return render_template('actors.html')


