from sqlalchemy import CheckConstraint
from sqlalchemy import Column
from sqlalchemy import Date
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import MetaData
from sqlalchemy import String
from sqlalchemy import Table
from sqlalchemy.orm import mapper


class Serials:
    """
        Model represents Serials table
    """

    def __init__(self):
        super().__init__()
        self.serial_id = None
        self.title = None
        self.release_year = None
        self.country = None

        self.seasons_count = None
        self.episodes_count = None

    def __str__(self):
        return "Serial # %s (%s)" % (self.serial_id, self.title)


class Seasons:
    """
        Model represents Episodes table
    """

    def __init__(self):
        super.__init__()
        self.season_id = None
        self.season_number = None
        self.serial_id = None


class Episodes:
    """
        Model represents Episodes table
    """

    def __init__(self):
        super.__init__()
        self.episode_id = None
        self.episode_number = None
        self.title = None
        self.release_date = None
        self.duration = None
        self.rating = None
        self.season_id = None

    def __str__(self):
        return "Episode # %s (%s)" % (self.episode_id, self.title)


metadata = MetaData()

# Create mappings
SerialsMapping = Table('serials', metadata,
                       Column('serial_id', Integer, primary_key=True),
                       Column('title', String(100)),
                       Column('release_year', Date),
                       Column('country', String(50))
                       )
SeasonsMapping = Table('seasons', metadata,
                       Column('season_id', Integer, primary_key=True),
                       Column('season_number', Integer, nullable=False),
                       Column('serial_id', Integer,
                              ForeignKey(SerialsMapping.columns['serial_id'], ondelete='CASCADE', onupdate='CASCADE'))
                       )
EpisodesMapping = Table('episodes', metadata,
                        Column('episode_id', Integer, primary_key=True),
                        Column('episode_number', Integer, nullable=False),
                        Column('title', String(20), nullable=False),
                        Column('release_date', Date, nullable=False),
                        Column('duration', Integer, nullable=False),
                        Column('rating', Integer,
                               CheckConstraint('rating > 0 AND rating < 11', name='Positive rating')),
                        Column('season_id', Integer,
                               ForeignKey(SeasonsMapping.columns['serial_id'], ondelete='CASCADE', onupdate='CASCADE')),
                        )

# Map classes to mappings
mapper(Serials, SerialsMapping)
mapper(Seasons, SeasonsMapping)
mapper(Episodes, EpisodesMapping)
