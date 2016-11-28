from sqlalchemy import MetaData


class PersonsTypes:
    ACTOR = "actor"
    DIRECTOR = "director"
    WRITER = "writer"


class Person:
    """
        Model represents Person table
    """

    def __init__(self, person_id, name, birthdate, genger):
        self.birthdate = birthdate
        self.genger = genger
        self.name = name
        self.person_id = person_id

    def serialize_json(self):
        return {"person_gender": self.genger,
                "person_birth_date": self.birthdate,
                "person_id": self.person_id,
                "person_name": self.name}


metadata = MetaData()

# # Create mappings
# EpisodesMapping = Table('episode', metadata,
#                         Column('title', String(20), nullable=False),
#                         Column('release_date', Date, nullable=False),
#                         Column('duration', Integer, nullable=False),
#                         Column('rating', Integer,
#                                CheckConstraint('rating > 0 AND rating < 11', name='Positive rating')),
#                         Column('episode_number', Integer, primary_key=True),
#                         Column('season_number', Integer, primary_key=True),
#                         Column('serial_id', Integer, primary_key=True),
#
#                         ForeignKeyConstraint(['season_number', 'serial_id'], ['season.season_number', 'season.serial_id'],
#                                              ondelete='CASCADE', onupdate='CASCADE')
#                         )
#
# # Map classes to mappings
# mapper(Episode, EpisodesMapping)
