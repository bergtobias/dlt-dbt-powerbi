with posts as (
    select * from "analytics"."staging"."stg_posts"
),
users as (
    select * from "analytics"."staging"."stg_users"
),
comment_counts as (
    select
        post_id,
        count(*) as comment_count
    from "analytics"."staging"."stg_comments"
    group by post_id
)
select
    p.post_id,
    p.user_id,
    p.title,
    p.body,
    u.name          as author_name,
    u.username      as author_username,
    u.email         as author_email,
    u.company_name,
    coalesce(c.comment_count, 0) as comment_count
from posts p
left join users u on p.user_id = u.user_id
left join comment_counts c on p.post_id = c.post_id