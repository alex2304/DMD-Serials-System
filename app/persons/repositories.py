from typing import List

from app import db
from app.serials.models import SerialsMapping, Serial
from app.utils.query_executor import QueryExecutor as qe
from app.utils.query_helper import QueryHelper as qh


class PersonsRepository:
    """
    Repository class for working with persons
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
