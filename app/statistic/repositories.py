class StatisticsRepository:
    """
    Repository class for working with persons
    """
    #
    # @classmethod
    # def _get_extended_serials(cls, serials: List[Serial]) -> List[Serial]:
    #     """
    #     Adding count of the seasons and episodes in each serial from list
    #     :param serials: list of the serials
    #     :return: new list of the serials, where every serial has episodes count and seasons count
    #     """
    #     extended_serials = []
    #
    #     for serial in serials:
    #         serial.seasons = cls.get_serial_seasons(serial.serial_id)
    #         serial.seasons_count = len(serial.seasons)
    #
    #         serial.episodes = cls.get_serial_episodes(serial.serial_id)
    #         serial.episodes_count = len(serial.episodes)
    #
    #         extended_serials.append(serial)
    #
    #     return extended_serials
