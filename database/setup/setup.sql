-- Drop database if it exists and create a new one
DROP DATABASE IF exists games;
CREATE DATABASE games;
USE games;

-- Drop users if they exist
DROP USER IF EXISTS 'admin'@'localhost';
DROP USER IF EXISTS 'client'@'localhost';

-- Create admin and client user
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
CREATE USER 'client'@'localhost' IDENTIFIED BY 'client';

-- Grant privileges to admin and client user
GRANT ALL PRIVILEGES ON games.* TO 'admin'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON games.* TO 'client'@'localhost';

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
    header_iamge VARCHAR(255),
    PRIMARY KEY (game_id, game_name)
);

-- Alter table to support utf8mb4 encoding (for emoji support)
-- database connection must be set to utf8mb4 to support emoji
ALTER TABLE game
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Table containing game videos
CREATE TABLE game_videos (
    video_id INT PRIMARY KEY AUTO_INCREMENT,
    game_id INT,
    video_url VARCHAR(255),
    FOREIGN KEY (game_id) REFERENCES game(game_id)
);

-- Table containing User/Client information
CREATE TABLE user (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash BINARY(64) NOT NULL,
    salt CHAR(8) NOT NULL,
    age INT,
    -- user role (admin, user, etc)
    user_role VARCHAR(255) NOT NULL DEFAULT 'user',
    date_joined DATE
); 

-- Table containing purchases made by users
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    game_id INT,
    purchase_date DATE,
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (game_id) REFERENCES game(game_id)
);

-- Contains single category for each game
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(255) UNIQUE
);

-- Junction table for relation between categories and games
CREATE TABLE game_categories (
    game_id INT,
    category_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Contains single genre for each game
CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(255) UNIQUE
);

-- Junction table for relation between genres and games
CREATE TABLE game_genres (
    game_id INT,
    genre_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

-- Contains all unique tags
CREATE TABLE tags (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(255) UNIQUE
);

-- Junction table for relation between tags and games
CREATE TABLE game_tags (
    game_id INT,
    tag_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
);

-- Contains all unique languages
CREATE TABLE supp_langs (
    lang_id INT PRIMARY KEY AUTO_INCREMENT,
    lang VARCHAR(255) UNIQUE
);

-- Junction table for relation between supported languages and games
CREATE TABLE game_langs (
    game_id INT,
    lang_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (lang_id) REFERENCES supp_langs(lang_id)
);

-- Contains all unique audio languages
CREATE TABLE supp_audio_langs (
    audio_lang_id INT PRIMARY KEY AUTO_INCREMENT,
    audio_lang VARCHAR(255) UNIQUE
);

-- Junction table for relation between supported audio languages and games
CREATE TABLE game_audio_langs (
    game_id INT,
    audio_lang_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (audio_lang_id) REFERENCES supp_audio_langs(audio_lang_id)
);

-- Contains all unique developers
CREATE TABLE developers (
    dev_id INT PRIMARY KEY AUTO_INCREMENT,
    dev_name VARCHAR(255) UNIQUE
);

-- Alter table to support utf8mb4 encoding (for emoji support)
-- database connection must be set to utf8mb4 to support emoji
ALTER TABLE developers 
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Junction table for relation between developers and games
CREATE TABLE game_developers (
    game_id INT,
    dev_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (dev_id) REFERENCES developers(dev_id)
);

-- Contains all unique publishers
CREATE TABLE publishers (
    pub_id INT PRIMARY KEY AUTO_INCREMENT,
    pub_name VARCHAR(255) UNIQUE
);

-- Alter table to support utf8mb4 encoding (for emoji support)
-- database connection must be set to utf8mb4 to support emoji
ALTER TABLE publishers
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Junction table for relation between publishers and games
CREATE TABLE game_publishers (
    game_id INT,
    pub_id INT,
    FOREIGN KEY (game_id) REFERENCES game(game_id),
    FOREIGN KEY (pub_id) REFERENCES publishers(pub_id)
);

-- Drop Procedures and Functions if they exist
DROP FUNCTION IF EXISTS make_salt;
DROP FUNCTION IF EXISTS authenticate;
DROP PROCEDURE IF EXISTS sp_add_user;
DROP PROCEDURE IF EXISTS sp_change_password;

-- Generate a random salt for the user
DELIMITER !
CREATE FUNCTION make_salt(num_chars INT)
RETURNS VARCHAR(20) NOT DETERMINISTIC
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    -- Don't want to generate more than 20 characters of salt.
    SET num_chars = LEAST(20, num_chars);

    -- Generate the salt!  Characters used are ASCII code 32 (space)
    -- through 126 ('z').
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END !
DELIMITER ;

-- Procedure to add a new user to the user table
DELIMITER !
CREATE PROCEDURE sp_add_user(
    new_username VARCHAR(20), password VARCHAR(20), user_role VARCHAR(20))
BEGIN
    DECLARE new_salt CHAR(8);
    DECLARE new_hash BINARY(64);

    -- Generate a new salt and hash for the password.
    SET new_salt = make_salt(8);
    SET new_hash = SHA2(CONCAT(new_salt, password), 256);

    -- Insert the new user into the table.
    INSERT INTO user (username, password_hash, salt, user_role, date_joined)
    VALUES (new_username, new_hash, new_salt, user_role, CURDATE());
END !
DELIMITER ;

-- Procedure to authenticate a user
DELIMITER !
CREATE FUNCTION authenticate(username VARCHAR(20), password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
BEGIN
  DECLARE user_salt CHAR(8);
  DECLARE user_hash BINARY(64);
  DECLARE given_hash BINARY(64);

  -- Get the salt and hash for the user.
  SELECT salt, password_hash INTO user_salt, user_hash
  FROM user
  WHERE user.username = username;

  -- If the user doesn't exist, return 0.
  IF user_salt IS NULL THEN
    RETURN 0;
  END IF;

  -- Hash the given password with the user's salt.
  SET given_hash = SHA2(CONCAT(user_salt, password), 256);

  -- Return 1 if the hashes match, 0 otherwise.
  RETURN user_hash = given_hash;
END !
DELIMITER ;

-- Procedure to change a user's password
DELIMITER !
CREATE PROCEDURE sp_change_password(
  username VARCHAR(20), new_password VARCHAR(20))
BEGIN
  DECLARE new_salt CHAR(8);
  DECLARE new_hash BINARY(64);

  -- Generate a new salt and hash for the password.
  SET new_salt = make_salt(8);
  SET new_hash = SHA2(CONCAT(new_salt, new_password), 256);

  -- Update the user's salt and hash in the table.
  UPDATE user
  SET salt = new_salt, password_hash = new_hash
  WHERE user.username = username;
END !
DELIMITER ;

-- Add admin user
CALL sp_add_user('admin', 'admin', 'admin');

-- Procedure to get all information about a game
DROP PROCEDURE IF EXISTS sp_get_game_info;

DELIMITER !
CREATE PROCEDURE sp_get_game_info(game_id INT)
BEGIN
    CREATE TEMPORARY TABLE game_info AS
    SELECT
        game.game_id,
        game.game_name,
        game.release_date,
        game.estimated_owners,
        game.price_usd,
        game.about_game,
        game.metacritic_score,
        game.platform_support,
        game.header_iamge,
        GROUP_CONCAT(DISTINCT game_videos.video_url) AS video_urls,
        GROUP_CONCAT(DISTINCT categories.category_name) AS categories,
        GROUP_CONCAT(DISTINCT genres.genre_name) AS genres,
        GROUP_CONCAT(DISTINCT tags.tag_name) AS tags,
        GROUP_CONCAT(DISTINCT supp_langs.lang) AS supported_langs,
        GROUP_CONCAT(DISTINCT supp_audio_langs.audio_lang) AS supported_audio_langs,
        GROUP_CONCAT(DISTINCT developers.dev_name) AS developers,
        GROUP_CONCAT(DISTINCT publishers.pub_name) AS publishers
    FROM game
    NATURAL LEFT JOIN game_videos
    NATURAL LEFT JOIN game_categories
    NATURAL LEFT JOIN categories
    NATURAL LEFT JOIN game_genres
    NATURAL LEFT JOIN genres
    NATURAL LEFT JOIN game_tags
    NATURAL LEFT JOIN tags
    NATURAL LEFT JOIN game_langs
    NATURAL LEFT JOIN supp_langs
    NATURAL LEFT JOIN game_audio_langs
    NATURAL LEFT JOIN supp_audio_langs
    NATURAL LEFT JOIN game_developers
    NATURAL LEFT JOIN developers
    NATURAL LEFT JOIN game_publishers
    NATURAL LEFT JOIN publishers
    WHERE game.game_id = game_id
    GROUP BY 
        game.game_id,
        game.game_name,
        game.release_date,
        game.estimated_owners,
        game.price_usd,
        game.about_game,
        game.metacritic_score,
        game.platform_support,
        game.header_iamge;

    SELECT * FROM game_info;
    DROP TEMPORARY TABLE game_info;
END !
DELIMITER ;