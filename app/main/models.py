from sqlalchemy import Column
from sqlalchemy import Date
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

    def __str__(self):
        return "Serial # %s (%s)" % (self.serial_id, self.title)

metadata = MetaData()

# Create mappings
SerialsMapping = Table('serials', metadata,
                       Column('serial_id', Integer, primary_key=True),
                       Column('title', String(100)),
                       Column('release_year', Date),
                       Column('country', String(50))
                       )

# Map classes to mappings
mapper(Serials, SerialsMapping)
