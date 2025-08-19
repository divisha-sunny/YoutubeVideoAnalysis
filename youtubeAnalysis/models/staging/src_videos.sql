WITH raw_videos AS (
    SELECT
    video_id,
    -- Convert publishedAt to TIMESTAMP
    SAFE_CAST(publishedAt AS TIMESTAMP) AS publishedAt,
    COALESCE(channel_Id, 'Not Given') AS channel_Id,
    COALESCE(video_title, 'Not Given') AS video_title,
    COALESCE(channel_Title, 'Not Given') AS channel_Title,
    -- Convert categoryId to INT64
    SAFE_CAST(categoryId AS INT64) AS categoryId,
    -- Convert ISO 8601 duration (e.g., PT2M3S) to seconds
    (
        COALESCE(SAFE_CAST(REGEXP_EXTRACT(duration, r'PT(\d+)H') AS INT64), 0) * 3600 +
        COALESCE(SAFE_CAST(REGEXP_EXTRACT(duration, r'PT(?:\d+H)?(\d+)M') AS INT64), 0) * 60 +
        COALESCE(SAFE_CAST(REGEXP_EXTRACT(duration, r'PT(?:\d+H)?(?:\d+M)?(\d+)S') AS INT64), 0)
        ) AS duration_sec,
    COALESCE(dimension, 'Not Given') AS dimension,
    COALESCE(definition, 'Not Given') AS definition,
    -- Convert caption to BOOLEAN
    CASE
    WHEN LOWER(caption) = 'true' THEN TRUE
    WHEN LOWER(caption) = 'false' THEN FALSE
    ELSE NULL
    END AS caption,
    licensedContent,
    madeForKids,
    -- Convert viewCount, likeCount, commentCount to INT64
    SAFE_CAST(viewCount AS INT64) AS viewCount,
    SAFE_CAST(likeCount AS INT64) AS likeCount,
    SAFE_CAST(commentCount AS INT64) AS commentCount,
    COALESCE(country, 'Not Given') AS country
FROM
    `youtubeDataAnalysis.video_data`
)
SELECT * FROM raw_videos
