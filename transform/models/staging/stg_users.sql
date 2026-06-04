select
    id                  as user_id,
    name,
    username,
    email,
    phone,
    website,
    address__city       as city,
    address__zipcode    as zipcode,
    company__name       as company_name
from {{ source('raw', 'users') }}
