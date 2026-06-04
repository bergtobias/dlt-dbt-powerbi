with source as (
    select * from {{ source('dummyjson', 'recipes') }}
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
from source
