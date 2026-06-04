import dlt
import requests

BASE = "https://dummyjson.com"


def _paginate(endpoint, key, limit=100, strip_keys=None):
    skip = 0
    while True:
        resp = requests.get(f"{BASE}/{endpoint}", params={"limit": limit, "skip": skip}).json()
        items = resp.get(key, [])
        if not items:
            break
        for item in items:
            for k in (strip_keys or []):
                item.pop(k, None)
            yield item
        skip += limit
        if skip >= resp["total"]:
            break


@dlt.source(name="dummyjson")
def source():
    return products(), users(), carts(), cart_items(), posts(), dj_todos(), recipes()


@dlt.resource(write_disposition="replace", primary_key="id")
def products():
    yield from _paginate("products", "products",
                         strip_keys=["reviews", "images", "meta", "dimensions", "tags"])


@dlt.resource(write_disposition="replace", primary_key="id")
def users():
    for u in _paginate("users", "users"):
        yield {
            "id":         u["id"],
            "first_name": u["firstName"],
            "last_name":  u["lastName"],
            "age":        u.get("age"),
            "gender":     u.get("gender"),
            "email":      u.get("email"),
            "city":       u.get("address", {}).get("city"),
            "state":      u.get("address", {}).get("state"),
            "country":    u.get("address", {}).get("country"),
            "company":    u.get("company", {}).get("name"),
            "department": u.get("company", {}).get("department"),
            "job_title":  u.get("company", {}).get("title"),
        }


@dlt.resource(write_disposition="replace", primary_key="id")
def carts():
    for c in _paginate("carts", "carts"):
        yield {
            "id":               c["id"],
            "user_id":          c["userId"],
            "total":            c.get("total"),
            "discounted_total": c.get("discountedTotal"),
            "total_products":   c.get("totalProducts"),
            "total_quantity":   c.get("totalQuantity"),
        }


@dlt.resource(write_disposition="replace", primary_key=["cart_id", "product_id"])
def cart_items():
    for c in _paginate("carts", "carts"):
        for p in c.get("products", []):
            yield {
                "cart_id":            c["id"],
                "user_id":            c["userId"],
                "product_id":         p["id"],
                "product_title":      p["title"],
                "price":              p["price"],
                "quantity":           p["quantity"],
                "total":              p["total"],
                "discounted_total":   p["discountedTotal"],
            }


@dlt.resource(write_disposition="replace", primary_key="id")
def posts():
    for p in _paginate("posts", "posts", strip_keys=["tags"]):
        yield {
            "id":         p["id"],
            "title":      p["title"],
            "body":       p["body"],
            "user_id":    p["userId"],
            "views":      p.get("views"),
            "likes":      p.get("reactions", {}).get("likes"),
            "dislikes":   p.get("reactions", {}).get("dislikes"),
        }


@dlt.resource(write_disposition="replace", primary_key="id")
def recipes():
    for r in _paginate("recipes", "recipes", strip_keys=["ingredients", "instructions", "tags", "image"]):
        yield {
            "id":                  r["id"],
            "name":                r["name"],
            "cuisine":             r.get("cuisine"),
            "difficulty":          r.get("difficulty"),
            "meal_type":           r.get("mealType", [None])[0],
            "prep_time_minutes":   r.get("prepTimeMinutes"),
            "cook_time_minutes":   r.get("cookTimeMinutes"),
            "total_time_minutes":  (r.get("prepTimeMinutes") or 0) + (r.get("cookTimeMinutes") or 0),
            "servings":            r.get("servings"),
            "calories_per_serving":r.get("caloriesPerServing"),
            "rating":              r.get("rating"),
            "review_count":        r.get("reviewCount"),
        }


@dlt.resource(write_disposition="replace", primary_key="id")
def dj_todos():
    for t in _paginate("todos", "todos"):
        yield {
            "id":        t["id"],
            "user_id":   t["userId"],
            "todo":      t["todo"],
            "completed": t["completed"],
        }
