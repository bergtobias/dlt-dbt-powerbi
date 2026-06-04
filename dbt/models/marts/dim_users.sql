select
    user_id,
    name,
    username,
    email,
    phone,
    website,
    city,
    zipcode,
    company_name
from {{ ref('stg_users') }}
