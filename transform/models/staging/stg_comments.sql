select
    id      as comment_id,
    post_id,
    name    as commenter_name,
    email   as commenter_email,
    body
from {{ source('raw', 'comments') }}
