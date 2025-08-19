

  create or replace view `third-flare-425403-c0`.`youtubeDataAnalysis`.`country_wise_summary`
  OPTIONS()
  as -- models/country_trending_summary.sql
-- Description: Generates a high-level country-wise YouTube trending summary

WITH base AS (
    -- Combine videos and categories
    SELECT
        v.*,
        c.category_title,
        CURRENT_DATE() AS trending_date,
        DATE_DIFF(CURRENT_DATE(), DATE(v.publishedAt), DAY) AS video_age_days,
        SAFE_DIVIDE(v.likeCount, NULLIF(v.viewCount, 0)) AS like_ratio
    FROM `third-flare-425403-c0`.`youtubeDataAnalysis`.`src_videos` v
    LEFT JOIN `third-flare-425403-c0`.`youtubeDataAnalysis`.`src_categories` c
        ON v.categoryId = c.category_id
        AND v.country = c.region_name
),

-- 1️⃣ Global top video by views
top_video AS (
    SELECT
        video_title,
        country,
        viewCount
    FROM base
    ORDER BY viewCount DESC
    LIMIT 1
),

-- 2️⃣ Video with highest engagement ratio globally
top_engagement AS (
    SELECT
        video_title,
        country,
        like_ratio
    FROM base
    ORDER BY like_ratio DESC
    LIMIT 1
),

-- 3️⃣ Average likes-to-views ratio per country
country_engagement AS (
    SELECT
        country,
        ROUND(AVG(like_ratio)*100,1) AS avg_like_pct,
        ROUND(AVG(video_age_days),1) AS avg_video_age_days
    FROM base
    GROUP BY country
),

-- 4️⃣ Countries with longest trending videos (average video age)
long_trending AS (
    SELECT
        country,
        ROUND(AVG(video_age_days),1) AS avg_video_age_days
    FROM base
    GROUP BY country
    ORDER BY avg_video_age_days DESC
    LIMIT 2
)

SELECT
    CONCAT(
        'Trending videos today span across ', COUNT(DISTINCT country), ' countries. ',
        'The most-watched video is "', (SELECT video_title FROM top_video), '" from ', 
            (SELECT country FROM top_video), ' with ', 
            FORMAT('%0.1fM', (SELECT viewCount FROM top_video)/1000000), ' views. ',
        'The video with the highest engagement ratio is "', (SELECT video_title FROM top_engagement), '" in ',
            (SELECT country FROM top_engagement), ' with ', 
            ROUND((SELECT like_ratio FROM top_engagement)*100,1), '% likes-to-views. ',
        'Viewer engagement varies across countries. ',
        'Some countries have videos trending for longer periods. ',
        'The countries with the highest average video age are ', 
            (SELECT STRING_AGG(country, ' and ') FROM long_trending), ' with average ages of ', 
            (SELECT STRING_AGG(CAST(avg_video_age_days AS STRING), ' and ') FROM long_trending), ' days.'
    ) AS summary_text
FROM base
LIMIT 1;

