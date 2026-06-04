
  
    USE [analytics];
    USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "marts"."fct_products__dbt_tmp__dbt_tmp_vw" as with products as (
    select * from "analytics"."staging"."stg_products"
)

select
    product_id,
    title,
    category,
    brand,
    price,
    discounted_price,
    discount_percentage,
    rating,
    stock,
    availability_status,
    sku,
    minimum_order_quantity,
    return_policy,
    shipping_information,
    warranty_information
from products;
    ')

EXEC('
            SELECT * INTO "analytics"."marts"."fct_products__dbt_tmp" FROM "analytics"."marts"."fct_products__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS marts.fct_products__dbt_tmp__dbt_tmp_vw')



    
    use [analytics];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'marts_fct_products__dbt_tmp_cci'
        AND object_id=object_id('marts_fct_products__dbt_tmp')
    )
    DROP index "marts"."fct_products__dbt_tmp".marts_fct_products__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX marts_fct_products__dbt_tmp_cci
    ON "marts"."fct_products__dbt_tmp"

   


  