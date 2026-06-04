USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "staging"."stg_users__dbt_tmp" as select
    id                  as user_id,
    name,
    username,
    email,
    phone,
    website,
    address__city       as city,
    address__zipcode    as zipcode,
    company__name       as company_name
from "analytics"."raw"."users";
    ')

