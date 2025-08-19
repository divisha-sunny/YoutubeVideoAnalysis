-- models/youtube_summary_story.sql
-- Description: Generates a daily, humanized, story-style summary of trending YouTube videos
-- with formatted numbers (K / M style)

WITH base AS (
    SELECT
        v.*,
        c.category_title,
        CURRENT_DATE() AS trending_date
    FROM {{ ref('src_videos') }} v
    LEFT JOIN {{ ref('src_categories') }} c
        ON v.categoryId = c.category_id
        AND v.country = c.region_name
),

-- Helper formatting function
formatted AS (
    SELECT
        *,
        CASE 
            WHEN viewCount >= 1000000 THEN CONCAT(ROUND(viewCount/1000000,1), 'M')
            WHEN viewCount >= 1000 THEN CONCAT(ROUND(viewCount/1000,1), 'K')
            ELSE CAST(viewCount AS STRING)
        END AS viewCount_fmt,
        CASE 
            WHEN likeCount >= 1000000 THEN CONCAT(ROUND(likeCount/1000000,1), 'M')
            WHEN likeCount >= 1000 THEN CONCAT(ROUND(likeCount/1000,1), 'K')
            ELSE CAST(likeCount AS STRING)
        END AS likeCount_fmt,
        CASE 
            WHEN commentCount >= 1000000 THEN CONCAT(ROUND(commentCount/1000000,1), 'M')
            WHEN commentCount >= 1000 THEN CONCAT(ROUND(commentCount/1000,1), 'K')
            ELSE CAST(commentCount AS STRING)
        END AS commentCount_fmt
    FROM base
),

-- 1️⃣ Top channels by number of trending videos
top_channels AS (
    SELECT
        trending_date,
        ARRAY_AGG(channel_Title ORDER BY cnt DESC LIMIT 2) AS top_channels
    FROM (
        SELECT
            trending_date,
            channel_Title,
            COUNT(video_id) AS cnt
        FROM formatted
        GROUP BY trending_date, channel_Title
    )
    GROUP BY trending_date
),

-- 2️⃣ Top 3 videos by views
top_videos AS (
    SELECT
        trending_date,
        ARRAY_AGG(STRUCT(video_title, channel_Title, viewCount, likeCount, commentCount,
                         viewCount_fmt, likeCount_fmt, commentCount_fmt)
                  ORDER BY viewCount DESC LIMIT 3) AS top_videos
    FROM formatted
    GROUP BY trending_date
),

-- 3️⃣ Category counts and percentages
category_counts AS (
    SELECT
        trending_date,
        category_title,
        COUNT(video_id) AS cnt
    FROM formatted
    GROUP BY trending_date, category_title
),
category_pct AS (
    SELECT
        trending_date,
        ARRAY_AGG(STRUCT(category_title, ROUND(100 * cnt / total_cnt,1) AS pct)) AS category_pct
    FROM (
        SELECT
            trending_date,
            category_title,
            cnt,
            SUM(cnt) OVER(PARTITION BY trending_date) AS total_cnt
        FROM category_counts
    )
    GROUP BY trending_date
),

-- 4️⃣ Total metrics per day
agg AS (
    SELECT
        trending_date,
        COUNT(*) AS total_videos,
        SUM(viewCount) AS total_views,
        SUM(likeCount) AS total_likes,
        SUM(commentCount) AS total_comments
    FROM formatted
    GROUP BY trending_date
)

-- 5️⃣ Combine everything into the story summary
SELECT
    a.trending_date,
    CONCAT(
        'Today, ', a.total_videos, ' videos are trending on YouTube. ',
        'Top channels: ', ARRAY_TO_STRING(b.top_channels, ' and '), '. ',
        'Top 3 videos: ',
        ARRAY_TO_STRING(
            ARRAY(
                SELECT CONCAT('"', video_title, '" by ', channel_Title, 
                              ' (', viewCount_fmt, ' views, ', likeCount_fmt, ' likes, ', commentCount_fmt, ' comments)')
                FROM UNNEST(c.top_videos)
            ), '; '
        ),
        '. Engagement highlight: the top video has a likes-to-views ratio of ', 
        ROUND(c.top_videos[OFFSET(0)].likeCount / NULLIF(c.top_videos[OFFSET(0)].viewCount,0), 2)*100, '%',
        '. Categories leading today: ',
        ARRAY_TO_STRING(
            ARRAY(
                SELECT CONCAT(category_title, ' (', pct, '%)')
                FROM UNNEST(d.category_pct)
                ORDER BY pct DESC
                LIMIT 2
            ), ' and '
        ), '.'
    ) AS summary_text
FROM agg a
LEFT JOIN top_channels b USING (trending_date)
LEFT JOIN top_videos c USING (trending_date)
LEFT JOIN category_pct d USING (trending_date)
ORDER BY a.trending_date DESC