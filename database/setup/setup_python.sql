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
    header_image VARCHAR(255),
    PRIMARY KEY (game_id, game_name)
);

-- Alter table to support utf8mb4 encoding (for emoji support)
-- database connection must be set to utf8mb4 to support emoji
ALTER TABLE game
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Table containing game videos
CREATE TABLE game_videos (
    game_id INT,
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
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    game_id INT,
    purchase_date DATE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE
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
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
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
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
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
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
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
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (lang_id) REFERENCES supp_langs(lang_id) ON DELETE CASCADE
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
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (audio_lang_id) REFERENCES supp_audio_langs(audio_lang_id)
    ON DELETE CASCADE
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
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (dev_id) REFERENCES developers(dev_id) ON DELETE CASCADE
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
    FOREIGN KEY (game_id) REFERENCES game(game_id) ON DELETE CASCADE,
    FOREIGN KEY (pub_id) REFERENCES publishers(pub_id) ON DELETE CASCADE
);

-- Drop Procedures and Functions if they exist
DROP FUNCTION IF EXISTS make_salt;
DROP FUNCTION IF EXISTS authenticate;
DROP PROCEDURE IF EXISTS sp_add_user;
DROP PROCEDURE IF EXISTS sp_change_password;

-- Generate a random salt for the user

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
END;

-- Procedure to add a new user to the user table

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
END;

-- Procedure to delete a user from the user table
DROP PROCEDURE IF EXISTS sp_delete_user;

CREATE PROCEDURE sp_delete_user(
    username VARCHAR(20), user_role VARCHAR(20))
BEGIN
    IF user_role = 'admin' THEN
        DELETE FROM user WHERE user.username = username;
    END IF;
END;

-- Procedure to update a user's role
DROP PROCEDURE IF EXISTS sp_update_user_role;

CREATE PROCEDURE sp_update_user_role(
    username VARCHAR(20), new_role VARCHAR(20))
BEGIN
    UPDATE user
    SET user_role = new_role
    WHERE user.username = username;
END;

-- Procedure to authenticate a user

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
END;

-- Procedure to change a user's password

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
END;

-- Add admin user
CALL sp_add_user('admin', 'admin', 'admin');

-- Function to check if game purchased by user
DROP FUNCTION IF EXISTS has_purchased;

CREATE FUNCTION has_purchased(user_id INT, game_id INT)
RETURNS TINYINT
BEGIN
    DECLARE purchased TINYINT;

    SELECT COUNT(*) INTO purchased
    FROM purchases
    WHERE purchases.user_id = user_id AND purchases.game_id = game_id;

    RETURN purchased;
END;

-- Procedure to get all information about a game
DROP PROCEDURE IF EXISTS sp_get_game_info;

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
        game.header_image,
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
        game.header_image;

    SELECT * FROM game_info;
    DROP TEMPORARY TABLE game_info;
END;

-- trigger to update the balance of the user after a purchase
DROP TRIGGER IF EXISTS update_balance;

CREATE TRIGGER update_balance
AFTER INSERT ON purchases
FOR EACH ROW
BEGIN
    UPDATE user
    SET balance = balance - (SELECT price_usd FROM game WHERE game_id = NEW.game_id)
    WHERE user_id = NEW.user_id;
END;

-- ufd to verify if a user has enough balance to make a purchase
DROP FUNCTION IF EXISTS has_enough_balance;

CREATE FUNCTION has_enough_balance(user_id INT, game_id INT)
RETURNS TINYINT
BEGIN
    DECLARE game_price DECIMAL(10, 2);
    DECLARE user_balance DECIMAL(10, 2);

    SELECT price_usd INTO game_price FROM game WHERE game.game_id = game_id;
    SELECT balance INTO user_balance FROM user WHERE user.user_id = user_id;

    IF user_balance >= game_price THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;

-- procedure to make a purchase
DROP PROCEDURE IF EXISTS sp_make_purchase;

CREATE PROCEDURE sp_make_purchase(user_id INT, game_id INT)
BEGIN
    IF has_enough_balance(user_id, game_id) AND NOT has_purchased(user_id, game_id) THEN
        INSERT INTO purchases (user_id, game_id, purchase_date)
        VALUES (user_id, game_id, CURDATE());
    END IF;
END;

-- header_image index
CREATE INDEX header_image_index ON game(header_image);

-- view that contains all attributes
DROP VIEW IF EXISTS attributes_view;

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

-- procedure to get games by all attributes
DROP PROCEDURE IF EXISTS sp_get_games_by_all_limit;

CREATE PROCEDURE sp_get_games_by_all_limit(
    IN category_ids VARCHAR(255), 
    IN genre_ids VARCHAR(255),
    IN tag_ids VARCHAR(255),
    IN lang_ids VARCHAR(255),
    IN audio_lang_ids VARCHAR(255),
    IN dev_ids VARCHAR(255),
    IN pub_ids VARCHAR(255),
    IN limit_num INT,
    IN offset_num INT
)

BEGIN
    DECLARE category_cnt INT DEFAULT 0;
    DECLARE genre_cnt INT DEFAULT 0;
    DECLARE tag_cnt INT DEFAULT 0;
    DECLARE lang_cnt INT DEFAULT 0;
    DECLARE audio_lang_cnt INT DEFAULT 0;
    DECLARE dev_cnt INT DEFAULT 0;
    DECLARE pub_cnt INT DEFAULT 0;

    IF TRIM(category_ids) <> '' THEN
        SET category_cnt = (LENGTH(category_ids) - LENGTH(REPLACE(category_ids, ',', '')) + 1);
    END IF;

    IF TRIM(genre_ids) <> '' THEN
        SET genre_cnt = (LENGTH(genre_ids) - LENGTH(REPLACE(genre_ids, ',', '')) + 1);
    END IF;

    IF TRIM(tag_ids) <> '' THEN
        SET tag_cnt = (LENGTH(tag_ids) - LENGTH(REPLACE(tag_ids, ',', '')) + 1);
    END IF;

    IF TRIM(lang_ids) <> '' THEN
        SET lang_cnt = (LENGTH(lang_ids) - LENGTH(REPLACE(lang_ids, ',', '')) + 1);
    END IF;

    IF TRIM(audio_lang_ids) <> '' THEN
        SET audio_lang_cnt = (LENGTH(audio_lang_ids) - LENGTH(REPLACE(audio_lang_ids, ',', '')) + 1);
    END IF;

    IF TRIM(dev_ids) <> '' THEN
        SET dev_cnt = (LENGTH(dev_ids) - LENGTH(REPLACE(dev_ids, ',', '')) + 1);
    END IF;

    IF TRIM(pub_ids) <> '' THEN
        SET pub_cnt = (LENGTH(pub_ids) - LENGTH(REPLACE(pub_ids, ',', '')) + 1);
    END IF;

    SET @dynamicQuery := 'SELECT g.* FROM game g ';

    IF category_cnt > 0 THEN
        SET @dynamicQuery := CONCAT(@dynamicQuery, 'JOIN (SELECT game_id FROM game_categories WHERE category_id IN (', category_ids, ') GROUP BY game_id HAVING COUNT(DISTINCT category_id) = ', category_cnt, ') gc ON g.game_id = gc.game_id ');
    END IF;

    IF genre_cnt > 0 THEN
        SET @dynamicQuery := CONCAT(@dynamicQuery, 'JOIN (SELECT game_id FROM game_genres WHERE genre_id IN (', genre_ids, ') GROUP BY game_id HAVING COUNT(DISTINCT genre_id) = ', genre_cnt, ') gg ON g.game_id = gg.game_id ');
    END IF;

    IF tag_cnt > 0 THEN
        SET @dynamicQuery := CONCAT(@dynamicQuery, 'JOIN (SELECT game_id FROM game_tags WHERE tag_id IN (', tag_ids, ') GROUP BY game_id HAVING COUNT(DISTINCT tag_id) = ', tag_cnt, ') gt ON g.game_id = gt.game_id ');
    END IF;

    IF lang_cnt > 0 THEN
        SET @dynamicQuery := CONCAT(@dynamicQuery, 'JOIN (SELECT game_id FROM game_langs WHERE lang_id IN (', lang_ids, ') GROUP BY game_id HAVING COUNT(DISTINCT lang_id) = ', lang_cnt, ') gl ON g.game_id = gl.game_id ');
    END IF;

    IF audio_lang_cnt > 0 THEN
        SET @dynamicQuery := CONCAT(@dynamicQuery, 'JOIN (SELECT game_id FROM game_audio_langs WHERE audio_lang_id IN (', audio_lang_ids, ') GROUP BY game_id HAVING COUNT(DISTINCT audio_lang_id) = ', audio_lang_cnt, ') gal ON g.game_id = gal.game_id ');
    END IF;

    IF dev_cnt > 0 THEN
        SET @dynamicQuery := CONCAT(@dynamicQuery, 'JOIN (SELECT game_id FROM game_developers WHERE dev_id IN (', dev_ids, ') GROUP BY game_id HAVING COUNT(DISTINCT dev_id) = ', dev_cnt, ') gd ON g.game_id = gd.game_id ');
    END IF;

    IF pub_cnt > 0 THEN
        SET @dynamicQuery := CONCAT(@dynamicQuery, 'JOIN (SELECT game_id FROM game_publishers WHERE pub_id IN (', pub_ids, ') GROUP BY game_id HAVING COUNT(DISTINCT pub_id) = ', pub_cnt, ') gp ON g.game_id = gp.game_id ');
    END IF;

    IF category_cnt = 0 AND genre_cnt = 0 AND tag_cnt = 0 AND lang_cnt = 0 AND audio_lang_cnt = 0 AND dev_cnt = 0 AND pub_cnt = 0 THEN
        SET @dynamicQuery := CONCAT(@dynamicQuery, 'WHERE 1=1');
    END IF;

    SET @dynamicQuery := CONCAT(@dynamicQuery, ' LIMIT ', limit_num, ' OFFSET ', offset_num);

    PREPARE stmt FROM @dynamicQuery;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;