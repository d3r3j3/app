-- Load data into games database

-- Load games into game table
LOAD DATA LOCAL INFILE 'game1.csv' INTO TABLE game
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'game2.csv' INTO TABLE game
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load genres into genres table
LOAD DATA LOCAL INFILE 'genre.csv' INTO TABLE genres
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load game_genres into game_genres table
LOAD DATA LOCAL INFILE 'game_genre.csv' INTO TABLE game_genres
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load categories into categories table
LOAD DATA LOCAL INFILE 'category.csv' INTO TABLE categories
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load game_categories into game_categories table
LOAD DATA LOCAL INFILE 'game_category.csv' INTO TABLE game_categories
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load tags into tags table
LOAD DATA LOCAL INFILE 'tag.csv' INTO TABLE tags
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load game_tags into game_tags table
LOAD DATA LOCAL INFILE 'game_tag.csv' INTO TABLE game_tags
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load developers into developers table
LOAD DATA LOCAL INFILE 'developer.csv' INTO TABLE developers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load game_developers into game_developers table
LOAD DATA LOCAL INFILE 'game_developer.csv' INTO TABLE game_developers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load publishers into publishers table
LOAD DATA LOCAL INFILE 'publisher.csv' INTO TABLE publishers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load game_publishers into game_publishers table
LOAD DATA LOCAL INFILE 'game_publisher.csv' INTO TABLE game_publishers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load supp_langs into supp_langs table
LOAD DATA LOCAL INFILE 'language.csv' INTO TABLE supp_langs
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load game_langs into game_langs table
LOAD DATA LOCAL INFILE 'game_language.csv' INTO TABLE game_langs
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load supp_audio_langs into supp_audio_langs table
LOAD DATA LOCAL INFILE 'audio_language.csv' INTO TABLE supp_audio_langs
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load game_audio_langs into game_audio_langs table
LOAD DATA LOCAL INFILE 'game_audio_language.csv' INTO TABLE game_audio_langs
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Load game_videos into game_videos table
LOAD DATA LOCAL INFILE 'game_video.csv' INTO TABLE game_videos
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;