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
  birthdade DATE NOT NULL,
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
  year DATE,
  award_title CHAR(50),
  played_id INTEGER,
  episode_number INTEGER,
  season_number INTEGER,
  serial_id INTEGER,

  PRIMARY KEY (played_id, episode_number, season_number, serial_id, award_title),
  FOREIGN KEY (award_title) REFERENCES actor_award (award_title) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (played_id) REFERENCES plays (played_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (episode_number, season_number, serial_id) REFERENCES
    episode (episode_number, season_number, serial_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE serial_has_award (
  year DATE,
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
      --if there is an episode in the NEXT season - raise an exception
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
    ELSEIF (NOT exists(SELECT *
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
