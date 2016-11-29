DROP FUNCTION IF EXISTS count_serials_by_genre();
DROP FUNCTION IF EXISTS get_avg_episode_duration_for_serial();
DROP FUNCTION IF EXISTS get_top_5_serials_in_each_genre();
DROP FUNCTION IF EXISTS get_list_of_episodes_where_each_actor_played_and_role();
DROP FUNCTION IF EXISTS get_top10_rated_episodes_for_the_actor(CHARACTER);
DROP FUNCTION IF EXISTS get_roles_of_all_people_in_each_episode();
DROP FUNCTION IF EXISTS get_roles_of_all_people_for_the_one_episode(CHAR, INTEGER, CHAR);
DROP FUNCTION IF EXISTS get_top5_serials_with_longest_average_episode();
DROP FUNCTION IF EXISTS get_top5_serials_in_genre(CHAR);
DROP FUNCTION IF EXISTS get_actor_roles(CHAR);
DROP FUNCTION IF EXISTS get_shortest_serials_in_genres(CHAR[]);
DROP FUNCTION IF EXISTS get_top5_creators();

CREATE OR REPLACE FUNCTION count_serials_by_genre() RETURNS TABLE (genre CHARACTER, number_of_serials BIGINT) AS $$
  BEGIN
    RETURN QUERY SELECT g.genre_title, COUNT(*)
                  FROM genre g NATURAL JOIN serial_has_genre shg
                  GROUP BY g.genre_title;
  END
$$ LANGUAGE plpgsql;

--average episode duration for serial
--------------------------------------------------------------------------------serial_title----------------------------------------
CREATE OR REPLACE FUNCTION get_avg_episode_duration_for_serial() RETURNS TABLE (genre CHARACTER, avg_episode_duration NUMERIC) AS $$
  BEGIN
    RETURN QUERY SELECT *
                 FROM avg_episode_duration_for_serial;
  END
$$ LANGUAGE plpgsql;

--list of episodes at serial where every actor played and role
CREATE OR REPLACE FUNCTION get_list_of_episodes_where_each_actor_played_and_role()
  RETURNS TABLE (actor_name CHARACTER, role_name CHARACTER, episode_number INTEGER, episode_title CHARACTER, season_number INTEGER, serial_title CHARACTER) AS $$
  BEGIN
    RETURN QUERY SELECT l.actor_name, l.role_name, l.episode_number, l.episode_title, l.season_number, l.serial_title
    FROM list_of_episodes_where_each_actor_played_and_role l;
  END
$$ LANGUAGE plpgsql;

--list of best rated episodes of the serial where actor filmed (top 10)
CREATE OR REPLACE FUNCTION get_top10_rated_episodes_for_the_actor(name CHARACTER)
  RETURNS TABLE (role_name CHARACTER, episode_title CHARACTER, serial_title CHARACTER, rating INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT top.role_name, top.episode_title, top.serial_title, top.rating
               FROM list_of_episodes_where_each_actor_played_and_role top
               WHERE lower(top.actor_name) LIKE lower($1 || '%')
               ORDER BY top.rating DESC
               LIMIT 10;
END
$$ LANGUAGE plpgsql;

--all people with roles of an episode: actors, directors, writers
CREATE OR REPLACE FUNCTION get_roles_of_all_people_in_each_episode()
  RETURNS TABLE (serial_title CHARACTER, season_number INTEGER, episode_title CHARACTER, person_name CHARACTER, role TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM roles_of_all_people_in_each_episode;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_roles_of_all_people_for_the_one_episode(_serial_title CHARACTER, _season_number INTEGER, _episode_title CHARACTER)
  RETURNS TABLE (serial_title CHARACTER, season_number INTEGER, episode_title CHARACTER, person_name CHARACTER, role TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM roles_of_all_people_in_each_episode r
  WHERE r.serial_title = $1 AND r.season_number = $2 AND r.episode_title = $3;
END
$$ LANGUAGE plpgsql;

-- top5 serials which have the longest average episode duration
CREATE OR REPLACE FUNCTION get_top5_serials_with_longest_average_episode() RETURNS
TABLE(serial_title CHAR, average_episode_length NUMERIC) AS
$BODY$
  SELECT *
  FROM avg_episode_duration_for_serial avg
  ORDER BY avg.episode_duration DESC
  LIMIT 5;
$BODY$
LANGUAGE sql;

-- top5 serials in the given genre which have maximal rating
CREATE OR REPLACE FUNCTION get_top5_serials_in_genre(_genre_title CHAR) RETURNS
TABLE(serial_title CHAR, serial_rating NUMERIC) AS
$BODY$
      SELECT s.title, s.rating
      FROM  serial s NATURAL JOIN serial_has_genre NATURAL JOIN genre g
      WHERE lower(g.genre_title) LIKE (_genre_title || '%')
      ORDER BY s.rating DESC
      LIMIT 5;
$BODY$
LANGUAGE sql;

-- all roles of the given actor
CREATE OR REPLACE FUNCTION get_actor_roles(_actor_name CHAR) RETURNS
TABLE(serial_title CHAR, episode_title CHAR, role_name CHAR) AS
$BODY$
  SELECT tr.serial_title, tr.episode_title, tr.role_name
  FROM list_of_episodes_where_each_actor_played_and_role tr
  WHERE lower(tr.actor_name) LIKE (lower($1) || '%')
GROUP BY tr.serial_title, tr.season_number, tr.episode_title, tr.role_name
ORDER BY tr.serial_title, tr.episode_title;
$BODY$
LANGUAGE sql;

-- top shortest serials which correspond to at least one of the given genres
CREATE OR REPLACE FUNCTION get_shortest_serials_in_genres(_genres_titles CHAR[]) RETURNS
TABLE(serial_title CHAR, serial_duration BIGINT) AS
$BODY$
  SELECT sd.title, sd.serial_duration
  FROM duration_of_each_serial sd NATURAL JOIN serial_has_genre shg
  WHERE is_string_matches_any(shg.genre_title, _genres_titles)
  GROUP BY sd.title, sd.serial_duration
  ORDER BY serial_duration
  LIMIT 10;
$BODY$
LANGUAGE sql;
-- top5 creators sorted by rating of their serials
CREATE OR REPLACE FUNCTION get_top5_creators() RETURNS
TABLE(creator_name CHAR, average_serials_rating NUMERIC) AS
$BODY$
  SELECT p.name, c.rating
  FROM creator c JOIN person p ON c.creator_id = p.person_id
  ORDER BY c.rating DESC
  LIMIT 5;
$BODY$
LANGUAGE sql;
