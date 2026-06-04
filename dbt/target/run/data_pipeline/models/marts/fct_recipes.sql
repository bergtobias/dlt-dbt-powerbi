
  
    USE [analytics];
    USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "marts"."fct_recipes__dbt_tmp__dbt_tmp_vw" as with source as (
    select * from "analytics"."dummyjson"."recipes"
)

select
    id                                          as recipe_id,
    name,
    cuisine,
    difficulty,
    meal_type,
    prep_time_minutes,
    cook_time_minutes,
    total_time_minutes,
    servings,
    calories_per_serving,
    rating,
    review_count,
    calories_per_serving * servings             as total_calories
from source;
    ')

EXEC('
            SELECT * INTO "analytics"."marts"."fct_recipes__dbt_tmp" FROM "analytics"."marts"."fct_recipes__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS marts.fct_recipes__dbt_tmp__dbt_tmp_vw')



    
    use [analytics];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'marts_fct_recipes__dbt_tmp_cci'
        AND object_id=object_id('marts_fct_recipes__dbt_tmp')
    )
    DROP index "marts"."fct_recipes__dbt_tmp".marts_fct_recipes__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX marts_fct_recipes__dbt_tmp_cci
    ON "marts"."fct_recipes__dbt_tmp"

   


  