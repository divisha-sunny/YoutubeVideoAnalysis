-- back compat for old kwarg name
  
  
        
            
                
                
            
                
                
            
                
                
            
        
    

    

    merge into `third-flare-425403-c0`.`youtubeDataAnalysis`.`combined_historical` as DBT_INTERNAL_DEST
        using (

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

        ) as DBT_INTERNAL_SOURCE
        on (
                    DBT_INTERNAL_SOURCE.video_id = DBT_INTERNAL_DEST.video_id
                ) and (
                    DBT_INTERNAL_SOURCE.trending_date = DBT_INTERNAL_DEST.trending_date
                ) and (
                    DBT_INTERNAL_SOURCE.country = DBT_INTERNAL_DEST.country
                )

    
    when matched then update set
        `video_id` = DBT_INTERNAL_SOURCE.`video_id`,`publishedAt` = DBT_INTERNAL_SOURCE.`publishedAt`,`channel_Id` = DBT_INTERNAL_SOURCE.`channel_Id`,`video_title` = DBT_INTERNAL_SOURCE.`video_title`,`channel_Title` = DBT_INTERNAL_SOURCE.`channel_Title`,`categoryId` = DBT_INTERNAL_SOURCE.`categoryId`,`duration_sec` = DBT_INTERNAL_SOURCE.`duration_sec`,`dimension` = DBT_INTERNAL_SOURCE.`dimension`,`definition` = DBT_INTERNAL_SOURCE.`definition`,`caption` = DBT_INTERNAL_SOURCE.`caption`,`licensedContent` = DBT_INTERNAL_SOURCE.`licensedContent`,`madeForKids` = DBT_INTERNAL_SOURCE.`madeForKids`,`viewCount` = DBT_INTERNAL_SOURCE.`viewCount`,`likeCount` = DBT_INTERNAL_SOURCE.`likeCount`,`commentCount` = DBT_INTERNAL_SOURCE.`commentCount`,`country` = DBT_INTERNAL_SOURCE.`country`,`category_title` = DBT_INTERNAL_SOURCE.`category_title`,`trending_date` = DBT_INTERNAL_SOURCE.`trending_date`
    

    when not matched then insert
        (`video_id`, `publishedAt`, `channel_Id`, `video_title`, `channel_Title`, `categoryId`, `duration_sec`, `dimension`, `definition`, `caption`, `licensedContent`, `madeForKids`, `viewCount`, `likeCount`, `commentCount`, `country`, `category_title`, `trending_date`)
    values
        (`video_id`, `publishedAt`, `channel_Id`, `video_title`, `channel_Title`, `categoryId`, `duration_sec`, `dimension`, `definition`, `caption`, `licensedContent`, `madeForKids`, `viewCount`, `likeCount`, `commentCount`, `country`, `category_title`, `trending_date`)


    