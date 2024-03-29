-- Includes all SELECT queries used for the entire project

-- Counts the total purchases made.
SELECT COUNT(*) AS purchase_cnt
    FROM purchases
    WHERE user_id = user_id AND game_id = game_id;

-- Retrieves the price in USD of a specific game by its game_id.
SELECT price_usd FROM game WHERE game_id = 10;

-- Retrieves the current balance of a specific user by their user_id.
SELECT balance FROM user WHERE user_id = 5;

-- Retrieves comprehensive details of a specific game, including videos, 
-- categories, genres, tags, supported languages, audio languages, developers, 
-- and publishers, grouped and concatenated into respective fields.
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
    WHERE game.game_id = 20
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

-- Selects game IDs from the game_categories table where the category ID 
-- matches any within the specified list, grouping results by game ID.
SELECT game_id FROM game_categories 
                WHERE category_id IN ('23') 
                GROUP BY game_id;

-- Retrieves the first 10 records from the game table, starting from the 
-- beginning.
SELECT * FROM game LIMIT 10 OFFSET 0;

-- Retrieves all details for the user with a user_id that matches 5 
SELECT * FROM user WHERE user_id = 5;

-- Retrieves all details for the user with the username 'user1'.
SELECT * FROM user WHERE username = 'user1';

-- Retrieves the first 10 records from the user table, starting from the 
-- beginning.
SELECT * FROM user LIMIT 10 OFFSET 0;

-- Retrieves the first 10 records from the purchases table, starting from the 
-- beginning.
SELECT * FROM purchases LIMIT 10 OFFSET 0;

-- Retrieves the first 10 purchase records for the user with a user_id of 5, 
-- starting from the beginning.
SELECT * FROM purchases WHERE user_id = 5 LIMIT 10 OFFSET 0;

-- Retrieves the first 10 purchase records for the game with a game_id of 20200,
-- starting from the beginning.
SELECT * FROM purchases WHERE game_id = 20200 LIMIT 10 OFFSET 0;

-- Retrieves the first 10 purchase records for user with user_id 5, including 
-- game details like name, release date, price, platform support, metacritic 
-- score, and header image, by joining the purchases and game tables.
SELECT 
    p.purchase_id, 
    p.user_id, 
    p.game_id, 
    p.purchase_date,  
    g.game_name, 
    g.release_date, 
    g.price_usd, 
    g.platform_support, 
    g.metacritic_score, 
    g.header_image
FROM purchases p
JOIN game g
ON p.game_id = g.game_id
WHERE p.user_id = 5
LIMIT 10 OFFSET 0;

-- Retrieves all records from the attributes_view, which consolidates 
-- various attribute types like categories, genres, tags, languages, developers,
--  and publishers into a single unified view.
SELECT * FROM attributes_view LIMIT 1000 OFFSET 0;

-- This SQL query retrieves the game name, genre name, and the total number of 
-- purchases for each game, grouped by game and genre. This is used in the 
-- relational algebra portion
SELECT g.game_name, ge.genre_name, COUNT(p.purchase_id) AS total_purchases
FROM purchases p
JOIN game g ON p.game_id = g.game_id
JOIN game_genres gg ON g.game_id = gg.game_id
JOIN genres ge ON gg.genre_id = ge.genre_id
GROUP BY g.game_name, ge.genre_name
ORDER BY ge.genre_name, total_purchases DESC;