from sqlalchemy import CheckConstraint
from sqlalchemy import Column
from sqlalchemy import Date
from sqlalchemy import ForeignKeyConstraint
from sqlalchemy import Integer
from sqlalchemy import MetaData
from sqlalchemy import String
from sqlalchemy import Table
from sqlalchemy.orm import mapper


class Director:
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

    def __str__(self):
        return "Episode # %s (%s)" % (self.episode_number, self.title)

metadata = MetaData()

# Create mappings
EpisodesMapping = Table('episode', metadata,
                        Column('title', String(20), nullable=False),
                        Column('release_date', Date, nullable=False),
                        Column('duration', Integer, nullable=False),
                        Column('rating', Integer,
                               CheckConstraint('rating > 0 AND rating < 11', name='Positive rating')),
                        Column('episode_number', Integer, primary_key=True),
                        Column('season_number', Integer, primary_key=True),
                        Column('serial_id', Integer, primary_key=True),

                        ForeignKeyConstraint(['season_number', 'serial_id'], ['season.season_number', 'season.serial_id'],
                                             ondelete='CASCADE', onupdate='CASCADE')
                        )

# Map classes to mappings
mapper(Director, EpisodesMapping)
