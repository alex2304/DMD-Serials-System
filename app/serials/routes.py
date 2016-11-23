from flask import abort
from flask import render_template
from flask import request

from app.serials.repositories import SerialsRepository, SeasonsRepository, EpisodesRepository
from . import serials


@serials.route('serials/', methods=['POST'])
def filter_serials():

    title_part = request.form['inputTitle']
    start_year, end_year = list(map(lambda x: int(x), request.form['inputYear'].split(',')))
    start_rating, end_rating = list(map(lambda x: int(x), request.form['inputRating'].split(',')))
    countries_list = request.form['inputCountry'].split(',') if request.form['inputCountry'] != '' else []
    actors_list = request.form['inputActor'].split(',') if request.form['inputActor'] != '' else []
    genres_list = request.form['inputGenre'].split(',') if request.form['inputGenre'] != '' else []
    start_duration, end_duration = list(map(lambda x: int(x), request.form['inputDuration'].split(',')))

    filtered_serials = SerialsRepository.get_filtered_serials(title_part,
                                                              start_year, end_year,
                                                              start_rating, end_rating,
                                                              countries_list, actors_list, genres_list,
                                                              start_duration, end_duration)

    serials_in_genres_counts = SerialsRepository.get_serials_in_genres_counts()
    return render_template('serials.html', serials_info=filtered_serials, genres=serials_in_genres_counts)


@serials.route('/')
def index():
    serials_info = SerialsRepository.get_all_serials()
    serials_in_genres_counts = SerialsRepository.get_serials_in_genres_counts()
    return render_template('serials.html', serials_info=serials_info,  genres=serials_in_genres_counts)


@serials.route('serials/')
@serials.route('serials/<int:serial_id>')
@serials.route('serials/<int:serial_id>/<int:season_number>')
@serials.route('serials/<int:serial_id>/<int:season_number>/<int:episode_number>')
def process_serials(serial_id=None, season_number=None, episode_number=None):
    """
    Routes to the page with info about serial(s)
    :param serial_id: id of the serial which info it needs to show
    :param season_number: number of the serial's season
    :param episode_number: number of the season's episode
    :return: renders serial page
    """
    if serial_id is not None:
        if season_number is not None:
            if episode_number is not None:
                return process_episode(serial_id, season_number, episode_number)
            else:
                return process_season(serial_id, season_number)
        else:
            return process_serial(serial_id)

    serials_info = SerialsRepository.get_all_serials(order_by_field='title')
    serials_in_genres_counts = SerialsRepository.get_serials_in_genres_counts()
    return render_template('serials.html', serials_info=serials_info, genres=serials_in_genres_counts)


def process_serial(serial_id):

    episodes_of_serial = SerialsRepository.get_serial_episodes(serial_id)
    serial_info = SerialsRepository.get_serial_by_id(serial_id)
    serial_played = SerialsRepository.get_serial_played(serial_id)
    if episodes_of_serial:
        serial_awards_list = list(map(lambda a: "%s(%s)" % (a.award_title, str(a.award_year)), serial_info.awards))
        reviews = SerialsRepository.get_reviews_of(serial_id)
        return render_template('serial_info.html', serial_info=serial_info,
                               episodes_info=episodes_of_serial,
                               serial_awards_list=serial_awards_list,
                               serial_played=serial_played,
                               reviews=reviews)
    else:
        abort(404)


def process_season(serial_id, season_number):

    serial_info = SerialsRepository.get_serial_by_id(serial_id, extended=False)
    season_info = SeasonsRepository.get_season_by_number(serial_id, season_number)
    comments = SerialsRepository.get_comments_of(serial_id, season_number)
    if season_info:
        return render_template('seasons.html', serial_info=serial_info, season_info=season_info, comments=comments)
    else:
        abort(404)


def process_episode(serial_id, season_number, episode_number):

    episode_info = EpisodesRepository.get_episode_by_number(serial_id, season_number, episode_number)
    if episode_info:
        return render_template('episodes.html', episode_info=episode_info)
    else:
        abort(404)


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


