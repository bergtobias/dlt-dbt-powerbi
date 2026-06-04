
  
    USE [analytics];
    USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "marts"."dim_users__dbt_tmp__dbt_tmp_vw" as select
    user_id,
    name,
    username,
    email,
    phone,
    website,
    city,
    zipcode,
    company_name
from "analytics"."staging"."stg_users";
    ')

EXEC('
            SELECT * INTO "analytics"."marts"."dim_users__dbt_tmp" FROM "analytics"."marts"."dim_users__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS marts.dim_users__dbt_tmp__dbt_tmp_vw')



    
    use [analytics];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'marts_dim_users__dbt_tmp_cci'
        AND object_id=object_id('marts_dim_users__dbt_tmp')
    )
    DROP index "marts"."dim_users__dbt_tmp".marts_dim_users__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX marts_dim_users__dbt_tmp_cci
    ON "marts"."dim_users__dbt_tmp"

   


  