with products as (
    select * from {{ ref('stg_products') }}
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
from products
