

SELECT
    v.*,
    c.category_title,
    CURRENT_DATE() AS trending_date
FROM `third-flare-425403-c0`.`youtubeDataAnalysis`.`src_videos` v
LEFT JOIN `third-flare-425403-c0`.`youtubeDataAnalysis`.`src_categories` c
    ON v.categoryId = c.category_id
    AND v.country = c.region_name


-- Only insert rows that don't exist yet in the historical table
WHERE (video_id, trending_date, country) 
      NOT IN (SELECT video_id, trending_date, country FROM `third-flare-425403-c0`.`youtubeDataAnalysis`.`combined_historical`)
