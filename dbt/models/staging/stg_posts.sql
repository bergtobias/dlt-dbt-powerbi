select
    id      as post_id,
    user_id,
    title,
    body
from {{ source('raw', 'posts') }}
