
DROP FUNCTION get_filtered_serials(text, integer, integer, NUMERIC, NUMERIC, text, text, text);
drop FUNCTION get_serial_rating(INTEGER);


CREATE OR REPLACE FUNCTION get_serial_rating(_serial_id INTEGER) RETURNS
  NUMERIC AS
  $BODY$
    SELECT AVG(e.rating) FROM episode e INNER JOIN serial s
        ON e.serial_id = s.serial_id AND s.serial_id = _serial_id;
  $BODY$
  LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_filtered_serials(title_part TEXT, start_year INTEGER, end_year INTEGER,
  start_rating NUMERIC, end_rating NUMERIC, countries TEXT, actors TEXT, genres TEXT) RETURNS
  TABLE(serial_id INTEGER, title CHAR, release_year INTEGER, country CHAR) AS
  $BODY$
    SELECT s.serial_id, s.title, s.release_year, s.country FROM serial s
    WHERE lower(s.title) LIKE ('%' || lower(title_part) || '%')                   -- title matching
    AND s.release_year <@ INT4RANGE(start_year, end_year + 1)                     -- year matching
    AND get_serial_rating(s.serial_id) <@ NUMRANGE(start_rating, end_rating + 1); -- rating matching
    -- AND
  $BODY$
  LANGUAGE sql;