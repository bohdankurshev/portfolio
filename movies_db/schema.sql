-- DDL: schema for Movies DB (simplified header)
-- Tables: movies, people, castings, user_ratings, box_office_daily

CREATE SCHEMA IF NOT EXISTS movies_app AUTHORIZATION CURRENT_USER;
-- Щоб за замовчуванням звертатись до цієї схеми:

SET search_path TO movies_app, public;
-- Cтворення таблиці movies

CREATE TABLE movies (
    movie_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title           VARCHAR(200)           NOT NULL,
    release_date    DATE                   NOT NULL,
    runtime_min     INTEGER                NOT NULL CHECK (runtime_min > 0),
    budget_usd      NUMERIC(12,2)          CHECK (budget_usd >= 0),
    genres          TEXT[]                 NOT NULL DEFAULT '{}',
    rating_mpaa     mpaa_rating,
    is_series       BOOLEAN                NOT NULL DEFAULT FALSE,
    metadata        JSONB                  NOT NULL DEFAULT '{}'::jsonb,
    created_at      TIMESTAMP              NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_movie UNIQUE (title, release_date)
);

-- індекси
CREATE INDEX idx_movies_release_date ON movies(release_date);
CREATE INDEX idx_movies_genres_gin   ON movies USING GIN(genres);
CREATE INDEX idx_movies_metadata_gin ON movies USING GIN(metadata);
-- Заповнюємо даними
INSERT INTO movies (title, release_date, runtime_min, budget_usd, genres, rating_mpaa, is_series, metadata)
VALUES
 ('Interstellar',      '2014-11-07', 169, 165000000, ARRAY['Sci-Fi','Drama'],    'PG-13', FALSE, '{"imdb_id":"tt0816692","languages":["en"],"origin":"US"}'),
 ('Parasite',          '2019-05-30', 132,  11400000, ARRAY['Thriller','Drama'],  'R',     FALSE, '{"imdb_id":"tt6751668","languages":["ko"],"origin":"KR"}'),
 ('Inception',         '2010-07-16', 148, 160000000, ARRAY['Sci-Fi','Thriller'], 'PG-13', FALSE, '{"imdb_id":"tt1375666","languages":["en"],"origin":"US"}'),
 ('The Dark Knight',   '2008-07-18', 152, 185000000, ARRAY['Action','Crime'],    'PG-13', FALSE, '{"imdb_id":"tt0468569","languages":["en"],"origin":"US"}'),
 ('The Godfather',     '1972-03-24', 175,   6000000, ARRAY['Crime','Drama'],     'R',     FALSE, '{"imdb_id":"tt0068646","languages":["en"],"origin":"US"}'),
 ('Pulp Fiction',      '1994-10-14', 154,   8000000, ARRAY['Crime','Drama'],     'R',     FALSE, '{"imdb_id":"tt0110912","languages":["en"],"origin":"US"}'),
 ('Spirited Away',     '2001-07-20', 125,  19000000, ARRAY['Animation','Fantasy'],'PG',   FALSE, '{"imdb_id":"tt0245429","languages":["ja"],"origin":"JP"}'),
 ('The Matrix',        '1999-03-31', 136,  63000000, ARRAY['Sci-Fi','Action'],   'R',     FALSE, '{"imdb_id":"tt0133093","languages":["en"],"origin":"US"}');

-- Створення таблиці PEOPLE
CREATE TABLE IF NOT EXISTS people (
  person_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name   VARCHAR(150) NOT NULL,
  birth_date  DATE,
  country     VARCHAR(80),
  created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);
-- Заповнюємо даними PEOPLE
INSERT INTO people (full_name, birth_date, country) VALUES
 ('Christopher Nolan', '1970-07-30', 'UK'),
 ('Leonardo DiCaprio', '1974-11-11', 'US'),
 ('Matthew McConaughey','1969-11-04','US'),
 ('Bong Joon-ho',      '1969-09-14', 'KR'),
 ('Song Kang-ho',      '1967-01-17', 'KR'),
 ('Christian Bale',    '1974-01-30', 'UK'),
 ('Marlon Brando',     '1924-04-03', 'US'),
 ('Quentin Tarantino', '1963-03-27', 'US'),
 ('Hayao Miyazaki',    '1941-01-05', 'JP'),
 ('Keanu Reeves',      '1964-09-02', 'CA');

-- CASTINGS (зв’язок фільм-людина)
CREATE TABLE IF NOT EXISTS castings (
  casting_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  movie_id      BIGINT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
  person_id     BIGINT NOT NULL REFERENCES people(person_id) ON DELETE CASCADE,
  role_type     TEXT   NOT NULL CHECK (role_type IN ('ACTOR','DIRECTOR','WRITER','PRODUCER')),
  character_name VARCHAR(120),
  billing_order  INTEGER CHECK (billing_order >= 1),
  salary_usd     NUMERIC(12,2) CHECK (salary_usd >= 0),
  UNIQUE (movie_id, person_id, role_type)
);

-- Для зручності вставок використаємо SELECT-зв’язування за назвами
-- Inception: Nolan (DIRECTOR), DiCaprio (ACTOR)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'DIRECTOR', NULL, 1, 5000000
FROM movies m JOIN people p ON m.title='Inception' AND p.full_name='Christopher Nolan';
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Cobb',1,20000000
FROM movies m JOIN people p ON m.title='Inception' AND p.full_name='Leonardo DiCaprio';

-- Interstellar: Nolan (DIRECTOR), McConaughey (ACTOR)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'DIRECTOR', NULL, 1, 7000000
FROM movies m JOIN people p ON m.title='Interstellar' AND p.full_name='Christopher Nolan';
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Cooper',1,15000000
FROM movies m JOIN people p ON m.title='Interstellar' AND p.full_name='Matthew McConaughey';

-- Parasite: Bong (DIRECTOR), Song Kang-ho (ACTOR)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'DIRECTOR', NULL, 1, 3000000
FROM movies m JOIN people p ON m.title='Parasite' AND p.full_name='Bong Joon-ho';
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Kim Ki-taek',1,1000000
FROM movies m JOIN people p ON m.title='Parasite' AND p.full_name='Song Kang-ho';

-- The Dark Knight: Nolan (DIRECTOR), Christian Bale (ACTOR)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'DIRECTOR', NULL, 1, 8000000
FROM movies m JOIN people p ON m.title='The Dark Knight' AND p.full_name='Christopher Nolan';
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Bruce Wayne',1,10000000
FROM movies m JOIN people p ON m.title='The Dark Knight' AND p.full_name='Christian Bale';

-- The Godfather: Marlon Brando (ACTOR)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Vito Corleone',1,250000
FROM movies m JOIN people p ON m.title='The Godfather' AND p.full_name='Marlon Brando';

-- Pulp Fiction: Tarantino (DIRECTOR)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'DIRECTOR', NULL, 1, 3000000
FROM movies m JOIN people p ON m.title='Pulp Fiction' AND p.full_name='Quentin Tarantino';

-- Spirited Away: Miyazaki (DIRECTOR)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'DIRECTOR', NULL, 1, 2000000
FROM movies m JOIN people p ON m.title='Spirited Away' AND p.full_name='Hayao Miyazaki';

-- The Matrix: Keanu Reeves (ACTOR)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Neo',1,12000000
FROM movies m JOIN people p ON m.title='The Matrix' AND p.full_name='Keanu Reeves';

-- Створення таблиці USER_RATINGS
CREATE TABLE IF NOT EXISTS user_ratings (
  rating_id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  movie_id   BIGINT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
  user_id    INTEGER NOT NULL,
  rating     NUMERIC(2,1) NOT NULL CHECK (rating BETWEEN 0 AND 10),
  review_text TEXT,
  rated_at   TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (movie_id, user_id)
);
-- Заповнюємо даними USER_RATINGS
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 101, 9.0, 'Mind-bending!' FROM movies WHERE title='Inception';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 102, 8.5, 'Great visuals'  FROM movies WHERE title='Inception';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 201, 9.2, 'Space epic'     FROM movies WHERE title='Interstellar';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 202, 8.9, 'Emotional'      FROM movies WHERE title='Interstellar';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 301, 9.6, 'Masterpiece'    FROM movies WHERE title='Parasite';

-- Створення таблиці BOX_OFFICE_DAILY
CREATE TABLE IF NOT EXISTS box_office_daily (
  movie_id     BIGINT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
  revenue_date DATE   NOT NULL,
  revenue_usd  NUMERIC(12,2) NOT NULL CHECK (revenue_usd >= 0),
  territory    TEXT   NOT NULL DEFAULT 'US',
  PRIMARY KEY (movie_id, revenue_date, territory)
);
-- Заповнюємо даними BOX_OFFICE_DAILY
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, '2010-07-16', 62000000, 'US' FROM movies WHERE title='Inception';
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, '2010-07-17', 42000000, 'US' FROM movies WHERE title='Inception';
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, '2014-11-07', 50000000, 'US' FROM movies WHERE title='Interstellar';
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, '2014-11-08', 38000000, 'US' FROM movies WHERE title='Interstellar';
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, '2019-05-30', 10000000, 'KR' FROM movies WHERE title='Parasite';
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, '2019-05-31',  8000000, 'KR' FROM movies WHERE title='Parasite';

INSERT INTO people (full_name, birth_date, country) VALUES
 ('Heath Ledger',       '1979-04-04', 'AU'),
 ('Al Pacino',          '1940-04-25', 'US'),
 ('Uma Thurman',        '1970-04-29', 'US'),
 ('John Travolta',      '1954-02-18', 'US'),
 ('Rumi Hiiragi',       '1987-08-01', 'JP'),
 ('Carrie-Anne Moss',   '1967-08-21', 'CA'),
 ('Laurence Fishburne', '1961-07-30', 'US');


-- The Dark Knight: Heath Ledger (Joker)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Joker',2,8000000
FROM movies m JOIN people p ON m.title='The Dark Knight' AND p.full_name='Heath Ledger';

-- The Godfather: Al Pacino (Michael Corleone)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Michael Corleone',2,350000
FROM movies m JOIN people p ON m.title='The Godfather' AND p.full_name='Al Pacino';

-- Pulp Fiction: Uma Thurman (Mia), John Travolta (Vincent)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Mia Wallace',2,500000
FROM movies m JOIN people p ON m.title='Pulp Fiction' AND p.full_name='Uma Thurman';
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Vincent Vega',1,800000
FROM movies m JOIN people p ON m.title='Pulp Fiction' AND p.full_name='John Travolta';

-- Spirited Away: Rumi Hiiragi (Chihiro voice)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Chihiro (voice)',1,150000
FROM movies m JOIN people p ON m.title='Spirited Away' AND p.full_name='Rumi Hiiragi';

-- The Matrix: Carrie-Anne Moss (Trinity), Laurence Fishburne (Morpheus)
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Trinity',2,2000000
FROM movies m JOIN people p ON m.title='The Matrix' AND p.full_name='Carrie-Anne Moss';
INSERT INTO castings (movie_id, person_id, role_type, character_name, billing_order, salary_usd)
SELECT m.movie_id, p.person_id, 'ACTOR','Morpheus',3,2500000
FROM movies m JOIN people p ON m.title='The Matrix' AND p.full_name='Laurence Fishburne';


-- Inception
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 103, 9.4, 'Rewatch value!' FROM movies WHERE title='Inception';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 104, 8.8, 'Great soundtrack' FROM movies WHERE title='Inception';

-- Interstellar
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 203, 9.4, 'Tars is the best' FROM movies WHERE title='Interstellar';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 204, 8.7, 'A bit long but epic' FROM movies WHERE title='Interstellar';

-- Parasite
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 302, 9.3, 'Brilliant social commentary' FROM movies WHERE title='Parasite';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 303, 9.0, 'Deserved the Oscar' FROM movies WHERE title='Parasite';

-- The Dark Knight
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 401, 9.5, 'Ledger is legendary' FROM movies WHERE title='The Dark Knight';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 402, 9.2, 'Best superhero movie' FROM movies WHERE title='The Dark Knight';

-- The Godfather
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 501, 9.8, 'Timeless classic' FROM movies WHERE title='The Godfather';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 502, 9.6, 'Masterful storytelling' FROM movies WHERE title='The Godfather';

-- Pulp Fiction
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 601, 9.0, 'Nonlinear brilliance' FROM movies WHERE title='Pulp Fiction';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 602, 8.7, 'Iconic dialogues' FROM movies WHERE title='Pulp Fiction';

-- Spirited Away (залишимо 1-2 оцінки)
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 701, 9.1, 'Magical' FROM movies WHERE title='Spirited Away';

-- The Matrix
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 801, 9.3, 'Mind opened' FROM movies WHERE title='The Matrix';
INSERT INTO user_ratings (movie_id, user_id, rating, review_text)
SELECT movie_id, 802, 9.0, 'Ahead of its time' FROM movies WHERE title='The Matrix';


-- Inception (US, 5 днів)
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, d::date, r, 'US' FROM movies, LATERAL (
  VALUES
  ('2010-07-15',62000000),
  ('2010-07-17',42000000),
  ('2010-07-18',35000000),
  ('2010-07-19',15000000),
  ('2010-07-20',12000000)
) AS t(d, r)
WHERE title='Inception';

-- Inception (додаємо 3 нові дні)
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, d::date, r, 'US'
FROM movies, LATERAL (
  VALUES
    ('2010-07-18', 35000000),
    ('2010-07-19', 15000000),
    ('2010-07-20', 12000000)
) AS t(d, r)
WHERE title='Inception';

-- Interstellar (додаємо 3 нові дні)
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, d::date, r, 'US'
FROM movies, LATERAL (
  VALUES
    ('2014-11-09', 30000000),
    ('2014-11-10', 12000000),
    ('2014-11-11', 10000000)
) AS t(d, r)
WHERE title='Interstellar';

-- Parasite (додаємо 3 нові дні)
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, d::date, r, 'KR'
FROM movies, LATERAL (
  VALUES
    ('2019-06-01', 12000000),
    ('2019-06-02',  9000000),
    ('2019-06-03',  4000000)
) AS t(d, r)
WHERE title='Parasite';



-- The Dark Knight (US, 5 днів)
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, d::date, r, 'US'
FROM movies, LATERAL (
  VALUES
    ('2008-07-18', 67000000),  -- прем'єрний день
    ('2008-07-19', 48000000),
    ('2008-07-20', 43000000),
    ('2008-07-21', 16000000),
    ('2008-07-22', 14000000)
) AS t(d, r)
WHERE title='The Dark Knight';

-- The Matrix (US, 5 днів)
INSERT INTO box_office_daily (movie_id, revenue_date, revenue_usd, territory)
SELECT movie_id, d::date, r, 'US'
FROM movies, LATERAL (
  VALUES
    ('1999-03-31', 28000000),  -- прем'єрний день
    ('1999-04-01', 18000000),
    ('1999-04-02', 15000000),
    ('1999-04-03', 13000000),
    ('1999-04-04', 12000000)
) AS t(d, r)
WHERE title='The Matrix';





