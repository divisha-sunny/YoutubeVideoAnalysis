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

### Data Pipelining

- Automated the entire pipeline: **Airflow** (for orchestration) → **YouTube API**(Data Source) → **AWS S3**(Raw Data Storage) → **BigQuery**(Data Warehouse) → **dbt** (for data transformations on BigQuery) → **Looker**(Dashboarding).

The dbt data transformations are as follows:

- Cleaned and transformed the raw JSON response from the API into a structured tabular format using SQL.
- Standardized column names, parsed timestamps, handled missing fields
- Uploaded the transformed datasets as `.parquet` files to an **AWS S3** bucket

---

### Dashboarding – Looker Studio

Finally, for the dashboard, I used **Looker Studio** and built a basic summary page for now. The dashboard includes:

- Top trending videos by views, likes, and comments  
- Total engagement metrics  
- Category-wise and country-wise breakdowns

The dashboard currently uses data from a single day — but it sets the foundation for future trend analysis, drill-down features, and chatbot interaction.

The dashboard looks like below:

<img width="828" height="589" alt="image" src="https://github.com/user-attachments/assets/bc0895a5-4066-41ee-9719-61fa45eed4a3" />

