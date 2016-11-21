CREATE TABLE serial (
  serial_id SERIAL PRIMARY KEY,
  title CHAR(100) NOT NULL,
  release_year INTEGER NOT NULL,
  country CHAR(50) NOT NULL,

  CONSTRAINT year_must_be_less_or_equal_than_now_and_grater_1948
  CHECK (release_year >= 1949 AND release_year <= extract(YEAR FROM current_date))
);

CREATE TABLE genre (
	genre_title CHAR(50) PRIMARY KEY
);

CREATE TABLE serial_has_genre (
  serial_id INTEGER,
  genre_title CHAR(50),

  FOREIGN KEY (serial_id) REFERENCES serial (serial_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (genre_title) REFERENCES genre (genre_title) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE app_user(
  login CHAR(20) PRIMARY KEY,
  vk_id INTEGER NOT NULL,
  email CHAR(50) NOT NULL,

  CONSTRAINT vk_id_must_be_unique UNIQUE (vk_id),
  CONSTRAINT email_must_be_unique UNIQUE (email)
);

CREATE TABLE subscribes (
  app_user_login CHAR(20),
  serial_id INTEGER,

  PRIMARY KEY (app_user_login, serial_id),
  FOREIGN KEY (serial_id) REFERENCES serial (serial_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (app_user_login) REFERENCES app_user (login) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE reviews (
  app_user_login CHAR(20),
  serial_id INTEGER,
  title CHAR(50),
  text CHAR(10000) NOT NULL,
  review_date DATE NOT NULL ,

  PRIMARY KEY (app_user_login, serial_id),
  FOREIGN KEY (app_user_login) REFERENCES app_user (login) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (serial_id) REFERENCES serial (serial_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE season (
  season_number INTEGER NOT NULL,
  serial_id INTEGER NOT NULL,

  PRIMARY KEY (season_number, serial_id),
  FOREIGN KEY (serial_id) REFERENCES serial(serial_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT season_number_must_be_grater_than_0 CHECK (season_number > 0)
);

CREATE TABLE comments (
  comment_id SERIAL PRIMARY KEY,
  comment_date DATE NOT NULL,
  text CHAR(1000) NOT NULL,
  app_user_login CHAR(20),
  season_number INTEGER,
  serial_id INTEGER,

  FOREIGN KEY (app_user_login) REFERENCES app_user (login) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (season_number, serial_id) REFERENCES season (season_number, serial_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE episode (
  title CHAR(20) NOT NULL,
  release_date DATE NOT NULL,
  duration INTEGER NOT NULL,
  rating INTEGER NOT NULL,
  episode_number INTEGER NOT NULL,
  season_number INTEGER,
  serial_id INTEGER,

  PRIMARY KEY (episode_number, season_number, serial_id),
  FOREIGN KEY (season_number, serial_id) REFERENCES season (season_number, serial_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT positive_rating CHECK (rating > 0 AND rating < 11),
  CONSTRAINT episode_number_must_be_grater_than_0 CHECK (episode_number > 0)
);

CREATE TABLE person (
  person_id SERIAL PRIMARY KEY,
  name CHAR(50) NOT NULL,
  birthdate DATE NOT NULL,
  genger CHAR(1) NOT NULL
);

CREATE TABLE director (
  director_id INTEGER REFERENCES person (person_id) PRIMARY KEY
);

CREATE TABLE writer (
  writer_id INTEGER REFERENCES person (person_id) PRIMARY KEY
);

CREATE TABLE creator (
  creator_id INTEGER REFERENCES person (person_id) PRIMARY KEY
);

CREATE TABLE actor (
  actor_id INTEGER REFERENCES person (person_id) PRIMARY KEY
);

CREATE TABLE role (
  role_id SERIAL PRIMARY KEY,
  title CHAR(50) NOT NULL
);

CREATE TABLE plays (
  played_id SERIAL PRIMARY KEY,
  role_id INTEGER,
  actor_id INTEGER,

  CONSTRAINT pair_role_id_actor_id_must_be_unique UNIQUE (role_id, actor_id),
  FOREIGN KEY (role_id) REFERENCES role (role_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE films (
  played_id INTEGER,
  episode_number INTEGER,
  season_number INTEGER,
  serial_id INTEGER,
  PRIMARY KEY (played_id, episode_number, season_number, serial_id),

  FOREIGN KEY (played_id) REFERENCES plays (played_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (episode_number, season_number, serial_id) REFERENCES
    episode (episode_number, season_number, serial_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE creates (
  creator_id INTEGER,
  serial_id INTEGER,

  PRIMARY KEY (creator_id, serial_id),
  FOREIGN KEY (creator_id) REFERENCES creator (creator_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (serial_id) REFERENCES serial (serial_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE directs (
  director_id INTEGER,
  episode_number INTEGER,
  season_number INTEGER,
  serial_id INTEGER,

  PRIMARY KEY (director_id, episode_number, season_number, serial_id),
  FOREIGN KEY (director_id) REFERENCES director (director_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (episode_number, season_number, serial_id) REFERENCES
    episode (episode_number, season_number, serial_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE writes (
  writer_id INTEGER,
  episode_number INTEGER,
  season_number INTEGER,
  serial_id INTEGER,

  PRIMARY KEY (writer_id, episode_number, season_number, serial_id),
  FOREIGN KEY (writer_id) REFERENCES writer (writer_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (episode_number, season_number, serial_id) REFERENCES
    episode (episode_number, season_number, serial_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE actor_award (
  award_title CHAR(50) PRIMARY KEY
);

CREATE TABLE serial_award (
  award_title CHAR(50) PRIMARY KEY
);

CREATE TABLE role_has_award (
  year INTEGER,
  award_title CHAR(50),
  played_id INTEGER,
  episode_number INTEGER,
  season_number INTEGER,
  serial_id INTEGER,

  PRIMARY KEY (played_id, episode_number, season_number, serial_id, award_title),
  FOREIGN KEY (award_title) REFERENCES actor_award (award_title) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (played_id) REFERENCES plays (played_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (episode_number, season_number, serial_id) REFERENCES
    episode (episode_number, season_number, serial_id) ON DELETE CASCADE ON UPDATE CASCADE,

  CHECK (year >= 1949 AND year <= extract(YEAR FROM current_date))
);

CREATE TABLE serial_has_award (
  year INTEGER,
  award_title CHAR(50),
  serial_id INTEGER,

  PRIMARY KEY (serial_id, award_title),
  FOREIGN KEY (award_title) REFERENCES serial_award (award_title) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (serial_id) REFERENCES serial (serial_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE OR REPLACE FUNCTION insert_into_episode(title CHAR(20), release_date DATE, duration INTEGER,
  rating INTEGER, episode_number INTEGER, season_number INTEGER, serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
    -- check release_year of serial
    IF (extract(YEAR FROM release_date) < (SELECT s.release_year
                           FROM serial s
                           WHERE ($7 = s.serial_id)))
    THEN
      RAISE EXCEPTION 'serial release_date must be smaller than episode release_date';
    END IF;
    -- if the first episode of serial just insert
    IF (episode_number = 1 AND season_number = 1)
      THEN
        INSERT INTO episode VALUES ($1, $2, $3, $4, $5, $6, $7);
    -- if the first episode os season check previous release_date
    ELSEIF (episode_number = 1)
      THEN
        IF (release_date >= (SELECT e.release_date
                          FROM episode e NATURAL JOIN (SELECT max(e1.episode_number) AS max, e1.serial_id, e1.season_number
                                                       FROM episode e1
                                                       GROUP BY e1.serial_id, e1.season_number) temp
                          WHERE e.season_number = $6 - 1 AND e.serial_id = $7 AND e.episode_number = temp.max))
          THEN
            INSERT INTO episode VALUES ($1, $2, $3, $4, $5, $6, $7);
        ELSE
          RAISE EXCEPTION 'release_date must be larger or equal release_date of last episode in previous season';
        END IF;
    -- check previous release_date
    ELSE
      -- if there is no episodes in this season - raise an exception
      IF (NOT EXISTS(SELECT *
                     FROM episode e
                     WHERE e.season_number = 1 AND $7 = e.serial_id))
        THEN
          RAISE EXCEPTION 'there is no first episode';
      END IF;
      -- if there is an episode in the NEXT season - raise an exception
      IF (EXISTS(SELECT *
                 FROM episode e
                 WHERE $6 < e.season_number AND $7 = e.serial_id))
        THEN
          RAISE EXCEPTION 'you can not add this episode in this season because there is the next season';
      END IF;
      -- check whether episodes go one by one
      IF (episode_number - 1 != (SELECT e.episode_number
                          FROM episode e NATURAL JOIN (SELECT max(e1.episode_number) AS max, e1.serial_id, e1.season_number
                                                       FROM episode e1
                                                       GROUP BY e1.serial_id, e1.season_number) temp
                          WHERE e.season_number = $6 AND e.serial_id = $7 AND e.episode_number = temp.max))
        THEN
          RAISE EXCEPTION 'episodes must go one by one';
      END IF;
      IF (release_date >= (SELECT e.release_date
                          FROM episode e NATURAL JOIN (SELECT max(e1.episode_number) AS max, e1.serial_id, e1.season_number
                                                       FROM episode e1
                                                       GROUP BY e1.serial_id, e1.season_number) temp
                          WHERE e.season_number = $6 AND e.serial_id = $7 AND e.episode_number = temp.max))
        THEN
          INSERT INTO episode VALUES ($1, $2, $3, $4, $5, $6, $7);
      ELSE
        RAISE EXCEPTION 'release_date must be larger or equal release_date of last episode in this season';
      END IF;
    END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_season(season_number INTEGER, serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
    IF (season_number = 1)
      THEN
        INSERT INTO season VALUES ($1, $2);

    -- check whether the first exists
    ELSEIF (NOT EXISTS(SELECT *
                       FROM season s
                       WHERE s.season_number = 1 AND $2 = s.serial_id))
      THEN
        RAISE EXCEPTION 'there is no first season';

    -- seasons must go one by one
    ELSEIF (season_number - 1 != (SELECT s.season_number
                                  FROM season s NATURAL JOIN (SELECT max(s1.season_number) AS max, s1.serial_id
                                                              FROM season s1
                                                              GROUP BY s1.serial_id) temp
                                  WHERE s.season_number = max AND $2 = s.serial_id))
      THEN
        RAISE EXCEPTION 'season numbers must go one by one';
    ELSE
      INSERT INTO season VALUES ($1, $2);
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_serial(title CHAR(100), release_year INTEGER,country CHAR(50)) RETURNS VOID AS $$
  BEGIN
    INSERT INTO serial (title, release_year, country) VALUES ($1, $2, $3);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_person(name CHAR(50), birthdate DATE, genger CHAR(1)) RETURNS VOID AS $$
  BEGIN
    INSERT INTO person (name, birthdate, genger) VALUES ($1, $2, $3);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_director(name CHAR(50), birthdate DATE, genger CHAR(1)) RETURNS VOID AS $$
  DECLARE pperson_id INTEGER;
  BEGIN
    pperson_id = (SELECT p.person_id
        FROM person p
        WHERE p.name = $1 AND p.birthdate = $2 AND p.genger = $3);
    IF (pperson_id IS NOT NULL)
      THEN
        INSERT INTO director VALUES (pperson_id);
      ELSE
        INSERT INTO person (name, birthdate, genger) VALUES ($1, $2, $3);
        pperson_id = (SELECT p.person_id
                      FROM person p
                      WHERE p.name = $1 AND p.birthdate = $2 AND p.genger = $3);
        INSERT INTO director VALUES (pperson_id);
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_director(person_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO director VALUES ($1);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_creator(name CHAR(50), birthdate DATE, genger CHAR(1)) RETURNS VOID AS $$
  DECLARE pperson_id INTEGER;
  BEGIN
    pperson_id = (SELECT p.person_id
        FROM person p
        WHERE p.name = $1 AND p.birthdate = $2 AND p.genger = $3);
    IF (pperson_id IS NOT NULL)
      THEN
        INSERT INTO creator VALUES (pperson_id);
      ELSE
        INSERT INTO person (name, birthdate, genger) VALUES ($1, $2, $3);
        pperson_id = (SELECT p.person_id
                      FROM person p
                      WHERE p.name = $1 AND p.birthdate = $2 AND p.genger = $3);
        INSERT INTO creator VALUES (pperson_id);
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_creator(person_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO creator VALUES ($1);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_writer(name CHAR(50), birthdate DATE, genger CHAR(1)) RETURNS VOID AS $$
  DECLARE pperson_id INTEGER;
  BEGIN
    pperson_id = (SELECT p.person_id
        FROM person p
        WHERE p.name = $1 AND p.birthdate = $2 AND p.genger = $3);
    IF (pperson_id IS NOT NULL)
      THEN
        INSERT INTO writer VALUES (pperson_id);
      ELSE
        INSERT INTO person (name, birthdate, genger) VALUES ($1, $2, $3);
        pperson_id = (SELECT p.person_id
                      FROM person p
                      WHERE p.name = $1 AND p.birthdate = $2 AND p.genger = $3);
        INSERT INTO writer VALUES (pperson_id);
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_writer(person_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO writer VALUES ($1);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_actor(name CHAR(50), birthdate DATE, genger CHAR(1)) RETURNS VOID AS $$
  DECLARE pperson_id INTEGER;
  BEGIN
    pperson_id = (SELECT p.person_id
        FROM person p
        WHERE p.name = $1 AND p.birthdate = $2 AND p.genger = $3);
    IF (pperson_id IS NOT NULL)
      THEN
        INSERT INTO actor VALUES (pperson_id);
      ELSE
        INSERT INTO person (name, birthdate, genger) VALUES ($1, $2, $3);
        pperson_id = (SELECT p.person_id
                      FROM person p
                      WHERE p.name = $1 AND p.birthdate = $2 AND p.genger = $3);
        INSERT INTO actor VALUES (pperson_id);
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_actor(person_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO actor VALUES ($1);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_creates(creator_id INTEGER, serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO creates VALUES ($1, $2);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_directs(director_id INTEGER, episode_is INTEGER,
  season_id INTEGER, serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO directs VALUES ($1, $2, $3, $4);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_writes(writer_id INTEGER, episode_is INTEGER,
  season_id INTEGER, serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO writes VALUES ($1, $2, $3, $4);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_genre(genre_title CHAR(50)) RETURNS VOID AS $$
  BEGIN
        INSERT INTO genre VALUES ($1);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_serial_has_genre(serial_id INTEGER, genre_title CHAR(50)) RETURNS VOID AS $$
  BEGIN
        INSERT INTO serial_has_genre VALUES ($1, $2);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_serial_award(award_title CHAR(50)) RETURNS VOID AS $$
  BEGIN
        INSERT INTO serial_award VALUES ($1);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_serial_has_award(year INTEGER, award_title CHAR(50), serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
    IF ($1 < (SELECT s.release_year
                FROM serial s
                WHERE s.serial_id = $3))
      THEN
        RAISE EXCEPTION 'release year must be less than or equal award year ';
      ELSE
        INSERT INTO serial_has_award VALUES ($1, $2, $3);
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_role(title CHAR(50)) RETURNS VOID AS $$
  BEGIN
    IF (exists(SELECT *
               FROM role r
               WHERE r.title = $1))
      THEN
        RETURN;
      ELSE
        INSERT INTO role (title) VALUES ($1);
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_plays(role_id INTEGER, actor_id INTEGER) RETURNS VOID AS $$
  BEGIN
    INSERT INTO plays (role_id, actor_id) VALUES ($1, $2);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_actor_award(award_title CHAR(50)) RETURNS VOID AS $$
  BEGIN
        INSERT INTO actor_award VALUES ($1);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_role_has_award(year INTEGER, award_title CHAR(50), played_id INTEGER,
  episode_number INTEGER, season_number INTEGER, serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
    IF ($1 < extract(YEAR FROM (SELECT e.release_date
                FROM episode e
                WHERE e.episode_number = $4 AND e.season_number = $5 AND e.serial_id = $6)))
      THEN
        RAISE EXCEPTION 'episode release date year must be less than or equal award year';
      ELSE
        INSERT INTO role_has_award VALUES ($1, $2, $3, $4, $5, $6);
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_films(played_id INTEGER, episode_number INTEGER, season_number INTEGER,
  serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO films VALUES ($1, $2, $3, $4);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_app_user(login CHAR(20),vk_id INTEGER, email CHAR(50)) RETURNS VOID AS $$
  BEGIN
        INSERT INTO app_user VALUES ($1, $2, $3);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_subscribes(login CHAR(20), serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO subscribes VALUES ($1, $2);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_comments(comment_date DATE, text CHAR(1000), app_user_login CHAR(20),
  season_number INTEGER, serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO comments (comment_date, text, app_user_login, season_number, serial_id) VALUES ($1, $2, $3, $4, $5);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_reviews(app_user_login CHAR(20), serial_id INTEGER, title CHAR(50),
  text CHAR(10000), review_date DATE) RETURNS VOID AS $$
  BEGIN
    IF (extract(YEAR FROM $5) < (SELECT s.release_year
                FROM serial s
                WHERE s.serial_id = $2))
      THEN
        RAISE EXCEPTION 'review can not be published before serial have been released';
      ELSE
        INSERT INTO reviews VALUES ($1, $2, $3, $4, $5);
      END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_comments(text CHAR(1000), app_user_login CHAR(20),
  season_number INTEGER, serial_id INTEGER) RETURNS VOID AS $$
  BEGIN
        INSERT INTO comments (comment_date, text, app_user_login, season_number, serial_id) VALUES (now(), $1, $2, $3, $4);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_reviews(app_user_login CHAR(20), serial_id INTEGER, title CHAR(50),
  text CHAR(10000)) RETURNS VOID AS $$
  BEGIN
    IF (extract(YEAR FROM $5) < (SELECT s.release_year
                FROM serial s
                WHERE s.serial_id = $2))
      THEN
        RAISE EXCEPTION 'review can not be published before serial have been released';
      ELSE
        INSERT INTO reviews VALUES ($1, $2, $3, $4, now());
      END IF;
  END;
$$ LANGUAGE plpgsql;


--serials
SELECT insert_into_serial('University comedy', 2001, 'Russia');
SELECT insert_into_serial('Campus horror', 2010, 'Russia');
SELECT insert_into_serial('I have a dream', 2011, 'Russia');
SELECT insert_into_serial('Everyday shuttling', 2015, 'Russia');
SELECT insert_into_serial('The Dutch', 2016, 'USA');
--seasons
SELECT insert_into_season(1, 1);
SELECT insert_into_season(2, 1);
SELECT insert_into_season(1, 2);
SELECT insert_into_season(1, 3);
SELECT insert_into_season(1, 4);
SELECT insert_into_season(1, 5);
--episodes
SELECT insert_into_episode('Epic start', '2001-03-02', 24, 7, 1, 1, 1);
SELECT insert_into_episode('Fuel ends', '2001-03-02', 35, 2, 2, 1, 1);
SELECT insert_into_episode('Not a journey!', '2001-03-02', 24, 8, 1, 2, 1);
SELECT insert_into_episode('Do not cry', '2001-03-02', 24, 10, 2, 2, 1);
SELECT insert_into_episode('Rubbish', '2014-04-20', 24, 7, 1, 1, 2);
SELECT insert_into_episode('Best prisoner', '2015-03-02', 24, 3, 2, 1, 2);
SELECT insert_into_episode('Foolish guy', '2013-03-02', 24, 6, 1, 1, 3);
SELECT insert_into_episode('Cave disease', '2015-11-30', 24, 2, 1, 1, 4);
SELECT insert_into_episode('Light in tunnel', '2016-11-02', 24, 9, 1, 1, 5);

--persons
SELECT insert_into_person('Brutus Ullson', '1983-09-09', 'm');
SELECT insert_into_person('Emma fon Schmidt', '1987-07-25', 'f');
SELECT insert_into_person('Dill Duck', '1964-12-31', 'm');
SELECT insert_into_person('Bill Deal', '1978-03-14', 'm');
SELECT insert_into_person('Mary Paris', '1994-02-03', 'f');
--creators
SELECT insert_into_creator(1);
SELECT insert_into_creator(2);
SELECT insert_into_creator(3);
SELECT insert_into_creator(4);
SELECT insert_into_creator(5);
--creates
SELECT insert_into_creates(1, 1);
SELECT insert_into_creates(2, 1);
SELECT insert_into_creates(2, 2);
SELECT insert_into_creates(3, 3);
SELECT insert_into_creates(4, 4);
SELECT insert_into_creates(5, 5);
--persons
SELECT insert_into_person('Jan Jack', '1979-05-13', 'm');
SELECT insert_into_person('Fill Bill', '1945-10-09', 'm');
SELECT insert_into_person('Stella Muck', '1989-02-28', 'f');
SELECT insert_into_person('Bella Kick', '1997-08-22', 'f');
SELECT insert_into_person('John Bon', '1977-07-07', 'm');
--writers
SELECT insert_into_writer(6);
SELECT insert_into_writer(7);
SELECT insert_into_writer(8);
SELECT insert_into_writer(9);
SELECT insert_into_writer(10);
--writes
SELECT insert_into_writes(6, 1, 1, 1);
SELECT insert_into_writes(6, 2, 1, 1);
SELECT insert_into_writes(7, 2, 1, 1);
SELECT insert_into_writes(8, 1, 2, 1);
SELECT insert_into_writes(6, 2, 2, 1);
SELECT insert_into_writes(9, 1, 1, 2);
SELECT insert_into_writes(10, 2, 1, 2);
SELECT insert_into_writes(7, 1, 1, 3);
SELECT insert_into_writes(8, 1, 1, 4);
SELECT insert_into_writes(9, 1, 1, 5);
--directors
SELECT insert_into_director(3);
SELECT insert_into_director(4);
SELECT insert_into_director(5);
SELECT insert_into_director(6);
SELECT insert_into_director(7);
--directs
SELECT insert_into_directs(3, 1, 1, 1);
SELECT insert_into_directs(4, 2, 1, 1);
SELECT insert_into_directs(5, 1, 2, 1);
SELECT insert_into_directs(6, 2, 2, 1);
SELECT insert_into_directs(7, 1, 1, 2);
SELECT insert_into_directs(3, 2, 1, 2);
SELECT insert_into_directs(4, 1, 1, 3);
SELECT insert_into_directs(5, 1, 1, 4);
SELECT insert_into_directs(6, 1, 1, 5);

--persons
SELECT insert_into_person('Rick Pick', '1995-07-20', 'm');
SELECT insert_into_person('Ben Pen', '1982-12-15', 'm');
SELECT insert_into_person('Nil Gill', '1992-10-01', 'm');
SELECT insert_into_person('Sara Para-pa-para', '1998-04-01', 'f');
SELECT insert_into_person('Milla Milk', '1980-10-19', 'f');
SELECT insert_into_person('Kira Witch', '1988-08-08', 'f');
SELECT insert_into_person('Peter Potter', '1990-04-03', 'm');
SELECT insert_into_person('Curt Burt', '1974-05-06', 'm');
SELECT insert_into_person('Daren Paren', '1978-11-28', 'm');
SELECT insert_into_person('Mark Dark', '1963-06-020', 'm');
--actors
SELECT insert_into_actor(1);
SELECT insert_into_actor(2);
SELECT insert_into_actor(3);
SELECT insert_into_actor(8);
SELECT insert_into_actor(9);--5
SELECT insert_into_actor(10);
SELECT insert_into_actor(11);
SELECT insert_into_actor(12);
SELECT insert_into_actor(13);
SELECT insert_into_actor(14);--10
SELECT insert_into_actor(15);
SELECT insert_into_actor(16);
SELECT insert_into_actor(17);
SELECT insert_into_actor(18);
SELECT insert_into_actor(19);--15
SELECT insert_into_actor(20);

--genres
SELECT insert_into_genre('horror');
SELECT insert_into_genre('comedy');
SELECT insert_into_genre('thriller');
SELECT insert_into_genre('romance');
SELECT insert_into_genre('drama');
--serial has genre
SELECT insert_into_serial_has_genre(1, 'horror');
SELECT insert_into_serial_has_genre(1, 'thriller');
SELECT insert_into_serial_has_genre(1, 'drama');
SELECT insert_into_serial_has_genre(2, 'drama');
SELECT insert_into_serial_has_genre(3, 'thriller');
SELECT insert_into_serial_has_genre(3, 'romance');
SELECT insert_into_serial_has_genre(4, 'horror');
SELECT insert_into_serial_has_genre(4, 'comedy');
SELECT insert_into_serial_has_genre(5, 'horror');
SELECT insert_into_serial_has_genre(5, 'drama');

--serial award
SELECT insert_into_serial_award('best horror');
SELECT insert_into_serial_award('best drama');
--serial has award
SELECT insert_into_serial_has_award(2016, 'best horror', 1);
SELECT insert_into_serial_has_award(2015, 'best horror', 2);
SELECT insert_into_serial_has_award(2016, 'best drama', 2);

--roles
SELECT insert_into_role('Tree');
SELECT insert_into_role('Barbara');
SELECT insert_into_role('Bill');
SELECT insert_into_role('Strange person');
SELECT insert_into_role('Chef');--5
SELECT insert_into_role('Cooker');
SELECT insert_into_role('Gungster');
SELECT insert_into_role('Thief');
SELECT insert_into_role('Adam');
SELECT insert_into_role('Tim');--10
SELECT insert_into_role('Alla');
--playes
SELECT insert_into_plays(1, 1);
SELECT insert_into_plays(1, 2);
SELECT insert_into_plays(2, 3);
SELECT insert_into_plays(3, 8);
SELECT insert_into_plays(3, 9);--5
SELECT insert_into_plays(4, 10);
SELECT insert_into_plays(4, 8);
SELECT insert_into_plays(5, 8);
SELECT insert_into_plays(6, 9);
SELECT insert_into_plays(7, 10);--10
SELECT insert_into_plays(8, 11);
SELECT insert_into_plays(9, 12);
SELECT insert_into_plays(9, 13);
SELECT insert_into_plays(10, 14);
SELECT insert_into_plays(11, 15);--15
SELECT insert_into_plays(11, 16);

--actor award
SELECT insert_into_actor_award('best role');
SELECT insert_into_actor_award('worst role');
--role_has_award
SELECT insert_into_role_has_award(2015, 'best role', 1, 1, 1, 1);
SELECT insert_into_role_has_award(2015, 'worst role', 2, 2, 1, 1);
SELECT insert_into_role_has_award(2015, 'best role', 1, 1, 2, 1);
SELECT insert_into_role_has_award(2016, 'worst role', 4, 2, 2, 1);
SELECT insert_into_role_has_award(2016, 'best role', 1, 1, 1, 3);

--films
SELECT insert_into_films(1, 1, 1, 1);
SELECT insert_into_films(2, 1, 1, 1);
SELECT insert_into_films(3, 1, 1, 1);
SELECT insert_into_films(1, 2, 1, 1);
SELECT insert_into_films(2, 2, 1, 1);--5
SELECT insert_into_films(1, 1, 2, 1);
SELECT insert_into_films(4, 2, 2, 1);
SELECT insert_into_films(5, 1, 1, 2);
SELECT insert_into_films(6, 1, 1, 2);
SELECT insert_into_films(5, 2, 1, 2);--10
SELECT insert_into_films(6, 2, 1, 2);
SELECT insert_into_films(7, 2, 1, 2);
SELECT insert_into_films(8, 1, 1, 3);
SELECT insert_into_films(9, 1, 1, 3);
SELECT insert_into_films(10, 1, 1, 3);--15
SELECT insert_into_films(1, 1, 1, 3);
SELECT insert_into_films(11, 1, 1, 4);
SELECT insert_into_films(12, 1, 1, 4);
SELECT insert_into_films(13, 1, 1, 4);
SELECT insert_into_films(14, 1, 1, 4);--20
SELECT insert_into_films(14, 1, 1, 5);
SELECT insert_into_films(1, 1, 1, 5);
SELECT insert_into_films(15, 1, 1, 5);
SELECT insert_into_films(16, 1, 1, 5);--24

--app_users
SELECT insert_into_app_user('paprika', 123456, 'yayaya@mail.ru');
SELECT insert_into_app_user('foreach', 492874, 'foreach@mail.ru');
SELECT insert_into_app_user('feedback', 1355, 'feedback@gmail.com');
SELECT insert_into_app_user('disk', 11111, 'disk@mail.ru');
SELECT insert_into_app_user('sobaka', 5433546, 'sobaka@mail.ru');
SELECT insert_into_app_user('dog', 10887776, 'doggy@mail.ru');
SELECT insert_into_app_user('duck_night', 655599, 'duck@mail.ru');
SELECT insert_into_app_user('sleep_tonight', 1566977, 'sleeeeeeep@mail.ru');
SELECT insert_into_app_user('tomorrow_gun', 1146879087, 'guntom@mail.ru');
SELECT insert_into_app_user('pictures', 2457886, 'pictures@mail.ru');

--subscribes
SELECT insert_into_subscribes('paprika', 1);
SELECT insert_into_subscribes('paprika', 3);
SELECT insert_into_subscribes('paprika', 4);
SELECT insert_into_subscribes('foreach', 1);
SELECT insert_into_subscribes('disk', 2);
SELECT insert_into_subscribes('sobaka', 5);
SELECT insert_into_subscribes('dog', 2);
SELECT insert_into_subscribes('sleep_tonight', 3);
SELECT insert_into_subscribes('pictures', 2);
SELECT insert_into_subscribes('pictures', 4);

--reviews
SELECT insert_into_reviews('paprika', 2, 'not good', 'I thought this serial would be better. Something is going wrong.', '2016-03-05');
SELECT insert_into_reviews('paprika', 1, 'the best one', 'I really like it.', '2016-11-01');
SELECT insert_into_reviews('sobaka', 1, 'could be better', 'My sister recommends, but not me.', '2016-10-15');

--comments
SELECT insert_into_comments('2016-02-02', 'Where is Michael? He is pretty good.', 'paprika', 1, 1);
SELECT insert_into_comments('2016-02-03', 'He has broken his leg.', 'foreach', 1, 1);
SELECT insert_into_comments('2016-02-04', 'Oh, I can not believe it!', 'paprika', 1, 1);