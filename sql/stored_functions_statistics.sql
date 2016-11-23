DROP FUNCTION count_serials_by_genre();
DROP FUNCTION get_avg_episode_duration_for_serial();
DROP FUNCTION get_ranked_serials_with_no_less_5_seasons_where_no_more_10_episodes_have_rating_less_5();
DROP FUNCTION get_top_5_serials_in_each_genre();
DROP FUNCTION get_list_of_episodes_where_each_actor_played_and_role();
DROP FUNCTION get_top10_rated_episodes_for_the_actor(CHARACTER);
DROP FUNCTION get_roles_of_all_people_in_each_episode();
DROP FUNCTION get_roles_of_all_people_for_the_one_episode(CHAR, INTEGER, CHAR);
DROP FUNCTION get_top5_serials_with_longest_average_episode();
DROP FUNCTION get_top5_serials_in_genre(CHAR);
DROP FUNCTION get_actor_roles(CHAR);
DROP FUNCTION get_shortest_serials_in_genres(CHAR[]);
DROP FUNCTION get_top5_creators();

CREATE OR REPLACE FUNCTION count_serials_by_genre() RETURNS TABLE (genre CHARACTER, number_of_serials BIGINT) AS $$
  BEGIN
    RETURN QUERY SELECT g.genre_title, COUNT(*)
                 FROM genre g NATURAL JOIN serial_has_genre shg
                 GROUP BY g.genre_title;
  END
$$ LANGUAGE plpgsql;

--average episode duration for serial
CREATE OR REPLACE FUNCTION get_avg_episode_duration_for_serial() RETURNS TABLE (genre CHARACTER, avg_episode_duration NUMERIC) AS $$
  BEGIN
    RETURN QUERY SELECT s.title, AVG(e.duration) AS episode_duration
                 FROM serial s JOIN episode e ON e.serial_id = s.serial_id
                 GROUP BY s.title
                 ORDER BY episode_duration DESC;
  END
$$ LANGUAGE plpgsql;

--rank serial with no less than 5 seasons (in each no more than 10 episodes with rating < 5) grouped by genre
-- ???so that each serial in a group has an unique creator
CREATE OR REPLACE FUNCTION get_ranked_serials_with_no_less_5_seasons_where_no_more_10_episodes_have_rating_less_5()
  RETURNS TABLE (serial_title CHARACTER, genre CHARACTER) AS $$
  BEGIN
    RETURN QUERY SELECT s.title, g.genre_title
                 FROM serial s NATURAL JOIN (SELECT se.serial_id
                                            FROM season se
                                            WHERE se.serial_id NOT IN (SELECT ep1.serial_id
                                                                        FROM episode ep1
                                                                        WHERE ep1.rating < 5
                                                                        GROUP BY ep1.serial_id
                                                                        HAVING count(*) >= 10)
                                            GROUP BY se.serial_id
                                            HAVING count(*) >= 5) temp
                NATURAL JOIN serial_has_genre sg NATURAL JOIN genre g NATURAL JOIN creates NATURAL JOIN creator NATURAL JOIN person p
                GROUP BY g.genre_title, s.title
                ORDER BY g.genre_title, s.title;
  END
$$ LANGUAGE plpgsql;

--Find top 5 serials in each genre
CREATE OR REPLACE FUNCTION get_top_5_serials_in_each_genre() RETURNS TABLE (serial_id CHARACTER, genre CHARACTER, rating NUMERIC) AS $$
  BEGIN
    CREATE OR REPLACE VIEW ordered_avg_serial_rating AS
      SELECT ep.serial_id, avg(ep.rating) serial_rating
      FROM episode ep
      GROUP BY ep.serial_id
      ORDER BY serial_rating DESC;

    RETURN QUERY SELECT ser.title, gen.genre_title, oasr.serial_rating
                FROM serial ser
                NATURAL JOIN serial_has_genre NATURAL JOIN genre gen NATURAL JOIN ordered_avg_serial_rating oasr
                WHERE ser.serial_id IN (SELECT s1.serial_id
                                        FROM serial s1 NATURAL JOIN ordered_avg_serial_rating
                                          NATURAL JOIN serial_has_genre shg
                                        WHERE gen.genre_title = shg.genre_title
                                        LIMIT 5)
                GROUP BY gen.genre_title, ser.title, oasr.serial_rating
                ORDER BY gen.genre_title, oasr.serial_rating DESC, ser.title;
    DROP VIEW ordered_avg_serial_rating;
  END
$$ LANGUAGE plpgsql;

--list of episodes at serial where every actor played and role
CREATE OR REPLACE FUNCTION get_list_of_episodes_where_each_actor_played_and_role()
  RETURNS TABLE (actor_name CHARACTER, role_name CHARACTER, episode_number INTEGER, episode_title CHARACTER, season_number INTEGER, serial_title CHARACTER) AS $$
  BEGIN
    RETURN QUERY SELECT p.name, r.title role_name, e.episode_number, e.title episode_title, e.season_number, s.title serial_title
                 FROM episode e NATURAL JOIN films NATURAL JOIN plays pl JOIN role r ON r.role_id = pl.role_id
                   NATURAL JOIN actor a JOIN person p ON a.actor_id = p.person_id JOIN serial s ON e.serial_id = s.serial_id
GROUP BY s.title, e.season_number, e.episode_number, e.title, r.title, p.name
ORDER BY s.title, e.title, p.name;
  END
$$ LANGUAGE plpgsql;

--list of best rated episodes of the serial where actor filmed (top 10)
CREATE OR REPLACE FUNCTION get_top10_rated_episodes_for_the_actor(name CHARACTER)
  RETURNS TABLE (role_name CHARACTER, episode_title CHARACTER, serial_title CHARACTER, rating INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT r.title role_name, e.title episode_title, s.title serial_title, e.rating
                 FROM episode e NATURAL JOIN films NATURAL JOIN plays pl JOIN role r ON r.role_id = pl.role_id
                   NATURAL JOIN actor a JOIN person p ON a.actor_id = p.person_id JOIN serial s ON e.serial_id = s.serial_id
                 WHERE p.name = $1
GROUP BY s.title, e.title, r.title, e.rating
ORDER BY e.rating DESC, s.title, e.title
LIMIT 10;
END
$$ LANGUAGE plpgsql;

--all people with roles of an episode: actors, directors, writers
CREATE OR REPLACE FUNCTION get_roles_of_all_people_in_each_episode()
  RETURNS TABLE (serial_title CHARACTER, season_number INTEGER, episode_title CHARACTER, person_name CHARACTER, role TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT ser.title, ep.season_number, ep.title, p.name, 'director' role_in_serial
  FROM person p JOIN director d ON p.person_id = d.director_id NATURAL JOIN Directs NATURAL JOIN episode ep JOIN serial ser ON ep.serial_id = ser.serial_id
  UNION
  SELECT ser.title, ep.season_number, ep.title, p.name, 'writer' role_in_serial
  FROM person p JOIN writer w ON p.person_id = w.writer_id NATURAL JOIN Writes NATURAL JOIN episode ep JOIN serial ser ON ep.serial_id = ser.serial_id
  UNION
  SELECT ser.title, ep.season_number, ep.title, p.name, 'actor' role_in_serial
  FROM person p JOIN actor a ON p.person_id = a.actor_id NATURAL JOIN plays NATURAL JOIN films NATURAL JOIN episode ep JOIN serial ser ON ep.serial_id = ser.serial_id
--default order??
ORDER BY 1, 2, 3, 4;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_roles_of_all_people_for_the_one_episode(_serial_title CHARACTER, _season_number INTEGER, _episode_title CHARACTER)
  RETURNS TABLE (serial_title CHARACTER, season_number INTEGER, episode_title CHARACTER, person_name CHARACTER, role TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT ser.title, ep.season_number, ep.title, p.name, 'director' role_in_serial
  FROM person p JOIN director d ON p.person_id = d.director_id NATURAL JOIN Directs NATURAL JOIN episode ep JOIN serial ser ON ep.serial_id = ser.serial_id
  WHERE ser.title = $1 AND ep.season_number = $2 AND ep.title = $3
  UNION
  SELECT ser.title, ep.season_number, ep.title, p.name, 'writer' role_in_serial
  FROM person p JOIN writer w ON p.person_id = w.writer_id NATURAL JOIN Writes NATURAL JOIN episode ep JOIN serial ser ON ep.serial_id = ser.serial_id
  WHERE ser.title = $1 AND ep.season_number = $2 AND ep.title = $3
  UNION
  SELECT ser.title, ep.season_number, ep.title, p.name, 'actor' role_in_serial
  FROM person p JOIN actor a ON p.person_id = a.actor_id NATURAL JOIN plays NATURAL JOIN films NATURAL JOIN episode ep JOIN serial ser ON ep.serial_id = ser.serial_id
  WHERE ser.title = $1 AND ep.season_number = $2 AND ep.title = $3
  --default order??
ORDER BY 1, 2, 3, 4;
END
$$ LANGUAGE plpgsql;

-- top5 serials which have the longest average episode duration
CREATE OR REPLACE FUNCTION get_top5_serials_with_longest_average_episode() RETURNS
TABLE(serial_title CHAR, average_episode_length BIGINT) AS
$BODY$
  SELECT s.title, sum(e.duration) / count(*) avg_duration
  FROM serial s JOIN episode e USING (serial_id)
  GROUP BY s.title
  ORDER BY avg_duration DESC
  LIMIT 5;
$BODY$
LANGUAGE sql;

-- top5 serials in the given genre which have maximal rating
CREATE OR REPLACE FUNCTION get_top5_serials_in_genre(_genre_title CHAR) RETURNS
TABLE(serial_title CHAR, serial_rating NUMERIC) AS
$BODY$
      SELECT s.title, avg(ep.rating) serial_rating
      FROM episode ep JOIN serial_has_genre shg USING (serial_id) JOIN serial s USING (serial_id)
      WHERE shg.genre_title = $1
      GROUP BY s.title
      ORDER BY serial_rating DESC
      LIMIT 5;
$BODY$
LANGUAGE sql;

-- all roles of the given actor
CREATE OR REPLACE FUNCTION get_actor_roles(_actor_name CHAR) RETURNS
TABLE(serial_title CHAR, episode_title CHAR, role_name CHAR) AS
$BODY$
  SELECT s.title serial_title, e.title episode_title, r.title role_name
                 FROM episode e NATURAL JOIN films NATURAL JOIN plays pl JOIN role r ON r.role_id = pl.role_id
                   NATURAL JOIN actor a JOIN person p ON a.actor_id = p.person_id JOIN serial s ON e.serial_id = s.serial_id
                 WHERE p.name = $1
GROUP BY s.title, e.season_number, e.title, r.title
ORDER BY s.title, e.title;
$BODY$
LANGUAGE sql;

-- top shortest serials which correspond to at least one of the given genres
CREATE OR REPLACE FUNCTION get_shortest_serials_in_genres(_genres_titles CHAR[]) RETURNS
TABLE(serial_title CHAR, serial_duration BIGINT) AS
$BODY$
  SELECT s.title, sum(e.duration) serial_duration
  FROM episode e JOIN serial s USING (serial_id) NATURAL JOIN serial_has_genre shg
  WHERE shg.genre_title = ANY ($1)
  GROUP BY s.title
  ORDER BY serial_duration
  LIMIT 5;
$BODY$
LANGUAGE sql;

-- top5 creators sorted by rating of their serials
CREATE OR REPLACE FUNCTION get_top5_creators() RETURNS
TABLE(creator_name CHAR, average_serials_rating NUMERIC) AS
$BODY$
  SELECT p.name, avg(avg_serial_rating.serial_rating) creator_rating
  FROM (SELECT ep.serial_id, avg(ep.rating) serial_rating
      FROM episode ep
      GROUP BY ep.serial_id) avg_serial_rating NATURAL JOIN creates NATURAL JOIN creator c JOIN person p ON c.creator_id = p.person_id
  GROUP BY p.name
  ORDER BY creator_rating DESC
  LIMIT 5;
$BODY$
LANGUAGE sql;
