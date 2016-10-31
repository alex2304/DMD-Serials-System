CREATE TABLE Serials (
  serial_id SERIAL PRIMARY KEY,
  title CHAR(100) NOT NULL,
  release_year DATE NOT NULL,
  country CHAR(50) NOT NULL
);

CREATE TABLE Genres (
	genre_title CHAR(50) PRIMARY KEY
);

CREATE TABLE SerialsGengres (
  serial_id INTEGER REFERENCES Serials (serial_id) ON DELETE CASCADE ON UPDATE CASCADE,
  genre_title CHAR(50) REFERENCES Genres (genre_title) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Users(
  login CHAR(20) PRIMARY KEY,
  vk_id INTEGER UNIQUE NOT NULL,
  email CHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Subscribes (
  user_login CHAR(20),
  serial_id INTEGER,
  PRIMARY KEY (user_login, serial_id),
  FOREIGN KEY (serial_id) REFERENCES Serials(serial_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user_login) REFERENCES Users (login) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Reviews (
  user_login CHAR(20) REFERENCES Users (login) ON DELETE CASCADE ON UPDATE CASCADE,
  serial_id INTEGER REFERENCES Serials(serial_id) ON DELETE CASCADE ON UPDATE CASCADE,
  title CHAR(50),
  text CHAR(10000) NOT NULL,
  review_date DATE NOT NULL ,
  PRIMARY KEY (user_login, serial_id)
);

CREATE TABLE Seasons (
  season_id SERIAL PRIMARY KEY,
  season_number INTEGER NOT NULL,
  serial_id INTEGER NOT NULL REFERENCES Serials(serial_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Comments (
  comment_id SERIAL PRIMARY KEY,
  comment_date DATE NOT NULL,
  text CHAR(1000) NOT NULL,

  user_login CHAR(20) REFERENCES Users (login) ON DELETE CASCADE ON UPDATE CASCADE,
  season_id INTEGER REFERENCES Seasons(season_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Episodes (
  episode_id SERIAL PRIMARY KEY,
  episode_number INTEGER NOT NULL,
  title CHAR(20) NOT NULL,
  release_date DATE NOT NULL,
  duration INTEGER NOT NULL,
  rating INTEGER NOT NULL CONSTRAINT positive_rating CHECK (rating > 0 AND rating < 11),

  season_id INTEGER REFERENCES Seasons (season_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Person (
  person_id SERIAL PRIMARY KEY,
  name CHAR(50) NOT NULL,
  birthdade DATE NOT NULL,
  genger CHAR(1) NOT NULL
);

CREATE TABLE Director (
  director_id INTEGER REFERENCES Person (person_id) PRIMARY KEY
);

CREATE TABLE Writer (
  writer_id INTEGER REFERENCES Person (person_id) PRIMARY KEY
);

CREATE TABLE Creator (
  creator_id INTEGER REFERENCES Person (person_id) PRIMARY KEY
);

CREATE TABLE Actor (
  actor_id INTEGER REFERENCES Person (person_id) PRIMARY KEY
);

CREATE TABLE Role (
  role_id SERIAL PRIMARY KEY,
  title CHAR(50) NOT NULL
);

CREATE TABLE Played (
  played_id SERIAL PRIMARY KEY,
  role_id INTEGER REFERENCES Role (role_id) ON DELETE CASCADE ON UPDATE CASCADE,
  actor_id INTEGER REFERENCES Actor (actor_id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE (role_id, actor_id)
);

CREATE TABLE Filmed (
  played_id INTEGER REFERENCES Played (played_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  episode_id INTEGER REFERENCES Episodes (episode_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  PRIMARY KEY (played_id, episode_id)
);

CREATE TABLE Created (
  creator_id INTEGER REFERENCES Creator (creator_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  serial_id INTEGER REFERENCES Serials (serial_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  PRIMARY KEY (creator_id, serial_id)
);

CREATE TABLE Directs (
  director_id INTEGER REFERENCES Director (director_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  episode_id INTEGER REFERENCES Episodes (episode_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  PRIMARY KEY (director_id, episode_id)
);

CREATE TABLE Writes (
  writer_id INTEGER REFERENCES Writer (writer_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  episode_id INTEGER REFERENCES Episodes (episode_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  PRIMARY KEY (writer_id, episode_id)
);

CREATE TABLE Actor_award (
  award_title CHAR(50) PRIMARY KEY
);

CREATE TABLE Serials_award (
  award_title CHAR(50) PRIMARY KEY
);

CREATE TABLE Role_awarded (
  year DATE,
  award_title CHAR(50) REFERENCES Actor_award (award_title) ON DELETE CASCADE ON UPDATE CASCADE ,
  played_id INTEGER REFERENCES Played (played_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  episode_id INTEGER REFERENCES Episodes (episode_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  PRIMARY KEY (played_id, episode_id, award_title)
);

CREATE TABLE Serials_awarded (
  year DATE,
  award_title CHAR(50) REFERENCES Serials_award (award_title) ON DELETE CASCADE ON UPDATE CASCADE ,
  creator_id INTEGER REFERENCES Creator (creator_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  serial_id INTEGER REFERENCES Serials (serial_id) ON DELETE CASCADE ON UPDATE CASCADE ,
  PRIMARY KEY (creator_id, serial_id, award_title)
);

INSERT INTO Serials(title, release_year, country) VALUES ('Test Serial', '2015-10-11', 'Russia');