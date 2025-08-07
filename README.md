# 📊 YouTube Trending Video Analysis

A project where I analyze YouTube’s trending videos using a fully cloud-based data pipeline — from API to interactive dashboarding.

This project is part of my **Weekly Project Streak**, where I build or improve one project every week until I land a job in data.

---

## Project Goal

The main goal of the project is to create a pipeline and dashboard that:

- Collects trending video data from the YouTube API  
- Processes and stores it using cloud services  
- Visualizes the data through an interactive dashboard  
- (Planned) Allows users to interact with the data via an LLM-powered chatbot  

---

## Work Done So Far

### Data Collection – YouTube Data API

For the first checkpoint of this project, I focused on setting up the full flow — from pulling trending video data to building a working dashboard.

- Set up access to the **YouTube Data API v3**
- Wrote a Python script to fetch trending videos using the [`videos.list`](https://developers.google.com/youtube/v3/docs/videos/list) endpoint  
  - Used `chart=mostPopular` to get top trending videos by region
  - Extracted key fields:
    - `snippet` → title, description, category ID, publish date  
    - `statistics` → view count, like count, comment count  
    - `contentDetails` → video duration, resolution (HD/SD)

- Used the [`videoCategories.list`](https://developers.google.com/youtube/v3/docs/videoCategories/list) endpoint to map category IDs to readable names (e.g. "Music", "Gaming", etc.)
- Ran everything in a Python script inside **Amazon SageMaker Notebook**

---

### Data Transformation & Storage – AWS

- Cleaned and transformed the raw JSON response from the API into a structured tabular format using **Pandas**
- Standardized column names, parsed timestamps, handled missing fields
- Uploaded the transformed datasets as `.parquet` files to an **AWS S3** bucket

---

### Data Modeling – Google BigQuery

- Connected **AWS S3 to Google BigQuery** manually using [BigQuery’s S3 Transfer guide](https://cloud.google.com/bigquery/docs/s3-transfer)  
- Loaded the `.parquet` files into BigQuery tables
- Designed the schema to match the data structure pulled from the API

I went with a **STAR schema** for this project because it’s simple, fast, and works well for dashboarding. I’ll be loading data regularly and analyzing it by dimensions like country, category, and channel — so STAR makes exploration much easier.

**Schema Overview:**

![Star Schema](https://github.com/user-attachments/assets/5d2354d4-6967-438e-97db-d4aec02b8fce)

I initially planned to use **AWS Redshift + QuickSight**, but due to free-tier limits, I switched to **BigQuery + Looker Studio**, which gave me similar functionality and more flexibility within the free tier.

---

### Dashboarding – Looker Studio

Finally, for the dashboard, I used **Looker Studio** and built a basic summary page for now. The dashboard includes:

- Top trending videos by views, likes, and comments  
- Total engagement metrics  
- Category-wise and country-wise breakdowns

The dashboard currently uses data from a single day — but it sets the foundation for future trend analysis, drill-down features, and chatbot interaction.

The dashboard looks like below:

<img width="824" height="502" alt="image" src="https://github.com/user-attachments/assets/8e8657ec-b0bb-4274-8c30-336afb72aaa6" />
