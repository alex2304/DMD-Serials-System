from sqlalchemy import text
from typing import List

from app import db
from app.main.models import SerialsMapping, Serials
from app.utils.QueryHelper import QueryHelper


class SerialsRepository:
    """
    Repository class for working with serials
    """

    @staticmethod
    def get_all_serials() -> List[Serials]:
        """
        :return: all serials from table Serials
        """
        serials_columns_string = QueryHelper.get_columns_string(SerialsMapping, "serials")

        statement = text("SELECT {serials_columns} FROM {serials_table}".format(serials_table=SerialsMapping.description,
                                                                                serials_columns=serials_columns_string))
        all_serials = db.session.query(Serials).from_statement(statement).all()

        return all_serials
