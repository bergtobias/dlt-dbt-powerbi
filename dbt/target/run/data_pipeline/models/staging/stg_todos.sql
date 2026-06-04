USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "staging"."stg_todos__dbt_tmp" as select
    id                          as todo_id,
    user_id,
    title,
    cast(completed as bit)      as is_completed
from "analytics"."raw"."todos";
    ')

