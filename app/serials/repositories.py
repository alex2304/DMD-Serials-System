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
            serial.seasons_count = cls.get_serial_seasons_count(serial.serial_id)
            serial.episodes_count = cls.get_serial_episodes_count(serial.serial_id)
            serials_with_counts.append(serial)

        return serials

    @classmethod
    def get_all_serials(cls) -> List[Serial]:
        """
        :return: all serials from table Serials
        """
        serials_columns_string = qh.get_columns_string(SerialsMapping)

        all_serials_query = qe.execute(db,
                                       "SELECT {serials_columns} FROM {serials_table}",
                                       *[Serial],
                                       **{'serials_columns': serials_columns_string,
                                          'serials_table': SerialsMapping.description})

        return cls._get_serials_with_counts(all_serials_query)

    @classmethod
    def get_serial_by_id(cls, serial_id: int) -> Serial:
        """
        Get info about the serial with id == serial_id
        :param serial_id: id of the serial (should be a whole number)
        :return: Info about the serial with serial_id, or None, if the serial doesn't exist
        """
        serial_id = int(serial_id)
        serials_columns_string = qh.get_columns_string(SerialsMapping)

        serial_query = qe.execute(db,
                                  "SELECT {serials_columns} FROM {serials_table} WHERE serial_id = {serial_id}",
                                  *[Serial],
                                  **{'serials_columns': serials_columns_string,
                                     'serials_table': SerialsMapping.description,
                                     'serial_id': serial_id})

        return serial_query[0]

    @classmethod
    def get_serial_episodes_count(cls, serial_id: int) -> int:
        """
        Get count of the episodes for the serial with serial_id
        :param serial_id: id of the serial (should be a whole number)
        :return: number of the episodes of the serial
        """
        serial_id = int(serial_id)
        episodes_columns_string = qh.get_columns_string(EpisodesMapping, 'episode')
        serials_episodes = qe.execute(db,
                                    "SELECT {episodes_columns} "
                                    " FROM {episodes_table} AS episode INNER JOIN "
                                    " (SELECT season.season_number, season.serial_id FROM {seasons_table} AS season "
                                    " LEFT JOIN {serials_table} as serial ON season.serial_id = serial.serial_id "
                                    " WHERE serial.serial_id = {serial_id}) AS s "
                                    " ON episode.season_number = s.season_number",
                                    *[Episode],
                                    **{'episodes_columns': episodes_columns_string,
                                       'episodes_table': EpisodesMapping.description,
                                       'seasons_table': SeasonsMapping.description,
                                       'serials_table': SerialsMapping.description,
                                       'serial_id': serial_id})

        return len(serials_episodes)

    @classmethod
    def get_serial_seasons_count(cls, serial_id: int) -> int:
        """
        Get count of the seasons for the serial with serial_id
        :param serial_id: id of the serial (should be a whole number)
        :return: number of the seasons of the serial
        """
        serial_id = int(serial_id)
        serials_columns_string = qh.get_columns_string(SerialsMapping, 'serial')
        seasons_columns_string = qh.get_columns_string(SeasonsMapping, 'season')
        serials_seasons = qe.execute(db,
                                   "SELECT {serials_columns}, {seasons_columns}"
                                   " FROM {seasons_table} AS season INNER JOIN "
                                   " {serials_table} as serial ON season.serial_id = serial.serial_id "
                                   " WHERE serial.serial_id = {serial_id}",
                                   *[Serial, Season],
                                   **{'serials_columns': serials_columns_string,
                                      'seasons_columns': seasons_columns_string,
                                      'seasons_table': SeasonsMapping.description,
                                      'serials_table': SerialsMapping.description,
                                      'serial_id': serial_id})

        return len(serials_seasons)
