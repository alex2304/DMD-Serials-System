--average rating for serial
SELECT serial.title, AVG(episode.rating) AS serial_rating
FROM serial serial NATURAL JOIN episode episode
GROUP BY serial.title
ORDER BY serial_rating DESC;

--average episode duration for serial
-------------------equal to previous!
SELECT serial.title, AVG(episode.duration) AS episode_duration
FROM serial serial NATURAL JOIN episode episode
GROUP BY serial.title
ORDER BY episode_duration DESC;

--rank serial with no less than 5 seasons (in each no more than 10 episodes with rating < 5)
--grouped by genre
-- ???so that each serial in a group has an unique creator
SELECT s.title, g.genre_title
FROM serial s NATURAL JOIN (SELECT se.serial_id
                             FROM season se
                             WHERE se.serial_id NOT IN (SELECT ep1.serial_id
                                                        FROM episode ep1
                                                        WHERE ep1.rating < 5
                                                        GROUP BY ep1.serial_id
                                                        HAVING count(*) >= 10)) temp
NATURAL JOIN serial_has_genre sg NATURAL JOIN genre g NATURAL JOIN creates NATURAL JOIN creator NATURAL JOIN person p
GROUP BY g.genre_title, s.title
ORDER BY g.genre_title, s.title;

--Find top 5 serials in each genre
SELECT ser.title, gen.genre_title
FROM serial ser NATURAL JOIN (SELECT ep.serial_id, avg(ep.rating) serial_rating
                               FROM episode ep
                               GROUP BY ep.serial_id) temp
  NATURAL JOIN serial_has_genre NATURAL JOIN genre gen
GROUP BY gen.genre_title, ser.title, temp.serial_rating
ORDER BY temp.serial_rating DESC, ser.title
LIMIT 5;

--list of episodes at serial where every actor played and role
SELECT p.name actor_name, r.title role_name,  episode.title episode_title, serial.title serial_title
FROM serial serial NATURAL JOIN episode episode
  NATURAL JOIN films NATURAL JOIN plays NATURAL JOIN role r
  NATURAL JOIN actor NATURAL JOIN person p
GROUP BY serial.title, episode.title, p.name, r.title
ORDER BY serial.title, episode.title, p.name;

--list of best rated episodes of the serial where actor occured (top 10)
SELECT p.name actor_name, r.title role_name,  episode.title episode_title,
  serial.title serial_title, episode.rating episode_rating
FROM serial serial NATURAL JOIN season NATURAL JOIN episode episode
  NATURAL JOIN films NATURAL JOIN plays NATURAL JOIN role r
  NATURAL JOIN actor NATURAL JOIN person p
GROUP BY serial.title, episode.title, p.name, r.title, episode.rating
ORDER BY episode.rating DESC, serial.title, episode.title, p.name
LIMIT 10;

--all people with roles of an episode: actors, directors, writers
SELECT ser.title, ep.title, p.name, 'director' role_in_serial
FROM person p NATURAL JOIN director NATURAL JOIN Directs NATURAL JOIN episode ep NATURAL JOIN serial ser
UNION
SELECT ser.title, ep.title, p.name, 'writer' role_in_serial
FROM person p NATURAL JOIN writer NATURAL JOIN Writes NATURAL JOIN episode ep NATURAL JOIN serial ser
UNION
SELECT ser.title, ep.title, p.name, 'actor' role_in_serial
FROM person p NATURAL JOIN actor NATURAL JOIN plays NATURAL JOIN films NATURAL JOIN episode ep NATURAL JOIN serial ser
--default order??
ORDER BY 1, 2, 3;
