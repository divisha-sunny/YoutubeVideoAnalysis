import pandas as pd
from datetime import datetime
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import gcsfs
import time


# -----------------------------
# 1. Set up YouTube client
# -----------------------------
API_KEY = "Your Key"
youtube = build("youtube", "v3", developerKey=API_KEY)

# -----------------------------
# 2. Hardcode GCS credentials
# -----------------------------
GCS_PROJECT = "third-flare-425403-c0"
GCS_BUCKET = "youtube-video-data-analysis"
GCS_CREDENTIALS_JSON = "Keys/GCP_Key.json"  # replace with your service account file

fs = gcsfs.GCSFileSystem(project=GCS_PROJECT, token=GCS_CREDENTIALS_JSON)

# -----------------------------
# 3. Get supported countries
# -----------------------------
def get_supported_countries(youtube):
    i18n_response = youtube.i18nRegions().list(part='snippet').execute()
    countries = {}
    for item in i18n_response.get('items', []):
        region_code = item['id']
        region_name = item['snippet']['name']
        countries[region_code] = region_name
    return countries

countries = get_supported_countries(youtube)

# -----------------------------
# 4. Extract video data
# -----------------------------
video_data = []

for code, name in countries.items():
    videos_response = youtube.videos().list(
        part='snippet,contentDetails,status,statistics',
        chart='mostPopular',
        maxResults=50,
        regionCode=code
    ).execute()

    for item in videos_response.get('items', []):
        snippet = item.get('snippet', {})
        content = item.get('contentDetails', {})
        status = item.get('status', {})
        stats = item.get('statistics', {})

        video_info = {
            'video_id': item.get('id'),
            'publishedAt': snippet.get('publishedAt'),
            'channel_Id': snippet.get('channelId'),
            'video_title': snippet.get('title'),
            'channel_Title': snippet.get('channelTitle'),
            'categoryId': snippet.get('categoryId'),
            'defaultLanguage': snippet.get('defaultLanguage'),
            'duration': content.get('duration'),
            'dimension': content.get('dimension'),
            'definition': content.get('definition'),
            'caption': content.get('caption'),
            'licensedContent': content.get('licensedContent'),
            'madeForKids': status.get('madeForKids'),
            'viewCount': stats.get('viewCount'),
            'likeCount': stats.get('likeCount'),
            'commentCount': stats.get('commentCount'),
            'country': name
        }

        video_data.append(video_info)

df = pd.DataFrame(video_data)

# -----------------------------
# 5. Get all categories
# -----------------------------
def get_all_video_categories(youtube, countries):
    all_categories = []

    for region_code in countries.keys():
        try:
            response = youtube.videoCategories().list(
                part="snippet",
                regionCode=region_code
            ).execute()

            for item in response.get('items', []):
                if item['snippet'].get('assignable', False):
                    all_categories.append({
                        'region_code': region_code,
                        'region_name': countries[region_code],
                        'category_id': item['id'],
                        'category_title': item['snippet']['title']
                    })

            time.sleep(0.1)

        except HttpError as e:
            print(f"Error fetching categories for region {region_code}: {e}")
            continue

    return pd.DataFrame(all_categories)

category_df = get_all_video_categories(youtube, countries)

# -----------------------------
# 6. Save to GCS
# -----------------------------
df.to_parquet(
    f"gs://{GCS_BUCKET}/processed_data/videos.parquet",
    index=False,
    storage_options={"project": GCS_PROJECT, "token": GCS_CREDENTIALS_JSON}
)

category_df.to_parquet(
    f"gs://{GCS_BUCKET}/processed_data/categories.parquet",
    index=False,
    storage_options={"project": GCS_PROJECT, "token": GCS_CREDENTIALS_JSON}
)
