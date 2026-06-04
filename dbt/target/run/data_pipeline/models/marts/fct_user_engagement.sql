
  
    USE [analytics];
    USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "marts"."fct_user_engagement__dbt_tmp__dbt_tmp_vw" as select
    a.user_id,
    u.name,
    u.username,
    u.company_name,
    u.city,
    a.post_count,
    a.total_comments_received,
    a.avg_comments_per_post,
    a.todo_count,
    a.completed_todos,
    a.completion_rate
from "analytics"."intermediate"."int_user_activity" a
inner join "analytics"."staging"."stg_users" u on a.user_id = u.user_id;
    ')

EXEC('
            SELECT * INTO "analytics"."marts"."fct_user_engagement__dbt_tmp" FROM "analytics"."marts"."fct_user_engagement__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS marts.fct_user_engagement__dbt_tmp__dbt_tmp_vw')



    
    use [analytics];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'marts_fct_user_engagement__dbt_tmp_cci'
        AND object_id=object_id('marts_fct_user_engagement__dbt_tmp')
    )
    DROP index "marts"."fct_user_engagement__dbt_tmp".marts_fct_user_engagement__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX marts_fct_user_engagement__dbt_tmp_cci
    ON "marts"."fct_user_engagement__dbt_tmp"

   


  