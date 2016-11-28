from typing import List, Dict

from app import db, db_engine
from app.serials.models import SerialsMapping, Serial, Episode, EpisodesMapping, SeasonsMapping, Season, SerialAward, \
    Played, Comment, Review
from app.utils.query_executor import QueryExecutor as qe
from app.utils.query_helper import QueryHelper as qh


class SerialsRepository:
    """
    Repository class for working with serials
    """

    @classmethod
    def _get_extended_serials(cls, serials: List[Serial]) -> List[Serial]:
        """
        Adding count of the seasons and episodes in each serial from list
        :param serials: list of the serials
        :return: new list of the serials, where every serial has episodes count and seasons count
        """
        extended_serials = []

        for serial in serials:
            serial.seasons = cls.get_serial_seasons(serial.serial_id)
            serial.seasons_count = len(serial.seasons)

            serial.episodes = cls.get_serial_episodes(serial.serial_id)
            serial.episodes_count = len(serial.episodes)

            serial.actors_names = cls.get_serial_actors_names(serial.serial_id)
            serial.genres_titles = cls.get_serial_genres_titles(serial.serial_id)
            serial.awards = cls.get_serial_awards(serial.serial_id)
            serial.creators_names = cls.get_serial_creators_names(serial.serial_id)

            serial.played = cls.get_serial_played(serial.serial_id)
            extended_serials.append(serial)

        return extended_serials

    @classmethod
    def get_all_serials(cls, order_by_field=None) -> List[Serial]:
        """
        :return: all serials from table Serials
        """
        serials_columns_string = qh.get_columns_string(SerialsMapping)

        if order_by_field is None:
            all_serials_query = qe.execute_mapped(db,
                                           "SELECT {serials_columns} FROM {serials_table}",
                                                  *[Serial],
                                                  **{'serials_columns': serials_columns_string,
                                              'serials_table': SerialsMapping.description})
        else:
            all_serials_query = qe.execute_mapped(db,
                                           "SELECT {serials_columns} FROM {serials_table} ORDER BY {order_by_field}",
                                                  *[Serial],
                                                  **{'serials_columns': serials_columns_string,
                                              'serials_table': SerialsMapping.description,
                                              'order_by_field': order_by_field})

        return cls._get_extended_serials(all_serials_query)

    @classmethod
    def get_filtered_serials(cls, title_part: str, start_year: int, end_year: int, start_rating: int, end_rating: int,
                             countries_list: List[str], actors_list: List[str], genres_list: List[str],
                             start_duration: int, end_duration: int) -> List[Serial]:
        """
        Get serials filtered by given params
        :param start_duration:
        :param end_duration:
        :param title_part:
        :param end_rating:
        :param start_rating:
        :param actors_list:
        :param genres_list:
        :param start_year: start year of the serials
        :param end_year: end year of the serials
        :param countries_list: list of the countries from wich serials needed
        :return: list of serials
        """
        serials_columns_string = qh.get_columns_string(SerialsMapping)

        all_serials_query = qe.execute_mapped(db,
                                           "SELECT {serials_columns}"
                                           " FROM get_filtered_serials('{title_part}', {start_year}, "
                                           " {end_year}, {start_rating}, {end_rating}, {countries}, {actors}, {genres},"
                                           " {start_duration}, {end_duration})",
                                              *[Serial],
                                              **{'serials_columns': serials_columns_string,
                                                  'title_part': title_part,
                                                  'start_year': start_year,
                                                  'end_year': end_year,
                                                  'start_rating': start_rating,
                                                  'end_rating': end_rating,
                                                  'countries': qh.get_sql_array(countries_list),
                                                  'actors': qh.get_sql_array(actors_list),
                                                  'genres': qh.get_sql_array(genres_list),
                                                 'start_duration': start_duration,
                                                 'end_duration': end_duration})

        return cls._get_extended_serials(all_serials_query)

    @classmethod
    def get_serial_episodes(cls, serial_id: int) -> List[Episode]:
        """
        Get episodes for the serial with serial_id
        :param serial_id: id of the serial (should be a whole number)
        :return: episodes of the serial
        """
        serial_id = int(serial_id)
        episodes_columns_string = qh.get_columns_string(EpisodesMapping, 'episode')
        serials_episodes = qe.execute_mapped(db,
                                        "SELECT {episodes_columns} "
                                        " FROM {episodes_table} WHERE serial_id = {serial_id}",
                                             *[Episode],
                                             **{'episodes_columns': episodes_columns_string,
                                           'episodes_table': EpisodesMapping.description,
                                           'serial_id': serial_id})

        return serials_episodes

    @classmethod
    def get_all_countries_list(cls) -> List[str]:
        """
        Return list of all countries from which serials exists
        :return: list of countries
        """
        serials = cls.get_all_serials()
        countries_list = map(lambda s: s.country, serials)
        return list(set(countries_list))

    @classmethod
    def get_serial_seasons(cls, serial_id: int) -> List[Season]:
        """
        Get seasons for the serial with serial_id
        :param serial_id: id of the serial (should be a whole number)
        :return: seasons of the serial
        """

        serial_seasons = qe.execute_arbitrary(db_engine,
                                                 "SELECT *"
                                                 " FROM get_seasons_of_serial({serial_id})",
                                                 **{'serial_id': serial_id})

        return [Season(row['season_number'], row['serial_id'], row['release_date']) for row in serial_seasons]

    @classmethod
    def get_serial_by_id(cls, serial_id, extended=True):

        serial_id = int(serial_id)
        serials_columns_string = qh.get_columns_string(SerialsMapping, 'serial')
        serial_with_id = qe.execute_mapped(db,
                                     "SELECT {serials_columns}"
                                     " FROM {serials_table} WHERE serial_id = {serial_id}",
                                           *[Serial],
                                           **{'serials_columns': serials_columns_string,
                                        'serials_table': SerialsMapping.description,
                                        'serial_id': serial_id})
        if len(serial_with_id) > 0:
            return cls._get_extended_serials(serial_with_id)[0] if extended else serial_with_id[0]
        return None

    @classmethod
    def get_serial_genres_titles(cls, serial_id: int) -> List[str]:
        """
        Get titles of serial's genres
        :param serial_id: id of the serial (should be a whole number)
        :return: titles of the serial's genres ['Title1', 'Title2', ...]
        """
        serial_id = int(serial_id)

        serial_genres = qe.execute_arbitrary(db_engine,
                                              "SELECT *"
                                              " FROM get_genres_of_serial_titles({serial_id})",
                                              **{'serial_id': serial_id})

        return [row['genre_title'].rstrip() for row in serial_genres]

    @classmethod
    def get_serial_actors_names(cls, serial_id: int) -> List[str]:
        """
        Get actors names of the serial
        :param serial_id: id of the serial (should be a whole number)
        :return: names of the serial's actors
        """
        serial_id = int(serial_id)

        serial_actors = qe.execute_arbitrary(db_engine,
                                              "SELECT *"
                                              " FROM get_actors_names_of({serial_id})",
                                              **{'serial_id': serial_id})

        return [str(row['actor_name']).rstrip() for row in serial_actors]

    @classmethod
    def get_serial_awards(cls, serial_id: int) -> List[SerialAward]:
        """
        Get serial Awards
        :param serial_id: id of the serial (should be a whole number)
        :return: List of SerialAward
        """
        serial_id = int(serial_id)

        serial_actors = qe.execute_arbitrary(db_engine,
                                              "SELECT *"
                                              " FROM get_serial_awards({serial_id})",
                                              **{'serial_id': serial_id})

        return [SerialAward(serial_id, str(row['award_title']).rstrip(), str(row['award_year']).rstrip())
                for row in serial_actors]

    @classmethod
    def get_serial_creators_names(cls, serial_id):
        """
        Get creators names of the serial
        :param serial_id: id of the serial (should be a whole number)
        :return: names of the serial's creators
        """
        serial_id = int(serial_id)

        serial_actors = qe.execute_arbitrary(db_engine,
                                              "SELECT *"
                                              " FROM get_creators_of_serial_names({serial_id})",
                                              **{'serial_id': serial_id})

        return [str(row['creator_name']).rstrip() for row in serial_actors]

    @classmethod
    def get_serial_played(cls, serial_id):

        serial_played = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_serial_played({serial_id})",
                                             **{'serial_id': serial_id})

        return [Played(serial_id, None, None,
                       row['actor_id'],
                       str(row['actor_name']).rstrip(), str(row['role_title']).rstrip(),
                       str(row['award_title']).rstrip(), row['award_year'])
                for row in serial_played]

    @classmethod
    def get_serials_in_genres_counts(cls) -> Dict:

        genres = qe.execute_arbitrary(db_engine,
                                      "SELECT *"
                                      " FROM get_serials_in_genres_counts()",
                                     )

        return {str(row['genre_title']): row['serials_count'] for row in genres}

    @classmethod
    def get_comments_of(cls, serial_id, season_number):
        query_result = qe.execute_arbitrary(db_engine,
                                            "SELECT *"
                                            " FROM get_comments_of({serial_id}, {season_number})",
                                            **{'serial_id': serial_id,
                                                'season_number': season_number})

        return [Comment(serial_id, season_number,
                        str(row['comment_text']), row['comment_date'],
                        str(row['user_login']))
                for row in query_result]

    @classmethod
    def get_reviews_of(cls, serial_id):
        query_result = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_reviews_of({serial_id})",
                                             **{'serial_id': serial_id})

        return [Review(serial_id, None,
                        str(row['title']),
                        str(row['review_text']), row['review_date'],
                        str(row['user_login']))
                for row in query_result]


class SeasonsRepository:

    @classmethod
    def _get_extended_seasons(cls, seasons):
        extended_seasons = []

        for season in seasons:
            season.episodes = cls.get_season_episodes(season.serial_id, season.season_number)
            season.seasons_count = len(season.episodes)

            season.actors_names = cls.get_season_actors_names(season.serial_id, season.season_number)
            season.rating = cls.get_season_rating(season.serial_id, season.season_number)
            season.duration = cls.get_season_duration(season.serial_id, season.season_number)
            season.release_date = cls.get_season_date(season.serial_id, season.season_number)
            extended_seasons.append(season)

        return extended_seasons

    @classmethod
    def get_season_by_number(cls, serial_id, season_number):
        serial_id = int(serial_id)
        seasons_columns_string = qh.get_columns_string(SeasonsMapping, 'season')
        seasons_result = qe.execute_mapped(db,
                                           "SELECT {seasons_columns}"
                                           " FROM {seasons_table} WHERE serial_id = {serial_id}"
                                           " AND season_number = {season_number}",
                                           *[Season],
                                           **{'seasons_columns': seasons_columns_string,
                                              'seasons_table': SeasonsMapping.description,
                                              'serial_id': serial_id,
                                              'season_number': season_number
                                              })
        if len(seasons_result) > 0:
            return cls._get_extended_seasons(seasons_result)[0]
        return None

    @classmethod
    def get_season_episodes(cls, serial_id, season_number):

        episodes_columns_string = qh.get_columns_string(EpisodesMapping, 'episode')
        season_episodes = qe.execute_mapped(db,
                                        "SELECT {episodes_columns} "
                                        " FROM {episodes_table} WHERE serial_id = {serial_id}"
                                        " AND season_number = {season_number}",
                                             *[Episode],
                                             **{'episodes_columns': episodes_columns_string,
                                                'episodes_table': EpisodesMapping.description,
                                                'serial_id': serial_id,
                                                'season_number': season_number})
        return season_episodes

    @classmethod
    def get_season_actors_names(cls, serial_id, season_number):
        serial_actors = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_actors_names_of({serial_id}, {season_number})",
                                             **{'serial_id': serial_id,
                                                'season_number': season_number})

        return [str(row['actor_name']).rstrip() for row in serial_actors]

    @classmethod
    def get_season_rating(cls, serial_id, season_number):
        season_rating = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_rating_of({serial_id}, {season_number})",
                                             **{'serial_id': serial_id,
                                                'season_number': season_number})
        if len(season_rating) > 0:
            return round(season_rating[0]['get_rating_of'], 2)
        return None

    @classmethod
    def get_season_duration(cls, serial_id, season_number):
        season_duration = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_duration_of({serial_id}, {season_number})",
                                             **{'serial_id': serial_id,
                                                'season_number': season_number})

        if len(season_duration) > 0:
            return season_duration[0]['get_duration_of']
        return None

    @classmethod
    def get_season_date(cls, serial_id, season_number):
        season_date = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_season_date({serial_id}, {season_number})",
                                             **{'serial_id': serial_id,
                                                'season_number': season_number})

        if len(season_date) > 0:
            return season_date[0]['get_season_date']
        return None


class EpisodesRepository:

    @classmethod
    def _get_extended_episodes(cls, episodes):
        extended_episodes = []

        for e in episodes:
            e.directors_names = cls.get_episode_directors_names(e.serial_id, e.season_number, e.episode_number)
            e.writers_names = cls.get_episode_writers_names(e.serial_id, e.season_number, e.episode_number)
            e.played = cls.get_episode_played(e.serial_id, e.season_number, e.episode_number)

            extended_episodes.append(e)

        return extended_episodes

    @classmethod
    def get_episode_by_number(cls, serial_id, season_number, episode_number):

        episodes_columns_string = qh.get_columns_string(EpisodesMapping, 'episode')
        episode_result = qe.execute_mapped(db,
                                           "SELECT {columns}"
                                           " FROM {table} WHERE serial_id = {serial_id}"
                                           " AND season_number = {season_number}"
                                           " AND episode_number = {episode_number}",
                                           *[Episode],
                                           **{'columns': episodes_columns_string,
                                              'table': EpisodesMapping.description,
                                              'serial_id': serial_id,
                                              'season_number': season_number,
                                              'episode_number': episode_number
                                              })
        if len(episode_result) > 0:
            return cls._get_extended_episodes(episode_result)[0]
        return None

    @classmethod
    def get_episode_directors_names(cls, serial_id, season_number, episode_number):

        episode_directors = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_episode_directors_names({serial_id}, {season_number}, {episode_number})",
                                             **{'serial_id': serial_id,
                                                'season_number': season_number,
                                                'episode_number': episode_number})

        return {row['director_id']: str(row['director_name']).rstrip() for row in episode_directors}

    @classmethod
    def get_episode_writers_names(cls, serial_id, season_number, episode_number):

        episode_writers = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_episode_writers_names({serial_id}, {season_number}, {episode_number})",
                                             **{'serial_id': serial_id,
                                                'season_number': season_number,
                                                'episode_number': episode_number})

        return {row['writer_id']: str(row['writer_name']).rstrip() for row in episode_writers}

    @classmethod
    def get_episode_played(cls, serial_id, season_number, episode_number):

        episode_played = qe.execute_arbitrary(db_engine,
                                             "SELECT *"
                                             " FROM get_episode_played({serial_id}, {season_number}, {episode_number})",
                                             **{'serial_id': serial_id,
                                                'season_number': season_number,
                                                'episode_number': episode_number})

        return [Played(serial_id, season_number, episode_number,
                       row['actor_id'],
                       str(row['actor_name']).rstrip(), str(row['role_title']).rstrip(),
                       str(row['award_title']).rstrip(), row['award_year'])
                for row in episode_played]


