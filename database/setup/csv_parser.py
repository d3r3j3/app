import datetime
import os
import json
import pandas as pd
from pydantic import BaseModel, Field
import unicodedata

class Game:
    def __init__(self, app_id, name):
        self.app_id = app_id
        self.name = name
        self.release_date = None
        self.estimated_owners = None
        self.peak_ccu = None
        self.required_age = None
        self.price = None
        self.dlc_count = None
        self.long_description = None
        self.short_description = None
        self.supported_languages = None
        self.full_audio_languages = None
        self.reviews = None
        self.header_image = None
        self.website = None
        self.support_url = None
        self.support_email = None
        self.support_windows = None
        self.support_mac = None
        self.support_linux = None
        self.metacritic_score = None
        self.metacritic_url = None
        self.user_score = None
        self.positive = None
        self.negative = None
        self.score_rank = None
        self.achievements = None
        self.recommendations = None
        self.notes = None
        self.average_playtime_forever = None
        self.average_playtime_2weeks = None
        self.median_playtime_forever = None
        self.median_playtime_2weeks = None
        self.packages = []
        self.developers = []
        self.publishers = []
        self.categories = []
        self.genres = []
        self.screenshots = []
        self.movies = []
        self.tags = []
    
    def __str__(self):
        return f"Game(app_id={self.app_id}, name={self.name})"
    
    def __repr__(self):
        return self.__str__()
    
    def to_dict(self):
        return {
            "app_id": self.app_id,
            "name": self.name,
            "release_date": self.release_date,
            "estimated_owners": self.estimated_owners,
            "peak_ccu": self.peak_ccu,
            "required_age": self.required_age,
            "price": self.price,
            "dlc_count": self.dlc_count,
            "long_description": self.long_description,
            "short_description": self.short_description,
            "supported_languages": self.supported_languages,
            "full_audio_languages": self.full_audio_languages,
            "reviews": self.reviews,
            "header_image": self.header_image,
            "website": self.website,
            "support_url": self.support_url,
            "support_email": self.support_email,
            "support_windows": self.support_windows,
            "support_mac": self.support_mac,
            "support_linux": self.support_linux,
            "metacritic_score": self.metacritic_score,
            "metacritic_url": self.metacritic_url,
            "user_score": self.user_score,
            "positive": self.positive,
            "negative": self.negative,
            "score_rank": self.score_rank,
            "achievements": self.achievements,
            "recommendations": self.recommendations,
            "notes": self.notes,
            "average_playtime_forever": self.average_playtime_forever,
            "average_playtime_2weeks": self.average_playtime_2weeks,
            "median_playtime_forever": self.median_playtime_forever,
            "median_playtime_2weeks": self.median_playtime_2weeks,
            "packages": self.packages,
            "developers": self.developers,
            "publishers": self.publishers,
            "categories": self.categories,
            "genres": self.genres,
            "screenshots": self.screenshots,
            "movies": self.movies,
            "tags": self.tags
        }
    
    def to_dataframe(self):
        return pd.DataFrame.from_dict(self.to_dict())
    
    def to_json(self):
        return json.dumps(self.to_dict(), indent=4)
    
    def from_dict(self, data):
        self.app_id = data["app_id"]
        self.name = data["name"]
        self.release_date = data["release_date"]
        self.estimated_owners = data["estimated_owners"]
        self.peak_ccu = data["peak_ccu"]
        self.required_age = data["required_age"]
        self.price = data["price"]
        self.dlc_count = data["dlc_count"]
        self.long_description = data["long_description"]
        self.short_description = data["short_description"]
        self.supported_languages = data["supported_languages"]
        self.full_audio_languages = data["full_audio_languages"]
        self.reviews = data["reviews"]
        self.header_image = data["header_image"]
        self.website = data["website"]
        self.support_url = data["support_url"]
        self.support_email = data["support_email"]
        self.support_windows = data["support_windows"]
        self.support_mac = data["support_mac"]
        self.support_linux = data["support_linux"]
        self.metacritic_score = data["metacritic_score"]
        self.metacritic_url = data["metacritic_url"]
        self.user_score = data["user_score"]
        self.positive = data["positive"]
        self.negative = data["negative"]
        self.score_rank = data["score_rank"]
        self.achievements = data["achievements"]
        self.recommendations = data["recommendations"]
        self.notes = data["notes"]
        self.average_playtime_forever = data["average_playtime_forever"]
        self.average_playtime_2weeks = data["average_playtime_2weeks"]
        self.median_playtime_forever = data["median_playtime_forever"]
        self.median_playtime_2weeks = data["median_playtime_2weeks"]
        self.packages = data["packages"]
        self.developers = data["developers"]
        self.publishers = data["publishers"]
        self.categories = data["categories"]
        self.genres = data["genres"]
        self.screenshots = data["screenshots"]
        self.movies = data["movies"]
        self.tags = data["tags"]

    def from_dataframe(self, df):
        self.app_id = df["app_id"]
        self.name = df["name"]
        self.release_date = df["release_date"]
        self.estimated_owners = df["estimated_owners"]
        self.peak_ccu = df["peak_ccu"]
        self.required_age = df["required_age"]
        self.price = df["price"]
        self.dlc_count = df["dlc_count"]
        self.long_description = df["long_description"]
        self.short_description = df["short_description"]
        self.supported_languages = df["supported_languages"]
        self.full_audio_languages = df["full_audio_languages"]
        self.reviews = df["reviews"]
        self.header_image = df["header_image"]
        self.website = df["website"]
        self.support_url = df["support_url"]
        self.support_email = df["support_email"]
        self.support_windows = df["support_windows"]
        self.support_mac = df["support_mac"]
        self.support_linux = df["support_linux"]
        self.metacritic_score = df["metacritic_score"]
        self.metacritic_url = df["metacritic_url"]
        self.user_score = df["user_score"]
        self.positive = df["positive"]
        self.negative = df["negative"]
        self.score_rank = df["score_rank"]
        self.achievements = df["achievements"]
        self.recommendations = df["recommendations"]
        self.notes = df["notes"]
        self.average_playtime_forever = df["average_playtime_forever"]
        self.average_playtime_2weeks = df["average_playtime_2weeks"]
        self.median_playtime_forever = df["median_playtime_forever"]
        self.median_playtime_2weeks = df["median_playtime_2weeks"]
        self.packages = df["packages"]
        self.developers = df["developers"]
        self.publishers = df["publishers"]
        self.categories = df["categories"]
        self.genres = df["genres"]
        self.screenshots = df["scrennshots"]
        self.movies = df["movies"]
        self.tags = df["tags"]

# Load the dataset
def load_dataset():
    games = []
    dataset = {}
    unique_genres = set()
    unique_categories = set()
    unique_tags = set()
    unique_developers = set()
    unique_publishers = set()
    unique_languages = set()
    unique_audio_languages = set()
    unique_game_ids = set()
    unique_game_names = set()
    unique_movie_urls = set()

    if os.path.exists('games.json'):
        with open('games.json', 'r', encoding='utf-8') as fin:
            text = fin.read()
            if len(text) > 0:
                dataset = json.loads(text)

    for app in dataset:
        appID = app                                         # AppID, unique identifier for each app (string).
        game = dataset[app]

        if appID in unique_game_ids:
            continue
        unique_game_ids.add(appID)

        if game['name'] in unique_game_names:
            continue
        unique_game_names.add(game['name'])             

        name = game['name']                                 # Game name (string).
        releaseDate = game['release_date']                  # Release date (string).
        estimatedOwners = game['estimated_owners']          # Estimated owners (string, e.g.: "0 - 20000").
        peakCCU = game['peak_ccu']                          # Number of concurrent users, yesterday (int).
        required_age = game['required_age']                 # Age required to play, 0 if it is for all audiences (int).
        price = game['price']                               # Price in USD, 0.0 if its free (float).
        dlcCount = game['dlc_count']                        # Number of DLCs, 0 if you have none (int).
        longDesc = game['detailed_description']             # Detailed description of the game (string).
        shortDesc = game['short_description']               # Brief description of the game,
                                                            # does not contain HTML tags (string).
        languages = game['supported_languages']             # Comma-separated enumeration of supporting languages.
        fullAudioLanguages = game['full_audio_languages']   # Comma-separated enumeration of languages with audio support.
        reviews = game['reviews']                           #
        headerImage = game['header_image']                  # Header image URL in the store (string).
        website = game['website']                           # Game website (string).
        supportWeb = game['support_url']                    # Game support URL (string).
        supportEmail = game['support_email']                # Game support email (string).
        supportWindows = game['windows']                    # Does it support Windows? (bool).
        supportMac = game['mac']                            # Does it support Mac? (bool).
        supportLinux = game['linux']                        # Does it support Linux? (bool).
        metacriticScore = game['metacritic_score']          # Metacritic score, 0 if it has none (int).
        metacriticURL = game['metacritic_url']              # Metacritic review URL (string).
        userScore = game['user_score']                      # Users score, 0 if it has none (int).
        positive = game['positive']                         # Positive votes (int).
        negative = game['negative']                         # Negative votes (int).
        scoreRank = game['score_rank']                      # Score rank of the game based on user reviews (string).
        achievements = game['achievements']                 # Number of achievements, 0 if it has none (int).
        recs = game['recommendations']                      # User recommendations, 0 if it has none (int).
        notes = game['notes']                               # Extra information about the game content (string).
        averagePlaytime = game['average_playtime_forever']  # Average playtime since March 2009, in minutes (int).
        averageplaytime2W = game['average_playtime_2weeks'] # Average playtime in the last two weeks, in minutes (int).
        medianPlaytime = game['median_playtime_forever']    # Median playtime since March 2009, in minutes (int).
        medianPlaytime2W = game['median_playtime_2weeks']   # Median playtime in the last two weeks, in minutes (int).

        packages = game['packages']                         # Available packages.
        for pack in packages:           
            title = pack['title']                             # Package title (string).
            packDesc = pack['description']                    # Package description (string).

            subs = pack['subs']                               # Subpackages.
            for sub in subs:            
                text = sub['text']                              # Subpackage title (string).
                subDesc = sub['description']                    # Subpackage description (string).
                subPrice = sub['price']                         # Subpackage price in USD (float).

        developers = game['developers']                     # Game developers.
        for developer in developers:            
            developerName = developer                         # Developer name (string).
            developerName = str_accents_to_ascii(developerName)
            unique_developers.add(developerName.lower())

        publishers = game['publishers']                     # Game publishers.
        for publisher in publishers:            
            publisherName = publisher                         # Publisher name (string).
            publisherName = str_accents_to_ascii(publisherName)
            if publisherName.lower() == "":
                continue
            unique_publishers.add(publisherName.lower())

        categories = game['categories']                     # Game categories.
        for category in categories:           
            categoryName = category                           # Category name (string).
            unique_categories.add(categoryName)

        genres = game['genres']                             # Game genres.
        for genre in genres:           
            genreName = genre                                 # Genre name (string).
            unique_genres.add(genreName)

        screenshots = game['screenshots']                   # Game screenshots.
        for screenshot in screenshots:            
            screenshotURL = screenshot                        # Game screenshot URL (string).

        movies = game['movies']                             # Game movies.
        for movie in movies:          
            if movie in unique_movie_urls:
                continue  
            movieURL = movie                                  # Game movie URL (string).
            unique_movie_urls.add(movieURL)

        tags = game['tags']                                 # Tags.
        for tag in tags:           
            tagKey = tag                                      # Tag key (string, int).
            unique_tags.add(tagKey)

        game_obj = Game(appID, name)
        game_dict_obj = {
            "app_id": appID,
            "name": name,
            "release_date": releaseDate,
            "estimated_owners": estimatedOwners,
            "peak_ccu": peakCCU,
            "required_age": required_age,
            "price": price,
            "dlc_count": dlcCount,
            "long_description": longDesc,
            "short_description": shortDesc,
            "supported_languages": languages,
            "full_audio_languages": fullAudioLanguages,
            "reviews": reviews,
            "header_image": headerImage,
            "website": website,
            "support_url": supportWeb,
            "support_email": supportEmail,
            "support_windows": supportWindows,
            "support_mac": supportMac,
            "support_linux": supportLinux,
            "metacritic_score": metacriticScore,
            "metacritic_url": metacriticURL,
            "user_score": userScore,
            "positive": positive,
            "negative": negative,
            "score_rank": scoreRank,
            "achievements": achievements,
            "recommendations": recs,
            "notes": notes,
            "average_playtime_forever": averagePlaytime,
            "average_playtime_2weeks": averageplaytime2W,
            "median_playtime_forever": medianPlaytime,
            "median_playtime_2weeks": medianPlaytime2W,
            "packages": packages,
            "developers": developers,
            "publishers": publishers,
            "categories": categories,
            "genres": genres,
            "screenshots": screenshots,
            "movies": movies,
            "tags": tags
        }

        game_obj.from_dict(game_dict_obj)
        games.append(game_obj)

        for lang in languages:
            l = cleanup_lang(lang)
            unique_languages.add(l)

        for audio_lang in fullAudioLanguages:
            al = cleanup_lang(audio_lang)
            unique_audio_languages.add(al)

    return (
        games,
        unique_genres,
        unique_categories,
        unique_tags,
        unique_developers,
        unique_publishers,
        unique_languages,
        unique_audio_languages
    )

def str_accents_to_ascii(input_str):
    nkfd_form = unicodedata.normalize('NFKD', input_str)
    s = u"".join([c for c in nkfd_form if not unicodedata.combining(c)])
    # remove non-ascii characters
    s = s.encode('ascii', 'ignore').decode('utf-8')
    s = s.strip()

    if s == "":
        return input_str
    
    return s

def create_csv_tables():
    # Load the dataset
    data = load_dataset()
    games = data[0]
    unique_genres = data[1]
    unique_categories = data[2]
    unique_tags = data[3]
    unique_developers = data[4]
    unique_publishers = data[5]
    unique_languages = data[6]
    unique_audio_languages = data[7]

    # Create game table
    game_table = []
    for game in games:
        g = {
            "game_id": game.app_id,
            "game_name": game.name,
            "release_date": convert_date(game.release_date),
            "estimated_owners": game.estimated_owners,
            "price_usd": game.price,
            "about_game": game.long_description,
            "metacritic_score": game.metacritic_score,
            "platform_support": create_platform_support_string(game.support_windows, game.support_mac, game.support_linux),
            "header_image": game.header_image
        }
        
        game_table.append(g)

    # create game csv
    game_df = pd.DataFrame(game_table)
    # split game data in half
    game_df1 = game_df.iloc[:int(len(game_df)/2)]
    game_df2 = game_df.iloc[int(len(game_df)/2):]

    game_df1.to_csv('game1.csv', index=False)
    game_df2.to_csv('game2.csv', index=False)

    # create genre csv
    genre_table = {}
    genre_id = 1
    for genre in unique_genres:
        genre_table[genre] = {
            "genre_id": genre_id,
            "genre": genre
        }
        genre_id += 1

    genre_df = pd.DataFrame(genre_table.values())
    genre_df.to_csv('genre.csv', index=False)

    # create game_genre csv
    game_genre_table = []
    for game in games:
        for genre in game.genres:
            game_genre_table.append({
                "game_id": game.app_id,
                "genre_id": genre_table[genre]["genre_id"]
            })

    game_genre_df = pd.DataFrame(game_genre_table)
    game_genre_df.to_csv('game_genre.csv', index=False)

    # create category csv
    category_table = {}
    category_id = 1
    for category in unique_categories:
        category_table[category] = {
            "category_id": category_id,
            "category": category
        }
        category_id += 1

    category_df = pd.DataFrame(category_table.values())
    category_df.to_csv('category.csv', index=False)

    # create game_category csv
    game_category_table = []
    for game in games:
        for category in game.categories:
            game_category_table.append({
                "game_id": game.app_id,
                "category_id": category_table[category]["category_id"]
            })

    game_category_df = pd.DataFrame(game_category_table)
    game_category_df.to_csv('game_category.csv', index=False)

    # create tag csv
    tag_table = {}
    tag_id = 1
    for tag in unique_tags:
        tag_table[tag] = {
            "tag_id": tag_id,
            "tag": tag
        }
        tag_id += 1

    tag_df = pd.DataFrame(tag_table.values())
    tag_df.to_csv('tag.csv', index=False)

    # create game_tag csv
    game_tag_table = []
    for game in games:
        for tag in game.tags:
            game_tag_table.append({
                "game_id": game.app_id,
                "tag_id": tag_table[tag]["tag_id"]
            })

    game_tag_df = pd.DataFrame(game_tag_table)
    game_tag_df.to_csv('game_tag.csv', index=False)

    # create developer csv
    developer_table = {}
    developer_id = 1
    for developer in unique_developers:
        # if string contains "ubisoft montr" then set to "ubisoft montreal"
        developer_table[developer] = {
            "dev_id": developer_id,
            "dev": developer
        }
        developer_id += 1

    developer_df = pd.DataFrame(developer_table.values())
    developer_df.to_csv('developer.csv', index=False)

    # create game_developer csv
    game_developer_table = []
    for game in games:
        for dev in game.developers:
            d = dev.lower()
            d = str_accents_to_ascii(d).lower()
            game_developer_table.append({
                "game_id": game.app_id,
                "dev_id": developer_table[d]["dev_id"]
            })

    game_developer_df = pd.DataFrame(game_developer_table)
    game_developer_df.to_csv('game_developer.csv', index=False)

    # create publisher csv
    publisher_table = {}
    publisher_id = 1
    for publisher in unique_publishers:
        publisher_table[publisher] = {
            "pub_id": publisher_id,
            "pub": publisher
        }
        publisher_id += 1

    publisher_df = pd.DataFrame(publisher_table.values())   
    publisher_df.to_csv('publisher.csv', index=False)

    # create game_publisher csv
    game_publisher_table = []
    for game in games:
        for pub in game.publishers:
            p = pub.lower()
            p = str_accents_to_ascii(p).lower()

            if p == "":
                continue
            game_publisher_table.append({
                "game_id": game.app_id,
                "pub_id": publisher_table[p]["pub_id"]
            })

    game_publisher_df = pd.DataFrame(game_publisher_table)
    game_publisher_df.to_csv('game_publisher.csv', index=False)

    # create language csv
    language_table = {}
    language_id = 1
    for lang in unique_languages:
        language_table[lang] = {
            "lang_id": language_id,
            "lang": lang
        }
        language_id += 1

    language_df = pd.DataFrame(language_table.values())
    language_df.to_csv('language.csv', index=False)

    # create game_language csv
    game_language_table = []
    for game in games:
        for lang in game.supported_languages:
            game_language_table.append({
                "game_id": game.app_id,
                "lang_id": language_table[cleanup_lang(lang)]["lang_id"]
            })

    game_language_df = pd.DataFrame(game_language_table)
    game_language_df.to_csv('game_language.csv', index=False)

    # create audio_language csv
    audio_language_table = {}
    audio_language_id = 1
    for audio_lang in unique_audio_languages:
        audio_language_table[audio_lang] = {
            "audio_lang_id": audio_language_id,
            "audio_lang": audio_lang
        }
        audio_language_id += 1

    audio_language_df = pd.DataFrame(audio_language_table.values())
    audio_language_df.to_csv('audio_language.csv', index=False)

    # create game_audio_language csv
    game_audio_language_table = []
    for game in games:
        for audio_lang in game.full_audio_languages:
            game_audio_language_table.append({
                "game_id": game.app_id,
                "audio_lang_id": audio_language_table[cleanup_lang(audio_lang)]["audio_lang_id"]
            })

    game_audio_language_df = pd.DataFrame(game_audio_language_table)
    game_audio_language_df.to_csv('game_audio_language.csv', index=False)

    # create game_video csv
    game_video_table = []
    for game in games:
        movie = game.movies[0] if len(game.movies) > 0 else ""
        if movie == "":
            continue
        game_video_table.append({
            "game_id": game.app_id,
            "video_url": movie
        })

    game_video_df = pd.DataFrame(game_video_table)
    game_video_df.to_csv('game_video.csv', index=False)

    return [
        ("game1.csv", "game"),
        ("game2.csv", "game"),
        ("genre.csv", "genres"),
        ("game_genre.csv", "game_genres"),
        ("category.csv", "categories"),
        ("game_category.csv", "game_categories"),
        ("tag.csv", "tags"),
        ("game_tag.csv", "game_tags"),
        ("developer.csv", "developers"),
        ("game_developer.csv", "game_developers"),
        ("publisher.csv", "publishers"),
        ("game_publisher.csv", "game_publishers"),
        ("language.csv", "supp_langs"),
        ("game_language.csv", "game_langs"),
        ("audio_language.csv", "supp_audio_langs"),
        ("game_audio_language.csv", "game_audio_langs"),
        ("game_video.csv", "game_videos")
    ]


def convert_date(date):
    date = date.split(' ')
    month = date[0]
    if len(date) == 2:
        day = "01"
        year = date[1]
    else:
        day = date[1].replace(',', '')
        year = date[2]

    month = month.lower()
    if month == "jan":
        month = "01"
    elif month == "feb":
        month = "02"
    elif month == "mar":
        month = "03"
    elif month == "apr":
        month = "04"
    elif month == "may":
        month = "05"
    elif month == "jun":
        month = "06"
    elif month == "jul":
        month = "07"
    elif month == "aug":
        month = "08"
    elif month == "sep":
        month = "09"
    elif month == "oct":
        month = "10"
    elif month == "nov":
        month = "11"
    elif month == "dec":
        month = "12"

    return datetime.datetime(int(year), int(month), int(day))

def cleanup_lang(lang):
    # remove newline characters
    temp = lang
    lang = lang.replace('\n', '')
    lang = lang.replace('\r', '')
    lang = lang.replace('\t', '')
    lang = lang.strip()
    l = lang.split(' ')[0]
    l = l.split(',')[0]
    l = l.split('[')[0]
    l = l.split('&')[0]

    if l.lower() == "traditional":
        return "chinese"
    elif l.lower() == "simplified":
        return "chinese"
    elif l.lower() == "russianenglishspanish":
        return "czech"
    elif l.lower() == "englishrussianspanish":
        return "czech"
    return l.lower()

def create_platform_support_string(support_windows, support_mac, support_linux):
    # create 3 digit binary string
    support_str = ""
    if support_windows:
        support_str += "1"
    else:
        support_str += "0"

    if support_mac:
        support_str += "1"
    else:
        support_str += "0"

    if support_linux:
        support_str += "1"
    else:
        support_str += "0"

    return support_str

def main():
    create_csv_tables()


if __name__ == "__main__":
    main()