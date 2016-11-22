from sqlalchemy import CheckConstraint
from sqlalchemy import Column
from sqlalchemy import Date
from sqlalchemy import ForeignKeyConstraint
from sqlalchemy import Integer
from sqlalchemy import MetaData
from sqlalchemy import String
from sqlalchemy import Table
from sqlalchemy.orm import mapper


class Serial:
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
        self.episodes = None
        self.seasons = None
        self.actors_names = None
        self.genres_titles = None
        self.awards = None
        self.creators_names = None
        self.played = None

    def __str__(self):
        return "Serial # %s (%s)" % (self.serial_id, self.title)


class Season:
    """
        Model represents Seasons table
    """

    def __init__(self, season_number=None, serial_id=None, release_date=None):
        self.season_number = season_number
        self.serial_id = serial_id

        self.release_date = release_date

        self.episodes = None
        self.seasons_count = None
        self.actors_names = None
        self.rating = None
        self.duration = None


class Episode:
    """
        Model represents Episodes table
    """

    def __init__(self):
        super.__init__()
        self.title = None
        self.release_date = None
        self.duration = None
        self.rating = None
        self.episode_number = None
        self.season_number = None
        self.serial_id = None

        self.directors_names = None
        self.writers_names = None
        self.played = None

    def __str__(self):
        return "Episode # %s (%s)" % (self.episode_number, self.title)


class SerialAward(object):
    """
        Model represents SerialAwards table
    """

    def __init__(self, serial_id, award_title, award_year):
        self.award_year = award_year
        self.award_title = award_title
        self.serial_id = serial_id


class Played:
    """
        Model represents Played table
    """

    def __init__(self, serial_id=None, season_number=None, episode_number=None, actor_name=None, role_title=None,
                 award_title=None, award_year=None):
        self.serial_id = serial_id
        self.season_number = season_number
        self.episode_number = episode_number
        self.award_year = award_year
        self.award_title = award_title
        self.role_title = role_title
        self.actor_name = actor_name


metadata = MetaData()

# Create mappings
SerialsMapping = Table('serial', metadata,
                       Column('serial_id', Integer, primary_key=True),
                       Column('title', String(100), nullable=False),
                       Column('release_year', Integer, nullable=False),
                       Column('country', String(50), nullable=False)
                       )
AwardsMapping = Table('serial_has_award', metadata,
                      Column('serial_id', Integer),
                      Column('award_title', String(100), nullable=False),
                      Column('year', Integer, nullable=False),
                      # PrimaryKeyConstraint(['serial_id', 'award_title']),
                      ForeignKeyConstraint(['serial_id'], ['serial.serial_id'], ondelete='CASCADE', onupdate='CASCADE'),
                      ForeignKeyConstraint(['award_title'], ['serial_award.award_title'], ondelete='CASCADE',
                                           onupdate='CASCADE')
                      )
SeasonsMapping = Table('season', metadata,
                       Column('season_number', Integer, nullable=False),
                       Column('serial_id', Integer, primary_key=True),
                       ForeignKeyConstraint(['serial_id'], ['serial.serial_id'], ondelete='CASCADE', onupdate='CASCADE')
                       )
EpisodesMapping = Table('episode', metadata,
                        Column('title', String(20), nullable=False),
                        Column('release_date', Date, nullable=False),
                        Column('duration', Integer, nullable=False),
                        Column('rating', Integer,
                               CheckConstraint('rating > 0 AND rating < 11', name='Positive rating')),
                        Column('episode_number', Integer, primary_key=True),
                        Column('season_number', Integer, primary_key=True),
                        Column('serial_id', Integer, primary_key=True),

                        ForeignKeyConstraint(['season_number', 'serial_id'],
                                             ['season.season_number', 'season.serial_id'],
                                             ondelete='CASCADE', onupdate='CASCADE')
                        )

# Map classes to mappings
mapper(Serial, SerialsMapping)
mapper(Season, SeasonsMapping)
mapper(Episode, EpisodesMapping)
