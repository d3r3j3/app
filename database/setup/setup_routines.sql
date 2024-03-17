-- Procedures, functions, and triggers for the database setup

-- Functiions

-- Drop existing functions
DROP FUNCTION IF EXISTS has_purchased;
DROP FUNCTION IF EXISTS has_enough_balance;

-- Function to check if a user has purchased a game
DELIMITER !

CREATE FUNCTION has_purchased(user_id INT, game_id INT)
RETURNS TINYINT
BEGIN
    DECLARE purchased TINYINT;

    SELECT COUNT(*) INTO purchased
    FROM purchases
    WHERE purchases.user_id = user_id AND purchases.game_id = game_id;

    RETURN purchased;
END !

DELIMITER ;

-- ufd to verify if a user has enough balance to make a purchase

DELIMITER !

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
END !

DELIMITER ;

-- Triggers

-- Drop existing triggers
DROP TRIGGER IF EXISTS update_balance;

-- trigger to update the balance of the user after a purchase

DELIMITER !

CREATE TRIGGER update_balance
AFTER INSERT ON purchases
FOR EACH ROW
BEGIN
    UPDATE user
    SET balance = balance - (
        SELECT price_usd FROM game WHERE game_id = NEW.game_id)
    WHERE user_id = NEW.user_id;
END !

DELIMITER ;

-- Procedures

-- Drop existing procedures
DROP PROCEDURE IF EXISTS sp_get_game_info;
DROP PROCEDURE IF EXISTS sp_make_purchase;
DROP PROCEDURE IF EXISTS sp_get_games_by_all_limit;

-- Procedure to get all information about a game
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
        game.header_image,
        GROUP_CONCAT(DISTINCT game_videos.video_url) AS video_urls,
        GROUP_CONCAT(DISTINCT categories.category_name) AS categories,
        GROUP_CONCAT(DISTINCT genres.genre_name) AS genres,
        GROUP_CONCAT(DISTINCT tags.tag_name) AS tags,
        GROUP_CONCAT(DISTINCT supp_langs.lang) AS supp_langs,
        GROUP_CONCAT(DISTINCT supp_audio_langs.audio_lang) AS supp_audio_langs,
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
END !

DELIMITER ;

-- procedure to make a purchase

DELIMITER !

CREATE PROCEDURE sp_make_purchase(user_id INT, game_id INT)
BEGIN
    IF 
        has_enough_balance(user_id, game_id) AND NOT 
        has_purchased(user_id, game_id) 
    THEN
        INSERT INTO purchases (user_id, game_id, purchase_date)
        VALUES (user_id, game_id, CURDATE());
    END IF;
END !

DELIMITER ;

-- Procedure to get games by all filters with limit and offset

DELIMITER !

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
        SET category_cnt = (
            LENGTH(category_ids) - 
            LENGTH(REPLACE(category_ids, ',', '')) + 1);
    END IF;

    IF TRIM(genre_ids) <> '' THEN
        SET genre_cnt = (
            LENGTH(genre_ids) - 
            LENGTH(REPLACE(genre_ids, ',', '')) + 1);
    END IF;

    IF TRIM(tag_ids) <> '' THEN
        SET tag_cnt = (
            LENGTH(tag_ids) - 
            LENGTH(REPLACE(tag_ids, ',', '')) + 1);
    END IF;

    IF TRIM(lang_ids) <> '' THEN
        SET lang_cnt = (
            LENGTH(lang_ids) - 
            LENGTH(REPLACE(lang_ids, ',', '')) + 1);
    END IF;

    IF TRIM(audio_lang_ids) <> '' THEN
        SET audio_lang_cnt = (
            LENGTH(audio_lang_ids) - 
            LENGTH(REPLACE(audio_lang_ids, ',', '')) + 1);
    END IF;

    IF TRIM(dev_ids) <> '' THEN
        SET dev_cnt = (
            LENGTH(dev_ids) - 
            LENGTH(REPLACE(dev_ids, ',', '')) + 1);
    END IF;

    IF TRIM(pub_ids) <> '' THEN
        SET pub_cnt = (
            LENGTH(pub_ids) - 
            LENGTH(REPLACE(pub_ids, ',', '')) + 1);
    END IF;

    SET @dq := 'SELECT g.* FROM game g ';

    IF category_cnt > 0 THEN
        SET @dq := CONCAT(
            @dq, 
            'JOIN (
                SELECT game_id FROM game_categories 
                WHERE category_id IN (', category_ids, ') 
                GROUP BY game_id 
                HAVING COUNT(DISTINCT category_id) = ', category_cnt, '
            ) gc ON g.game_id = gc.game_id ');
    END IF;

    IF genre_cnt > 0 THEN
        SET @dq := CONCAT(
            @dq, 
            'JOIN (
                SELECT game_id FROM game_genres 
                WHERE genre_id IN (', genre_ids, ') 
                GROUP BY game_id 
                HAVING COUNT(DISTINCT genre_id) = ', genre_cnt, '
            ) gg ON g.game_id = gg.game_id ');
    END IF;

    IF tag_cnt > 0 THEN
        SET @dq := CONCAT(
            @dq, 
            'JOIN (
                SELECT game_id FROM game_tags 
                WHERE tag_id IN (', tag_ids, ') 
                GROUP BY game_id 
                HAVING COUNT(DISTINCT tag_id) = ', tag_cnt, '
            ) gt ON g.game_id = gt.game_id ');
    END IF;

    IF lang_cnt > 0 THEN
        SET @dq := CONCAT(
            @dq, 
            'JOIN (
                SELECT game_id FROM game_langs 
                WHERE lang_id IN (', lang_ids, ') 
                GROUP BY game_id 
                HAVING COUNT(DISTINCT lang_id) = ', lang_cnt, '
            ) gl ON g.game_id = gl.game_id ');
    END IF;

    IF audio_lang_cnt > 0 THEN
        SET @dq := CONCAT(
            @dq, 
            'JOIN (
                SELECT game_id FROM game_audio_langs 
                WHERE audio_lang_id IN (', audio_lang_ids, ') 
                GROUP BY game_id 
                HAVING 
                COUNT(DISTINCT audio_lang_id) = ', audio_lang_cnt, '
            ) gal ON g.game_id = gal.game_id ');
    END IF;

    IF dev_cnt > 0 THEN
        SET @dq := CONCAT(
            @dq, 
            'JOIN (
                SELECT game_id FROM game_developers 
                WHERE dev_id IN (', dev_ids, ') 
                GROUP BY game_id 
                HAVING COUNT(DISTINCT dev_id) = ', dev_cnt, '
            ) gd ON g.game_id = gd.game_id ');
    END IF;

    IF pub_cnt > 0 THEN
        SET @dq := CONCAT(
            @dq, 
            'JOIN (
                SELECT game_id FROM game_publishers 
                WHERE pub_id IN (', pub_ids, ') 
                GROUP BY game_id 
                HAVING COUNT(DISTINCT pub_id) = ', pub_cnt, '
            ) gp ON g.game_id = gp.game_id ');
    END IF;

    IF 
        category_cnt = 0 
        AND genre_cnt = 0 
        AND tag_cnt = 0 
        AND lang_cnt = 0 
        AND audio_lang_cnt = 0 
        AND dev_cnt = 0 
        AND pub_cnt = 0 
    THEN
        SET @dq := CONCAT(@dq, 'WHERE 1=1');
    END IF;

    SET @dq := CONCAT(
        @dq, ' LIMIT ', limit_num, ' OFFSET ', offset_num);

    PREPARE stmt FROM @dq;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END !

DELIMITER ;