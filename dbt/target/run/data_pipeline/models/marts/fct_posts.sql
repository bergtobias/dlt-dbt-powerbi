
  
    USE [analytics];
    USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "marts"."fct_posts__dbt_tmp__dbt_tmp_vw" as select
    post_id,
    user_id,
    title,
    body,
    author_name,
    author_username,
    company_name,
    comment_count,
    case when comment_count > 0 then 1 else 0 end  as is_commented
from "analytics"."intermediate"."int_posts_enriched";
    ')

EXEC('
            SELECT * INTO "analytics"."marts"."fct_posts__dbt_tmp" FROM "analytics"."marts"."fct_posts__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS marts.fct_posts__dbt_tmp__dbt_tmp_vw')



    
    use [analytics];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'marts_fct_posts__dbt_tmp_cci'
        AND object_id=object_id('marts_fct_posts__dbt_tmp')
    )
    DROP index "marts"."fct_posts__dbt_tmp".marts_fct_posts__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX marts_fct_posts__dbt_tmp_cci
    ON "marts"."fct_posts__dbt_tmp"

   


  