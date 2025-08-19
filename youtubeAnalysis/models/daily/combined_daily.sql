SELECT
    v.*,
    c.category_title,
    CURRENT_DATE() AS trending_date
FROM {{ ref('src_videos') }} v
LEFT JOIN {{ ref('src_categories') }} c
    ON v.categoryId = c.category_id
    AND v.country = c.region_name