with source as (
    select * from "analytics"."dummyjson"."products"
),

renamed as (
    select
        id                                          as product_id,
        title,
        category,
        brand,
        price,
        discount_percentage,
        round(price * (1 - discount_percentage / 100), 2) as discounted_price,
        rating,
        stock,
        availability_status,
        sku,
        minimum_order_quantity,
        return_policy,
        shipping_information,
        warranty_information
    from source
)

select * from renamed
where brand is not null and trim(brand) != ''