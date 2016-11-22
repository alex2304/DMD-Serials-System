from flask import Response
from flask import json
from flask import render_template
from flask import request

from app.statistic.repositories import StatisticsRepository
from . import statistics


@statistics.route('/')
def process_statistics():

    top5_longest_episodes = StatisticsRepository.get_top5_serials_with_longest_average_episode()
    top5_creators = StatisticsRepository.get_top5_creators()

    additional_name = ""
    additional_value = ""

    if request.args.get('top5_serials_in_genre'):
        result = StatisticsRepository.get_top5_serials_in_genre(request.args['top5_serials_in_genre'])
        return Response(json.dumps(result), mimetype='application/json')
    elif request.args.get('top5_shortest_serials_in_genres'):
        result = StatisticsRepository.get_shortest_serials_in_genres(str(request.args['top5_shortest_serials_in_genres']).split(','))
        return Response(json.dumps(result), mimetype='application/json')
    elif request.args.get('actor_roles'):
        result = StatisticsRepository.get_actor_roles(request.args['actor_roles'])
        return Response(json.dumps(result), mimetype='application/json')

    return render_template('statistics.html',
                           **{"top5_creators": top5_creators,
                              "top5_longest_episodes": top5_longest_episodes,
                              additional_name: additional_value
                             })

# @statistics.route('/')
# def process_statistics():
#
#     top5_longest_episodes = StatisticsRepository.get_top5_serials_with_longest_average_episode()
#     top5_creators = StatisticsRepository.get_top5_creators()
#
#     additional_name = ""
#     additional_value = ""
#
#     if request.args.get('top5_serials_in_genre'):
#         additional_name = "top5_serials_in_genre"
#         additional_value = StatisticsRepository.get_top5_serials_in_genre(request.args['top5_serials_in_genre'])
#     elif request.args.get('top5_shortest_serials_in_genres'):
#         additional_name = "top5_shortest_in_genres"
#         additional_value = StatisticsRepository.get_shortest_serials_in_genres(str(request.args['top5_serials_in_genre']).split(','))
#     elif request.args.get('actor_roles'):
#         additional_name = "actor_roles"
#         additional_value = StatisticsRepository.get_actor_roles(request.args['actor_roles'])
#
#     return render_template('statistics.html',
#                            **{"top5_creators": top5_creators,
#                               "top5_longest_episodes": top5_longest_episodes,
#                               additional_name: additional_value
#                              })
