from sqlalchemy import text


class QueryExecutor:
    """

    """

    @classmethod
    def execute(cls, db, query_string: str, *models_list, **query_string_params):
        """
        Executes arbitrary query to the db and return query object with the result
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
