USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "staging"."stg_comments__dbt_tmp" as select
    id      as comment_id,
    post_id,
    name    as commenter_name,
    email   as commenter_email,
    body
from "analytics"."raw"."comments";
    ')

