DROP FUNCTION count_serials_by_genre()

CREATE OR REPLACE FUNCTION count_serials_by_genre() RETURNS TABLE (genre CHARACTER, number_of_serials BIGINT) AS $$
  BEGIN
    RETURN QUERY SELECT g.genre_title, COUNT(*)
    FROM genre g NATURAL JOIN serial_has_genre shg
    GROUP BY g.genre_title;
  END
$$ LANGUAGE plpgsql;
