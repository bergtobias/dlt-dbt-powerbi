select
    id                          as todo_id,
    user_id,
    title,
    cast(completed as bit)      as is_completed
from {{ source('raw', 'todos') }}
