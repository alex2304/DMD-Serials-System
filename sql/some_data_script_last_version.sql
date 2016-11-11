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
SELECT insert_into_episode('Best prisoner', '2014-04-22', 24, 3, 2, 1, 2);
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