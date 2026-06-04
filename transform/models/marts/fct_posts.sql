select
    post_id,
    user_id,
    title,
    body,
    author_name,
    author_username,
    company_name,
    comment_count,
    case when comment_count > 0 then 1 else 0 end  as is_commented
from {{ ref('int_posts_enriched') }}
