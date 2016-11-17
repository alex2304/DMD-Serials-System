CREATE TABLE serial (
  serial_id SERIAL PRIMARY KEY,
  title CHAR(100) NOT NULL,
  release_date DATE NOT NULL,
  country CHAR(50) NOT NULL
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
  FOREIGN KEY (serial_id) REFERENCES serial(serial_id) ON DELETE CASCADE ON UPDATE CASCADE
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
  CONSTRAINT positive_rating CHECK (rating > 0 AND rating < 11)
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

CREATE OR REPLACE FUNCTION check_data_release() RETURNS TRIGGER AS $check_data_release$
  BEGIN
    IF (NEW.release_date < (SELECT s.release_date
                           FROM serial s
                           WHERE (NEW.serial_id = s.serial_id)))
    THEN
    RAISE EXCEPTION 'serial release_date must be smaller than episode release_date';
    END IF;
    RETURN NEW;
  END;
$check_data_release$ LANGUAGE plpgsql;

--DROP TRIGGER check_episode_data_release on episode;
CREATE TRIGGER check_episode_data_release
  BEFORE INSERT OR UPDATE ON episode
  FOR EACH ROW EXECUTE PROCEDURE check_data_release();

--serials
INSERT INTO serial (title, release_date, country) VALUES ('University comedy', '2001-03-01', 'Russia');
INSERT INTO serial (title, release_date, country) VALUES ('Campus horror', '2010-02-15', 'Russia');
INSERT INTO serial (title, release_date, country) VALUES ('I have a dream', '2011-11-11', 'Russia');
INSERT INTO serial (title, release_date, country) VALUES ('Money honey', '2012-12-12', 'Russia');
INSERT INTO serial (title, release_date, country) VALUES ('Everyday shuttling', '2015-03-21', 'Russia');
--seasons
INSERT INTO season VALUES (1, 1);
INSERT INTO season VALUES (2, 1);
INSERT INTO season VALUES (1, 2);
INSERT INTO season VALUES (1, 3);
INSERT INTO season VALUES (1, 4);
INSERT INTO season VALUES (1, 5);
--episodes
INSERT INTO episode VALUES ('Epic start', '2001-03-02', 24, 7, 1, 1, 1);
INSERT INTO episode VALUES ('Fuel ends', '2001-03-02', 35, 2, 2, 1, 1);
INSERT INTO episode VALUES ('Not a journey!', '2001-03-02', 24, 8, 1, 2, 1);
INSERT INTO episode VALUES ('Do not cry', '2001-03-02', 24, 10, 2, 2, 1);
INSERT INTO episode VALUES ('Rubbish', '2014-04-20', 24, 7, 1, 1, 2);
INSERT INTO episode VALUES ('Best prisoner', '2010-03-02', 24, 3, 2, 1, 2);
INSERT INTO episode VALUES ('Foolish guy', '2013-03-02', 24, 6, 1, 1, 3);
INSERT INTO episode VALUES ('Cave disease', '2015-11-30', 24, 2, 1, 1, 4);
INSERT INTO episode VALUES ('Light in tunnel', '2016-11-02', 24, 9, 1, 1, 5);

--persons
INSERT INTO person (name, birthdade, genger) VALUES ('Brutus Ullson', '1983-09-09', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Emma fon Schmidt', '1987-07-25', 'f');
INSERT INTO person (name, birthdade, genger) VALUES ('Dill Duck', '1964-12-31', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Bill Deal', '1978-03-14', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Mary Paris', '1994-02-03', 'f');
--creators
INSERT INTO creator VALUES (1);
INSERT INTO creator VALUES (2);
INSERT INTO creator VALUES (3);
INSERT INTO creator VALUES (4);
INSERT INTO creator VALUES (5);
--creates
INSERT INTO creates VALUES (1, 1);
INSERT INTO creates VALUES (2, 1);
INSERT INTO creates VALUES (2, 2);
INSERT INTO creates VALUES (3, 3);
INSERT INTO creates VALUES (4, 4);
INSERT INTO creates VALUES (5, 5);
--persons
INSERT INTO person (name, birthdade, genger) VALUES ('Jan Jack', '1979-05-13', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Fill Bill', '1945-10-09', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Stella Muck', '1989-02-28', 'f');
INSERT INTO person (name, birthdade, genger) VALUES ('Bella Kick', '1997-08-22', 'f');
INSERT INTO person (name, birthdade, genger) VALUES ('John Bon', '1977-07-07', 'm');
--writers
INSERT INTO writer VALUES (6);
INSERT INTO writer VALUES (7);
INSERT INTO writer VALUES (8);
INSERT INTO writer VALUES (9);
INSERT INTO writer VALUES (10);
--writes
INSERT INTO writes VALUES (6, 1, 1, 1);
INSERT INTO writes VALUES (6, 2, 1, 1);
INSERT INTO writes VALUES (7, 2, 1, 1);
INSERT INTO writes VALUES (8, 1, 2, 1);
INSERT INTO writes VALUES (6, 2, 2, 1);
INSERT INTO writes VALUES (9, 1, 1, 2);
INSERT INTO writes VALUES (10, 2, 1, 2);
INSERT INTO writes VALUES (7, 1, 1, 3);
INSERT INTO writes VALUES (8, 1, 1, 4);
INSERT INTO writes VALUES (9, 1, 1, 5);
--directors
INSERT INTO director VALUES (3);
INSERT INTO director VALUES (4);
INSERT INTO director VALUES (5);
INSERT INTO director VALUES (6);
INSERT INTO director VALUES (7);
--directs
INSERT INTO directs VALUES (3, 1, 1, 1);
INSERT INTO directs VALUES (4, 2, 1, 1);
INSERT INTO directs VALUES (5, 1, 2, 1);
INSERT INTO directs VALUES (6, 2, 2, 1);
INSERT INTO directs VALUES (7, 1, 1, 2);
INSERT INTO directs VALUES (3, 2, 1, 2);
INSERT INTO directs VALUES (4, 1, 1, 3);
INSERT INTO directs VALUES (5, 1, 1, 4);
INSERT INTO directs VALUES (6, 1, 1, 5);

--persons
INSERT INTO person (name, birthdade, genger) VALUES ('Rick Pick', '1995-07-20', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Ben Pen', '1982-12-15', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Nil Gill', '1992-10-01', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Sara Para-pa-para', '1998-04-01', 'f');
INSERT INTO person (name, birthdade, genger) VALUES ('Milla Milk', '1980-10-19', 'f');
INSERT INTO person (name, birthdade, genger) VALUES ('Kira Witch', '1988-08-08', 'f');
INSERT INTO person (name, birthdade, genger) VALUES ('Peter Potter', '1990-04-03', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Curt Burt', '1974-05-06', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Daren Paren', '1978-11-28', 'm');
INSERT INTO person (name, birthdade, genger) VALUES ('Mark Dark', '1963-06-020', 'm');
--actors
INSERT INTO actor VALUES (1);
INSERT INTO actor VALUES (2);
INSERT INTO actor VALUES (3);
INSERT INTO actor VALUES (8);
INSERT INTO actor VALUES (9);--5
INSERT INTO actor VALUES (10);
INSERT INTO actor VALUES (11);
INSERT INTO actor VALUES (12);
INSERT INTO actor VALUES (13);
INSERT INTO actor VALUES (14);--10
INSERT INTO actor VALUES (15);
INSERT INTO actor VALUES (16);
INSERT INTO actor VALUES (17);
INSERT INTO actor VALUES (18);
INSERT INTO actor VALUES (19);--15
INSERT INTO actor VALUES (20);

--genres
INSERT INTO genre VALUES ('horror');
INSERT INTO genre VALUES ('comedy');
INSERT INTO genre VALUES ('thriller');
INSERT INTO genre VALUES ('romance');
INSERT INTO genre VALUES ('drama');
--serial has genre
INSERT INTO serial_has_genre VALUES (1, 'horror');
INSERT INTO serial_has_genre VALUES (1, 'thriller');
INSERT INTO serial_has_genre VALUES (1, 'drama');
INSERT INTO serial_has_genre VALUES (2, 'drama');
INSERT INTO serial_has_genre VALUES (3, 'thriller');
INSERT INTO serial_has_genre VALUES (3, 'romance');
INSERT INTO serial_has_genre VALUES (4, 'horror');
INSERT INTO serial_has_genre VALUES (4, 'comedy');
INSERT INTO serial_has_genre VALUES (5, 'horror');
INSERT INTO serial_has_genre VALUES (5, 'drama');

--serial award
INSERT INTO serial_award VALUES ('best horror');
INSERT INTO serial_award VALUES ('best drama');
--serial has award
INSERT INTO serial_has_award VALUES ('2016-11-02', 'best horror', 1);
INSERT INTO serial_has_award VALUES ('2015-11-02', 'best horror', 2);
INSERT INTO serial_has_award VALUES ('2016-11-02', 'best drama', 2);

--roles
INSERT INTO role (title) VALUES ('Tree');
INSERT INTO role (title) VALUES ('Barbara');
INSERT INTO role (title) VALUES ('Bill');
INSERT INTO role (title) VALUES ('Strange person');
INSERT INTO role (title) VALUES ('Chef');--5
INSERT INTO role (title) VALUES ('Cooker');
INSERT INTO role (title) VALUES ('Gungster');
INSERT INTO role (title) VALUES ('Thief');
INSERT INTO role (title) VALUES ('Adam');
INSERT INTO role (title) VALUES ('Tim');--10
INSERT INTO role (title) VALUES ('Alla');
--playes
INSERT INTO plays (role_id, actor_id) VALUES (1, 1);
INSERT INTO plays (role_id, actor_id) VALUES (1, 2);
INSERT INTO plays (role_id, actor_id) VALUES (2, 3);
INSERT INTO plays (role_id, actor_id) VALUES (3, 8);
INSERT INTO plays (role_id, actor_id) VALUES (3, 9);--5
INSERT INTO plays (role_id, actor_id) VALUES (4, 10);
INSERT INTO plays (role_id, actor_id) VALUES (4, 8);
INSERT INTO plays (role_id, actor_id) VALUES (5, 8);
INSERT INTO plays (role_id, actor_id) VALUES (6, 9);
INSERT INTO plays (role_id, actor_id) VALUES (7, 10);--10
INSERT INTO plays (role_id, actor_id) VALUES (8, 11);
INSERT INTO plays (role_id, actor_id) VALUES (9, 12);
INSERT INTO plays (role_id, actor_id) VALUES (9, 13);
INSERT INTO plays (role_id, actor_id) VALUES (10, 14);
INSERT INTO plays (role_id, actor_id) VALUES (11, 15);--15
INSERT INTO plays (role_id, actor_id) VALUES (11, 16);

--actor award
INSERT INTO actor_award VALUES ('best role');
INSERT INTO actor_award VALUES ('worst role');
--role_has_award
INSERT INTO role_has_award VALUES ('2015-04-04', 'best role', 1, 1, 1, 1);
INSERT INTO role_has_award VALUES ('2015-04-04', 'worst role', 2, 2, 1, 1);
INSERT INTO role_has_award VALUES ('2015-04-04', 'best role', 1, 1, 2, 1);
INSERT INTO role_has_award VALUES ('2016-11-04', 'worst role', 4, 2, 2, 1);
INSERT INTO role_has_award VALUES ('2016-12-04', 'best role', 1, 1, 1, 3);

--films
INSERT INTO films VALUES (1, 1, 1, 1);
INSERT INTO films VALUES (2, 1, 1, 1);
INSERT INTO films VALUES (3, 1, 1, 1);
INSERT INTO films VALUES (1, 2, 1, 1);
INSERT INTO films VALUES (2, 2, 1, 1);--5
INSERT INTO films VALUES (1, 1, 2, 1);
INSERT INTO films VALUES (4, 2, 2, 1);
INSERT INTO films VALUES (5, 1, 1, 2);
INSERT INTO films VALUES (6, 1, 1, 2);
INSERT INTO films VALUES (5, 2, 1, 2);--10
INSERT INTO films VALUES (6, 2, 1, 2);
INSERT INTO films VALUES (7, 2, 1, 2);
INSERT INTO films VALUES (8, 1, 1, 3);
INSERT INTO films VALUES (9, 1, 1, 3);
INSERT INTO films VALUES (10, 1, 1, 3);--15
INSERT INTO films VALUES (1, 1, 1, 3);
INSERT INTO films VALUES (11, 1, 1, 4);
INSERT INTO films VALUES (12, 1, 1, 4);
INSERT INTO films VALUES (13, 1, 1, 4);
INSERT INTO films VALUES (14, 1, 1, 4);--20
INSERT INTO films VALUES (14, 1, 1, 5);
INSERT INTO films VALUES (1, 1, 1, 5);
INSERT INTO films VALUES (15, 1, 1, 5);
INSERT INTO films VALUES (16, 1, 1, 5);--24

--app_users
INSERT INTO app_user VALUES ('paprika', 123456, 'yayaya@mail.ru');
INSERT INTO app_user VALUES ('foreach', 492874, 'foreach@mail.ru');
INSERT INTO app_user VALUES ('feedback', 1355, 'feedback@gmail.com');
INSERT INTO app_user VALUES ('disk', 11111, 'disk@mail.ru');
INSERT INTO app_user VALUES ('sobaka', 5433546, 'sobaka@mail.ru');
INSERT INTO app_user VALUES ('dog', 10887776, 'doggy@mail.ru');
INSERT INTO app_user VALUES ('duck_night', 655599, 'duck@mail.ru');
INSERT INTO app_user VALUES ('sleep_tonight', 1566977, 'sleeeeeeep@mail.ru');
INSERT INTO app_user VALUES ('tomorrow_gun', 1146879087, 'guntom@mail.ru');
INSERT INTO app_user VALUES ('pictures', 2457886, 'pictures@mail.ru');

--subscribes
INSERT INTO subscribes VALUES ('paprika', 1);
INSERT INTO subscribes VALUES ('paprika', 3);
INSERT INTO subscribes VALUES ('paprika', 4);
INSERT INTO subscribes VALUES ('foreach', 1);
INSERT INTO subscribes VALUES ('disk', 2);
INSERT INTO subscribes VALUES ('sobaka', 5);
INSERT INTO subscribes VALUES ('dog', 2);
INSERT INTO subscribes VALUES ('sleep_tonight', 3);
INSERT INTO subscribes VALUES ('pictures', 2);
INSERT INTO subscribes VALUES ('pictures', 4);

--reviews
INSERT INTO reviews VALUES ('paprika', 2, 'not good', 'I thought this serial would be better. Something is going wrong.', '2016-03-05');
INSERT INTO reviews VALUES ('paprika', 1, 'the best one', 'I really like it.', '2016-11-01');
INSERT INTO reviews VALUES ('sobaka', 1, 'could be better', 'My sister recommends, but not me.', '2016-10-15');

--comments
INSERT INTO comments (comment_date, text, app_user_login, season_number, serial_id) VALUES
  ('2016-02-02', 'Where is Michael? He is pretty good.', 'paprika', 1, 1);
INSERT INTO comments (comment_date, text, app_user_login, season_number, serial_id) VALUES
  ('2016-02-03', 'He has broken his leg.', 'foreach', 1, 1);
INSERT INTO comments (comment_date, text, app_user_login, season_number, serial_id) VALUES
  ('2016-02-04', 'Oh, I can not believe it!', 'paprika', 1, 1);