from typing import List

from app import db_engine
from app.utils.query_executor import QueryExecutor as qe
from app.utils.query_helper import QueryHelper as qh


class StatisticsRepository:
    """
    Repository class for working with statistics
    """

    @classmethod
    def get_top5_serials_with_longest_average_episode(cls):

        query_result = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_top5_serials_with_longest_average_episode()")

        return [{"title": str(row['serial_title']).rstrip(),
                 "avg_episode_length": row['average_episode_length']}
                for row in query_result]

    @classmethod
    def get_top5_serials_in_genre(cls, genre_title):

        query_result = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_top5_serials_in_genre({genre_title})",
                                            **{
                                                "genre_title": genre_title
                                            })

        return [{"title": str(row['serial_title']).rstrip(),
                 "rating": round(row['serial_rating'], 2)}
                for row in query_result]

    @classmethod
    def get_actor_roles(cls, actor_name):

        query_result = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_actor_roles({actor_name})",
                                            **{
                                                "actor_name": actor_name
                                            })

        return [{"serial_title": str(row['serial_title']).rstrip(),
                 "episode_title": str(row['episode_title']).rstrip(),
                 "role_name": str(row['role_name']).rstrip()}
                for row in query_result]

    @classmethod
    def get_shortest_serials_in_genres(cls, genres_list: List[str]):

        query_result = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_shortest_serials_in_genres({genres_list})",
                                            **{
                                                "genres_list": qh.get_sql_array(genres_list)
                                            })

        return [{"serial_title": str(row['serial_title']).rstrip(),
                 "duration": row['serial_duration']}
                for row in query_result]

    @classmethod
    def get_top5_creators(cls):

        query_result = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_top5_creators()")

        return [{"name": str(row['creator_name']).rstrip(),
                 "rating": row['average_serials_rating']}
                for row in query_result]
