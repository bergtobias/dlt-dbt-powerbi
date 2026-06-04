
  
    USE [analytics];
    USE [analytics];
    
    

    

    
    USE [analytics];
    EXEC('
        create view "marts"."fct_user_activity__dbt_tmp__dbt_tmp_vw" as -- Cross-analysis: user engagement across posts, todos, and cart spend
with users as (
    select * from "analytics"."dummyjson"."users"
),

posts as (
    select
        user_id,
        count(*)        as post_count,
        sum(views)      as total_views,
        sum(likes)      as total_likes,
        sum(dislikes)   as total_dislikes
    from "analytics"."dummyjson"."posts"
    group by user_id
),

todos as (
    select
        user_id,
        count(*)                                        as todo_count,
        sum(case when completed = 1 then 1 else 0 end) as completed_todos
    from "analytics"."dummyjson"."dj_todos"
    group by user_id
),

carts as (
    select
        user_id,
        count(distinct id)  as cart_count,
        sum(total)          as total_spend,
        sum(discounted_total) as discounted_spend,
        sum(total_quantity) as items_bought
    from "analytics"."dummyjson"."carts"
    group by user_id
)

select
    u.id                                                        as user_id,
    u.first_name + '' '' + u.last_name                           as full_name,
    u.age,
    u.gender,
    u.city,
    u.country,
    u.company,
    u.department,

    coalesce(p.post_count, 0)                                   as post_count,
    coalesce(p.total_views, 0)                                  as total_views,
    coalesce(p.total_likes, 0)                                  as total_likes,

    coalesce(t.todo_count, 0)                                   as todo_count,
    coalesce(t.completed_todos, 0)                              as completed_todos,
    case
        when coalesce(t.todo_count, 0) = 0 then null
        else round(cast(t.completed_todos as float) / t.todo_count * 100, 1)
    end                                                         as completion_rate_pct,

    coalesce(c.cart_count, 0)                                   as cart_count,
    coalesce(c.total_spend, 0)                                  as total_spend,
    coalesce(c.discounted_spend, 0)                             as discounted_spend,
    coalesce(c.items_bought, 0)                                 as items_bought

from users u
left join posts  p on p.user_id  = u.id
left join todos  t on t.user_id  = u.id
left join carts  c on c.user_id  = u.id;
    ')

EXEC('
            SELECT * INTO "analytics"."marts"."fct_user_activity__dbt_tmp" FROM "analytics"."marts"."fct_user_activity__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS marts.fct_user_activity__dbt_tmp__dbt_tmp_vw')



    
    use [analytics];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'marts_fct_user_activity__dbt_tmp_cci'
        AND object_id=object_id('marts_fct_user_activity__dbt_tmp')
    )
    DROP index "marts"."fct_user_activity__dbt_tmp".marts_fct_user_activity__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX marts_fct_user_activity__dbt_tmp_cci
    ON "marts"."fct_user_activity__dbt_tmp"

   


  