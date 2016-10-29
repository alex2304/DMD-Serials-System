from flask import redirect
from flask import render_template
from flask import url_for

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


@main.route('episodes/<int:episode_id>')
def episodes(episode_id=None):
    episode_info = episode_id  # TODO: need to retrieve serial information form DB
    if episode_id is not None:
        return render_template('episode_info.html', episode_info=episode_info)

    return redirect(url_for('serials'))


@main.route('actors/')
@main.route('actors/<int:actor_id>')
def actors(actor_id=None):
    actor_info = actor_id  # TODO: need to retrieve actor information form DB
    if actor_id is not None:
        return render_template('actor_info.html', actor_info=actor_info)

    return render_template('actors.html')


