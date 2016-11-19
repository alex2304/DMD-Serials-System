
drop FUNCTION get_serial_rating(INTEGER);
drop FUNCTION get_genres_of_serial(INTEGER);
drop FUNCTION get_actors_of_serial(INTEGER);
DROP FUNCTION get_filtered_serials(CHAR, integer, integer, NUMERIC,NUMERIC, CHAR[],CHAR[],CHAR[]);

CREATE OR REPLACE FUNCTION get_serial_rating(_serial_id INTEGER) RETURNS
  NUMERIC AS
  $BODY$
    SELECT AVG(e.rating) FROM episode e INNER JOIN serial s
        ON e.serial_id = s.serial_id AND s.serial_id = _serial_id;
  $BODY$
  LANGUAGE sql;


CREATE OR REPLACE FUNCTION get_genres_of_serial(_serial_id INTEGER) RETURNS
  TABLE(genre_title CHAR) AS
  $BODY$
    SELECT g.genre_title FROM serial_has_genre g WHERE g.serial_id = _serial_id;
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_actors_of_serial(_serial_id INTEGER) RETURNS
  TABLE(actor_name CHAR) AS
  $BODY$
    SELECT ps.name actor_name FROM
      serial s INNER JOIN films f ON s.serial_id = f.serial_id
      INNER JOIN plays p ON p.played_id = f.played_id
      INNER JOIN person ps ON p.actor_id = ps.person_id
    WHERE s.serial_id = _serial_id;
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_filtered_serials(title_part CHAR, start_year INTEGER, end_year INTEGER,
  start_rating NUMERIC, end_rating NUMERIC, countries CHAR[], actors CHAR[], genres CHAR[]) RETURNS
  TABLE(serial_id INTEGER, title CHAR, release_year INTEGER, country CHAR) AS
  $BODY$
    SELECT s.serial_id, s.title, s.release_year, s.country FROM serial s
    WHERE lower(s.title) LIKE ('%' || lower(title_part) || '%')                   -- title matching
    AND s.release_year <@ INT4RANGE(start_year, end_year + 1)                     -- year matching
    AND get_serial_rating(s.serial_id) <@ NUMRANGE(start_rating, end_rating + 1) -- rating matching
    AND (countries IS NULL or ARRAY[s.country] && countries)                             -- countries matching
    AND (actors is NULL or EXISTS(
        SELECT actor_name FROM get_actors_of_serial(s.serial_id) act
        WHERE act.actor_name = ANY(actors)))
    AND (genres is NULL or EXISTS(
        SELECT genre_title FROM get_genres_of_serial(s.serial_id) genr
        WHERE genr.genre_title = ANY(genres)));

  $BODY$
  LANGUAGE sql;

