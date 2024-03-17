-- Drop database if it exists and create a new one
DROP DATABASE IF exists games;
CREATE DATABASE games;
USE games;

-- add utf8mb4 support
ALTER DATABASE games CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Drop tables if they exist
DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS game_videos;
DROP TABLE IF EXISTS game_categories;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS game_genres;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS game_tags;
DROP TABLE IF EXISTS supp_langs;
DROP TABLE IF EXISTS game_langs;
DROP TABLE IF EXISTS supp_audio_langs;
DROP TABLE IF EXISTS game_audio_langs;
DROP TABLE IF EXISTS developers;
DROP TABLE IF EXISTS game_developers;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS game_publishers;

-- Table with general info about the game
CREATE TABLE game (
    -- unique game ID
    game_id INT,
    game_name VARCHAR(255),
    release_date DATE,
    -- Range of owners for the game, (ex: 0-2000)
    estimated_owners VARCHAR(255),
    -- price of game in USD
    price_usd DECIMAL(10, 2),
    -- Text description of game 
    about_game TEXT,
    -- Metacritic score for game, out of 10, (ex: 1, 5, 7)
    metacritic_score INT,
    -- Platform support for game, (ex: "110" windows and linux support)
    platform_support VARCHAR(3),
    -- URL to game image
    header_image VARCHAR(255),
    PRIMARY KEY (game_id, game_name)
);

-- Table containing game videos
CREATE TABLE game_videos (
    -- unqiue game ID
    game_id INT,
    -- url that links to video for gameplay/trailer
    video_url VARCHAR(255),
    PRIMARY KEY (game_id, video_url),
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE
);

-- Table containing User/Client information
CREATE TABLE user (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) UNIQUE NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 200.00,
    password_hash BINARY(64) NOT NULL,
    salt CHAR(8) NOT NULL,
    -- user role (admin, user, etc)
    user_role VARCHAR(10) NOT NULL DEFAULT 'user',
    date_joined DATE
); 

-- Table containing purchases made by users
CREATE TABLE purchases (
    -- unqiue purchase ID for game purchased by user
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    game_id INT,
    purchase_date DATE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE
);

-- Contains single category for each game
CREATE TABLE categories (
    -- Unique category ID corresponding to category name
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    -- category name (ex: Co-op, PVP)
    category_name VARCHAR(255) UNIQUE
);

-- Junction table for relation between categories and games
CREATE TABLE game_categories (
    game_id INT,
    category_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) 
    ON DELETE CASCADE
);

-- Contains single genre for each game
CREATE TABLE genres (
    -- Unqiue genre ID corresponding to genre name
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    -- genre name (ex: Horror, Action)
    genre_name VARCHAR(255) UNIQUE
);

-- Junction table for relation between genres and games
CREATE TABLE game_genres (
    game_id INT,
    genre_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

-- Contains all unique tags
CREATE TABLE tags (
    -- Unqiue tag ID corresponding to tag name
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    -- tag name (ex: Pixel graphics, Science, Shoot 'Em Up)
    tag_name VARCHAR(255) UNIQUE
);

-- Junction table for relation between tags and games
CREATE TABLE game_tags (
    game_id INT,
    tag_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- Contains all unique languages
CREATE TABLE supp_langs (
    -- Unqiue language ID corresponding to text language in-game
    lang_id INT PRIMARY KEY AUTO_INCREMENT,
    -- name of language used in game for text (ex: French, Spanish)
    lang VARCHAR(255) UNIQUE
);

-- Junction table for relation between supported languages and games
CREATE TABLE game_langs (
    game_id INT,
    lang_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (lang_id) REFERENCES supp_langs(lang_id) ON DELETE CASCADE
);

-- Contains all unique audio languages
CREATE TABLE supp_audio_langs (
    -- Unqiue language ID corresponding to in game audio language
    audio_lang_id INT PRIMARY KEY AUTO_INCREMENT,
    -- name of language used for in-game audio
    audio_lang VARCHAR(255) UNIQUE
);

-- Junction table for relation between supported audio languages and games
CREATE TABLE game_audio_langs (
    game_id INT,
    audio_lang_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (audio_lang_id) REFERENCES supp_audio_langs(audio_lang_id)
    ON DELETE CASCADE
);

-- Contains all unique developers
CREATE TABLE developers (
    -- Unqiue developer ID corresponding to developer name
    dev_id INT PRIMARY KEY AUTO_INCREMENT,
    -- developer name (ex: raven studios)
    dev_name VARCHAR(255) UNIQUE
);

-- Junction table for relation between developers and games
CREATE TABLE game_developers (
    game_id INT,
    dev_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (dev_id) REFERENCES developers(dev_id) ON DELETE CASCADE
);

-- Contains all unique publishers
CREATE TABLE publishers (
    -- Unqiue publisher ID corresponding to publisher name
    pub_id INT PRIMARY KEY AUTO_INCREMENT,
    -- publisher name (ex: bad gremlin studios)
    pub_name VARCHAR(255) UNIQUE
);

-- Junction table for relation between publishers and games
CREATE TABLE game_publishers (
    game_id INT,
    pub_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (pub_id) REFERENCES publishers(pub_id) ON DELETE CASCADE
);


-- header_image index
CREATE INDEX idx_game_price_usd ON game(price_usd);

-- view that contains all attributes
DROP VIEW IF EXISTS attributes_view;

-- Consolidates categories, genres, tags, languages, audio languages, 
-- developers, and publishers into a unified view, sorted by type and name.
CREATE VIEW attributes_view AS
SELECT
    'category' AS type,
    category_id AS id,
    category_name AS name
FROM categories
UNION
SELECT
    'genre' AS type,
    genre_id AS id,
    genre_name AS name
FROM genres
UNION
SELECT
    'tag' AS type,
    tag_id AS id,
    tag_name AS name
FROM tags
UNION
SELECT
    'lang' AS type,
    lang_id AS id,
    lang AS name
FROM supp_langs
UNION
SELECT
    'audio_lang' AS type,
    audio_lang_id AS id,
    audio_lang AS name
FROM supp_audio_langs
UNION
SELECT
    'developer' AS type,
    dev_id AS id,
    dev_name AS name
FROM developers
UNION
SELECT
    'publisher' AS type,
    pub_id AS id,
    pub_name AS name
FROM publishers
ORDER BY type, name;
