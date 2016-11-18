from typing import List

from app import db
from app.serials.models import SerialsMapping, Serial, Episode, EpisodesMapping, SeasonsMapping, Season
from app.utils.query_executor import QueryExecutor as qe
from app.utils.query_helper import QueryHelper as qh


class SerialsRepository:
    """
    Repository class for working with serials
    """

    @classmethod
    def _get_serials_with_counts(cls, serials: List[Serial]) -> List[Serial]:
        """
        Adding count of the seasons and episodes in each serial from list
        :param serials: list of the serials
        :return: new list of the serials, where every serial has episodes count and seasons count
        """
        serials_with_counts = []

        for serial in serials:
            serial.seasons_count = len(cls.get_serial_seasons(serial.serial_id))
            serial.episodes_count = len(cls.get_serial_episodes(serial.serial_id))
            serials_with_counts.append(serial)

        return serials

    @classmethod
    def get_all_serials(cls, order_by_field=None) -> List[Serial]:
        """
        :return: all serials from table Serials
        """
        serials_columns_string = qh.get_columns_string(SerialsMapping)

        if order_by_field is None:
            all_serials_query = qe.execute(db,
                                           "SELECT {serials_columns} FROM {serials_table}",
                                           *[Serial],
                                           **{'serials_columns': serials_columns_string,
                                              'serials_table': SerialsMapping.description})
        else:
            all_serials_query = qe.execute(db,
                                           "SELECT {serials_columns} FROM {serials_table} ORDER BY {order_by_field}",
                                           *[Serial],
                                           **{'serials_columns': serials_columns_string,
                                              'serials_table': SerialsMapping.description,
                                              'order_by_field': order_by_field})

        return cls._get_serials_with_counts(all_serials_query)

    @classmethod
    def get_filtered_serials(cls, title_part: str, start_year: int, end_year: int, start_rating: int, end_rating: int,
                             countries_list: List[str], actors_list: List[str], genres_list: List[str]) -> List[Serial]:
        """
        Get serials filtered by given params
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

        all_serials_query = qe.execute(db,
                                       "SELECT {serials_columns} "
                                       "FROM get_filtered_serials('{title_part}', {start_year}, "
                                       "{end_year}, {start_rating}, {end_rating}, {countries}, {actors}, {genres})",
                                       *[Serial],
                                       **{'serials_columns': serials_columns_string,
                                          'title_part': title_part,
                                          'start_year': start_year,
                                          'end_year': end_year,
                                          'start_rating': start_rating,
                                          'end_rating': end_rating,
                                          'countries': qh.get_range_string(countries_list),
                                          'actors': qh.get_range_string(actors_list),
                                          'genres': qh.get_range_string(genres_list)})

        return cls._get_serials_with_counts(all_serials_query)

    @classmethod
    def get_serial_episodes(cls, serial_id: int) -> List[Episode]:
        """
        Get episodes for the serial with serial_id
        :param serial_id: id of the serial (should be a whole number)
        :return: episodes of the serial
        """
        serial_id = int(serial_id)
        episodes_columns_string = qh.get_columns_string(EpisodesMapping, 'episode')
        serials_episodes = qe.execute(db,
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
        serial_id = int(serial_id)
        seasons_columns_string = qh.get_columns_string(SeasonsMapping, 'season')

        # connection = psycopg2.connect('postgresql://postgres:postgres@localhost/SerialsSystem')
        #
        # query_str = "SELECT {seasons_columns} FROM {seasons_table}"\
        #     .format(seasons_columns=seasons_columns_string,
        #                             seasons_table=SeasonsMapping.description)
        # connection.cursor().execute(query_str)
        #
        # temp_result = connection.cursor().fetchall()
        # connection.commit()
        # connection.close()

        serials_seasons = qe.execute(db,
                                     "SELECT {seasons_columns}"
                                     " FROM {seasons_table} WHERE serial_id = {serial_id}",
                                     *[Season],
                                     **{'seasons_columns': seasons_columns_string,
                                        'seasons_table': SeasonsMapping.description,
                                        'serial_id': serial_id})

        return serials_seasons

    @classmethod
    def get_serial_by_id(cls, serial_id):
        serial_id = int(serial_id)
        serials_columns_string = qh.get_columns_string(SerialsMapping, 'serial')
        serial_with_id = qe.execute(db,
                                     "SELECT {serials_columns}"
                                     " FROM {serials_table} WHERE serial_id = {serial_id}",
                                     *[Serial],
                                     **{'serials_columns': serials_columns_string,
                                        'serials_table': SerialsMapping.description,
                                        'serial_id': serial_id})
        if len(serial_with_id) > 0:
            return serial_with_id[0]
        return None
