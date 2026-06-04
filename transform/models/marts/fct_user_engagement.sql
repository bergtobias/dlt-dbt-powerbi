select
    a.user_id,
    u.name,
    u.username,
    u.company_name,
    u.city,
    a.post_count,
    a.total_comments_received,
    a.avg_comments_per_post,
    a.todo_count,
    a.completed_todos,
    a.completion_rate
from {{ ref('int_user_activity') }} a
inner join {{ ref('stg_users') }} u on a.user_id = u.user_id
