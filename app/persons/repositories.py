from app import db_engine
from app.persons.models import Person
from app.persons.models import PersonsTypes as pt
from app.serials.models import Episode
from app.utils.query_executor import QueryExecutor as qe


class PersonsRepository:
    """
    Repository class for working with persons
    """

    @classmethod
    def get_person_by_id(cls, person_id: int, person_type: str) -> Person:
        """
        Retrieve person with person_id and person_type.
        :param person_id: id of the person
        :param person_type: type of the person from PersonsTypes
        :return: single Person instance
        """

        if person_type == pt.ACTOR:
            function_name = "get_actor_by_id"
        elif person_type == pt.DIRECTOR:
            function_name = "get_director_by_id"
        elif person_type == pt.WRITER:
            function_name = "get_writer_by_id"
        else:
            raise ValueError("Error getting person by id: wrong person type '%s'" % person_type)

        query_result = qe.execute_arbitrary(db_engine,
                                              "SELECT *"
                                              " FROM {function_name}({person_id})",
                                              **{'function_name': function_name,
                                                 'person_id': person_id})

        if len(query_result) > 0:
            row = query_result[0]
            return Person(person_id, str(row['person_name']).rstrip(), row['person_birth_date'], row['person_gender'])

        return None

    @classmethod
    def get_filtered_persons(cls, person_name_part: str, person_type: str):
        """
        Retrieve all persons with given type which names partially equals to given person_name_part
        :param person_name_part: part of the person's name
        :param person_type: type of the person from PersonsTypes
        :return: List of Persons serialized to json format
        """
        if person_type == pt.ACTOR:
            function_name = "get_filtered_actors"
        elif person_type == pt.DIRECTOR:
            function_name = "get_filtered_directors"
        elif person_type == pt.WRITER:
            function_name = "get_filtered_writers"
        else:
            raise ValueError("Error getting filtered persons: wrong person type '%s'" % person_type)

        query_result = qe.execute_arbitrary(db_engine,
                                              "SELECT *"
                                              " FROM {function_name}('{person_name_part}')",
                                              **{'function_name': function_name,
                                                 'person_name_part': person_name_part})

        return [Person(str(row['person_id']),
                       str(row['person_name']).rstrip(),
                       row['person_birth_date'],
                       row['person_gender']).serialize_json()
                for row in query_result]

    @classmethod
    def get_top_episodes_of(cls, person_id: int, person_type: str):
        """
        Return list of dict-serialized top rated episodes in which person participated info
        :param person_id: persond id
        :param person_type: type of the person from PersonsTypes
        :return: List of dicts represented episodes info
        """
        if person_type == pt.ACTOR:
            function_name = "get_top5_best_actor_episodes"
        elif person_type == pt.DIRECTOR:
            function_name = "get_top5_best_director_episodes"
        elif person_type == pt.WRITER:
            function_name = "get_top5_best_writer_episodes"
        else:
            raise ValueError("Error getting top episodes of person: wrong person type '%s'" % person_type)

        query_result = qe.execute_arbitrary(db_engine,
                                              "SELECT *"
                                              " FROM {function_name}({person_id})",
                                              **{'function_name': function_name,
                                                 'person_id': person_id})

        return [Episode(str(row['episode_title']).rstrip(),
                        row['release_date'],
                        row['rating'],
                        row['serial_title'],
                        row['episode_number'],
                        row['season_number'],
                        row['serial_id'],)
                for row in query_result]
