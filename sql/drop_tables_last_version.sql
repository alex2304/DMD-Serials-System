DROP FUNCTION insert_into_episode(character, date, integer, integer, integer, integer, integer);

DROP FUNCTION insert_into_season(integer, integer);

DROP FUNCTION insert_into_serial(CHARACTER, INTEGER, CHARACTER);

DROP FUNCTION insert_into_person(CHARACTER, DATE, CHARACTER);

DROP FUNCTION insert_into_director(INTEGER);

DROP FUNCTION insert_into_director(CHARACTER, DATE, CHARACTER);

DROP FUNCTION insert_into_creator(INTEGER);

DROP FUNCTION insert_into_creator(CHARACTER, DATE, CHARACTER);

DROP FUNCTION insert_into_writer(INTEGER);

DROP FUNCTION insert_into_writer(CHARACTER, DATE, CHARACTER);

DROP FUNCTION insert_into_actor(INTEGER);

DROP FUNCTION insert_into_actor(CHARACTER, DATE, CHARACTER);

DROP FUNCTION insert_into_actor_award(CHARACTER);

DROP FUNCTION insert_into_app_user(CHARACTER, INTEGER, CHARACTER);

DROP FUNCTION insert_into_comments(DATE, CHARACTER, CHARACTER, INTEGER, INTEGER);

DROP FUNCTION insert_into_creates(INTEGER, INTEGER);

DROP FUNCTION insert_into_directs(INTEGER, INTEGER, INTEGER, INTEGER);

DROP FUNCTION insert_into_films(INTEGER, INTEGER, INTEGER,INTEGER);

DROP FUNCTION insert_into_genre(CHARACTER);

DROP FUNCTION insert_into_plays(INTEGER, INTEGER);

DROP FUNCTION insert_into_reviews(CHARACTER, INTEGER, CHARACTER, CHARACTER, DATE);

DROP FUNCTION insert_into_role(CHARACTER);

DROP FUNCTION insert_into_role_has_award(INTEGER, CHARACTER, INTEGER,INTEGER, INTEGER, INTEGER);

DROP FUNCTION insert_into_serial_award(CHARACTER);

DROP FUNCTION insert_into_serial_has_award(INTEGER, CHARACTER, INTEGER);

DROP FUNCTION insert_into_serial_has_genre(INTEGER, CHARACTER);

DROP FUNCTION insert_into_subscribes(CHARACTER, INTEGER);

DROP FUNCTION insert_into_writes(INTEGER, INTEGER, INTEGER, INTEGER);

DROP TABLE serial CASCADE;

DROP TABLE genre CASCADE;

DROP TABLE serial_has_genre CASCADE;

DROP TABLE app_user CASCADE;

DROP TABLE subscribes CASCADE;

DROP TABLE reviews CASCADE;

DROP TABLE season CASCADE;

DROP TABLE comments CASCADE;

DROP TABLE episode CASCADE;

DROP TABLE person CASCADE;

DROP TABLE director CASCADE;

DROP TABLE writer CASCADE;

DROP TABLE creator CASCADE;

DROP TABLE actor CASCADE;

DROP TABLE role CASCADE;

DROP TABLE plays CASCADE;

DROP TABLE films CASCADE;

DROP TABLE creates CASCADE;

DROP TABLE directs CASCADE;

DROP TABLE writes CASCADE;

DROP TABLE actor_award CASCADE;

DROP TABLE serial_award CASCADE;

DROP TABLE role_has_award CASCADE;

DROP TABLE serial_has_award CASCADE;
