from sqlalchemy import text


class QueryExecutor:
    """

    """

    @classmethod
    def execute_arbitrary(cls, engine, query_string: str, **query_string_params):
        """
        Executes arbitrary query using Engine object.
        Returns list of rows like   [(v1, v2, v3),
                                     (v1, v2, v3),
                                     ....
                                    ]
        :param engine: Engine object
        :param query_string: sql query string
        :param query_string_params: params for query string
        :return:
        """
        if query_string_params:
            query_string = query_string.format(**query_string_params)

        connection = engine.connect()
        try:
            query_result = connection.execute(query_string)
        except:
            print("* ERROR executing query '%s'" % query_string)
            query_result = []

        result_rows = [row for row in query_result]
        connection.close()

        return result_rows

    @classmethod
    def execute_mapped(cls, db, query_string: str, *models_list, **query_string_params):
        """
        Executes query to the db using session.query(), and return query object with the result.
        Result will be mapped to classes in *models_list
        :param db: SQLAlchemy database
        :param query_string: sql statement in string format
        :param models_list: list of the models which participate in the query
        :param query_string_params: arguments to format with query_string
        :return: query object with the result
        """
        if query_string_params:
            query_string = query_string.format(**query_string_params)

        # Building a query
        if models_list:
            result_query = db.session.query(*models_list)
        else:
            result_query = db.session.query()

        # Apply the statement to the query
        result = result_query.from_statement(text(query_string))

        # Trying to return the result
        #try:
        return result.all()
        #except IndexError:
        #    traceback.print_exc()
        #    return []
