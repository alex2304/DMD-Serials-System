DROP FUNCTION get_season_date(INTEGER, INTEGER);
drop FUNCTION get_rating_of(INTEGER);
drop FUNCTION get_rating_of(INTEGER, INTEGER);
drop FUNCTION get_genres_of_serial_titles(INTEGER);
drop FUNCTION get_actors_names_of(INTEGER);
drop FUNCTION get_actors_names_of(INTEGER, INTEGER);
DROP FUNCTION get_filtered_serials(CHAR, integer, integer, NUMERIC,NUMERIC, CHAR[],CHAR[],CHAR[], INTEGER, INTEGER);
DROP FUNCTION get_seasons_of_serial(INTEGER);
DROP FUNCTION get_serial_awards(INTEGER);
DROP FUNCTION get_creators_of_serial_names(INTEGER);
DROP FUNCTION get_duration_of(INTEGER, INTEGER);
DROP FUNCTION get_duration_of(INTEGER);
DROP FUNCTION get_episode_directors_names(INTEGER, INTEGER, INTEGER);
DROP FUNCTION get_episode_writers_names(INTEGER, INTEGER, INTEGER);
DROP FUNCTION get_episode_played(INTEGER, INTEGER, INTEGER);
DROP FUNCTION get_serial_played(INTEGER);
DROP FUNCTION get_serials_in_genres_counts();

CREATE OR REPLACE FUNCTION get_season_date(_serial_id INTEGER, _season_number INTEGER)
  RETURNS DATE AS
  $BODY$
    SELECT MIN(e.release_date) FROM
      episode e INNER JOIN season s ON s.serial_id = e.serial_id AND s.season_number = e.season_number
    WHERE e.season_number = _season_number AND e.serial_id = _serial_id;
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_seasons_of_serial(_serial_id INTEGER)
  RETURNS TABLE(season_number INTEGER, serial_id INTEGER, release_date DATE) AS
  $BODY$
    SELECT s.season_number, _serial_id, get_season_date(_serial_id, s.season_number) release_date FROM
      episode e INNER JOIN season s ON s.serial_id = e.serial_id AND s.season_number = e.season_number
    WHERE e.serial_id = _serial_id
    GROUP BY s.season_number;
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_rating_of(_serial_id INTEGER) RETURNS
  NUMERIC AS
  $BODY$
    SELECT AVG(e.rating) FROM episode e INNER JOIN serial s
        ON e.serial_id = s.serial_id AND s.serial_id = _serial_id;
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_rating_of(_serial_id INTEGER, _season_number INTEGER) RETURNS
  NUMERIC AS
  $BODY$
    SELECT AVG(e.rating) FROM episode e INNER JOIN season s
        ON e.serial_id = s.serial_id AND s.serial_id = _serial_id
        AND e.season_number = s.season_number AND s.season_number = _season_number;
  $BODY$
  LANGUAGE sql;


CREATE OR REPLACE FUNCTION get_genres_of_serial_titles(_serial_id INTEGER) RETURNS
  TABLE(genre_title CHAR) AS
  $BODY$
    SELECT g.genre_title FROM serial_has_genre g WHERE g.serial_id = _serial_id;
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_actors_names_of(_serial_id INTEGER) RETURNS
  TABLE(actor_name CHAR) AS
  $BODY$
    SELECT ps.name actor_name FROM
      serial s INNER JOIN films f ON s.serial_id = f.serial_id
      INNER JOIN plays p ON p.played_id = f.played_id
      INNER JOIN person ps ON p.actor_id = ps.person_id
    WHERE s.serial_id = _serial_id
    GROUP BY ps.name;
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_actors_names_of(_serial_id INTEGER, _season_number INTEGER) RETURNS
  TABLE(actor_name CHAR) AS
  $BODY$
    SELECT ps.name actor_name FROM
      season se INNER JOIN serial s  ON s.serial_id = se.serial_id
      INNER JOIN films f ON s.serial_id = f.serial_id
      INNER JOIN plays p ON p.played_id = f.played_id
      INNER JOIN person ps ON p.actor_id = ps.person_id
    WHERE se.serial_id = _serial_id AND se.season_number = _season_number
    GROUP BY ps.name;
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_duration_of(_serial_id INTEGER) RETURNS
 BIGINT AS
 $BODY$
    SELECT sum(e.duration)
    FROM season s NATURAL JOIN episode e
    WHERE s.serial_id = $1;
 $BODY$
 LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_filtered_serials(title_part CHAR, start_year INTEGER, end_year INTEGER,
  start_rating NUMERIC, end_rating NUMERIC, countries CHAR[], actors CHAR[], genres CHAR[], start_duration INTEGER, end_duration INTEGER) RETURNS
  TABLE(serial_id INTEGER, title CHAR, release_year INTEGER, country CHAR) AS
  $BODY$
    SELECT s.serial_id, s.title, s.release_year, s.country FROM serial s
    WHERE lower(s.title) LIKE ('%' || lower(title_part) || '%')                   -- title matching
    AND s.release_year <@ INT4RANGE(start_year, end_year + 1)                     -- year matching
    AND get_rating_of(s.serial_id) <@ NUMRANGE(start_rating, end_rating + 1) -- rating matching
    AND (countries IS NULL or ARRAY[s.country] && countries)                             -- countries matching
    AND (actors is NULL or EXISTS(
        SELECT actor_name FROM get_actors_of_serial_names(s.serial_id) act
        WHERE act.actor_name = ANY(actors)))
    AND (genres is NULL or EXISTS(
        SELECT genre_title FROM get_genres_of_serial_titles(s.serial_id) genr
        WHERE genr.genre_title = ANY(genres)))
    AND (start_duration is NULL or get_duration_of(s.serial_id) > start_duration)
    AND (end_duration is NULL or get_duration_of(s.serial_id) < end_duration);
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_serial_awards(_serial_id INTEGER)
 RETURNS TABLE(award_title CHAR, award_year INTEGER) AS
 $BODY$
    SELECT sha.award_title, sha.year
    FROM serial s NATURAL JOIN serial_has_award sha
    WHERE s.serial_id = $1;
 $BODY$
 LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_creators_of_serial_names(_serial_id INTEGER)
 RETURNS TABLE(creator_name CHAR) AS
 $BODY$
    SELECT p.name
    FROM serial s NATURAL JOIN creates NATURAL JOIN creator c JOIN person p ON c.creator_id = p.person_id
    WHERE s.serial_id = $1;
 $BODY$
 LANGUAGE sql;


CREATE OR REPLACE FUNCTION get_duration_of(_serial_id INTEGER, _season_number INTEGER) RETURNS
 BIGINT AS
 $BODY$
    SELECT sum(e.duration)
    FROM season s NATURAL JOIN episode e
    WHERE s.serial_id = $1 AND s.season_number = $2;
 $BODY$
 LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_episode_directors_names(_serial_id INTEGER, _season_number INTEGER, _episode_number INTEGER) RETURNS
 TABLE(director_name CHAR) AS
 $BODY$
    SELECT p.name
    FROM episode e NATURAL JOIN directs NATURAL JOIN director d JOIN person p ON p.person_id = d.director_id
    WHERE e.serial_id = $1 AND e.season_number = $2 AND e.episode_number = $3;
 $BODY$
 LANGUAGE sql;


CREATE OR REPLACE FUNCTION get_episode_writers_names(_serial_id INTEGER, _season_number INTEGER, _episode_number INTEGER) RETURNS
 TABLE(writer_name CHAR) AS
 $BODY$
    SELECT p.name
    FROM episode e NATURAL JOIN writes NATURAL JOIN writer w JOIN person p ON p.person_id = w.writer_id
    WHERE e.serial_id = $1 AND e.season_number = $2 AND e.episode_number = $3;
 $BODY$
 LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_episode_played(_serial_id INTEGER, _season_number INTEGER, _episode_number INTEGER) RETURNS
 TABLE(actor_name CHAR, role_title CHAR, award_title CHAR, award_year INTEGER) AS
 $BODY$
   SELECT temp.actor_name, temp.role_title, rha.award_title, rha.year
   FROM episode e NATURAL JOIN films NATURAL JOIN plays
     NATURAL JOIN (SELECT r.title role_title, p.name actor_name, pl.played_id played_id
                   FROM plays pl NATURAL JOIN role r NATURAL JOIN actor a JOIN person p ON a.actor_id = p.person_id) temp
     LEFT JOIN role_has_award rha ON temp.played_id = rha.played_id
                                     AND rha.serial_id = $1 AND rha.season_number = $2 AND rha.episode_number = $3
   WHERE e.serial_id = $1 AND e.season_number = $2 AND e.episode_number = $3;
 $BODY$
 LANGUAGE sql;

--All played roles with awards (if awards exist) for the serial with _serial_id
CREATE OR REPLACE FUNCTION get_serial_played(_serial_id INTEGER) RETURNS
TABLE(actor_name CHAR, role_title CHAR, award_title CHAR, award_year INTEGER) AS
  $BODY$
    SELECT temp.actor_name, temp.role_title, rha.award_title, rha.year
   FROM episode e NATURAL JOIN films NATURAL JOIN plays
     NATURAL JOIN (SELECT r.title role_title, p.name actor_name, pl.played_id played_id
                   FROM plays pl NATURAL JOIN role r NATURAL JOIN actor a JOIN person p ON a.actor_id = p.person_id) temp
     LEFT JOIN role_has_award rha ON temp.played_id = rha.played_id
                                     AND rha.serial_id = $1
   WHERE e.serial_id = $1
    GROUP BY temp.actor_name, temp.role_title, rha.award_title, rha.year
    ORDER BY temp.actor_name, rha.year, rha.award_title;
  $BODY$
LANGUAGE sql;

-- Count of serials in each genre
CREATE OR REPLACE FUNCTION get_serials_in_genres_counts() RETURNS
TABLE(genre_title CHAR,  serials_count BIGINT) AS
  $BODY$
    SELECT g.genre_title, COUNT(*)
    FROM genre g NATURAL JOIN serial_has_genre shg
    GROUP BY g.genre_title;
  $BODY$
LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_comments_of(_serial_id INTEGER, _season_number INTEGER) RETURNS
TABLE(comment_text CHAR, comment_date DATE, user_login CHAR) AS
$BODY$
  SELECT c.text, c.comment_date, c.app_user_login
  FROM comments c
  WHERE c.serial_id = $1 AND c.season_number = $2;
$BODY$
LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_reviews_of(_serial_id INTEGER) RETURNS
TABLE(title CHAR, review_text CHAR, review_date DATE, user_login CHAR) AS
$BODY$
  SELECT r.title, r.text, r.review_date, r.app_user_login
  FROM reviews r
  WHERE r.serial_id = $1;
$BODY$
LANGUAGE sql;