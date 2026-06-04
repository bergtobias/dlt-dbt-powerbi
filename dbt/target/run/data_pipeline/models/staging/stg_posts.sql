USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "staging"."stg_posts__dbt_tmp" as select
    id      as post_id,
    user_id,
    title,
    body
from "analytics"."raw"."posts";
    ')

