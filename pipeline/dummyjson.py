import dlt
import requests

BASE = "https://dummyjson.com"


@dlt.source(name="dummyjson")
def source():
    return products()


@dlt.resource(write_disposition="replace", primary_key="id")
def products():
    limit = 100
    skip = 0
    while True:
        resp = requests.get(f"{BASE}/products", params={"limit": limit, "skip": skip}).json()
        items = resp.get("products", [])
        if not items:
            break
        for item in items:
            item.pop("reviews", None)
            item.pop("images", None)
            item.pop("meta", None)
            item.pop("dimensions", None)
            item.pop("tags", None)
            yield item
        skip += limit
        if skip >= resp["total"]:
            break
