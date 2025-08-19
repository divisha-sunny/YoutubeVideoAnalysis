With raw_categories AS(
    SELECT region_code, region_name,
    SAFE_CAST(category_id AS INT64) AS category_id,
    category_title
    FROM youtubeDataAnalysis.category_data
)
SELECT * FROM raw_categories