with todos_summary as (
    select
        user_id,
        count(*)                                                as todo_count,
        sum(case when is_completed = 1 then 1 else 0 end)      as completed_todos
    from "analytics"."staging"."stg_todos"
    group by user_id
),
posts_summary as (
    select
        user_id,
        count(*)                                    as post_count,
        sum(comment_count)                          as total_comments_received,
        avg(cast(comment_count as float))           as avg_comments_per_post
    from "analytics"."intermediate"."int_posts_enriched"
    group by user_id
)
select
    u.user_id,
    coalesce(p.post_count, 0)                       as post_count,
    coalesce(p.total_comments_received, 0)          as total_comments_received,
    coalesce(p.avg_comments_per_post, 0.0)          as avg_comments_per_post,
    coalesce(t.todo_count, 0)                       as todo_count,
    coalesce(t.completed_todos, 0)                  as completed_todos,
    case
        when coalesce(t.todo_count, 0) = 0 then 0.0
        else cast(t.completed_todos as float) / t.todo_count
    end                                             as completion_rate
from "analytics"."staging"."stg_users" u
left join posts_summary p on u.user_id = p.user_id
left join todos_summary t on u.user_id = t.user_id