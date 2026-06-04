import dlt
import requests

BASE = "https://jsonplaceholder.typicode.com"


@dlt.source(name="jsonplaceholder")
def source():
    return users(), posts(), comments(), todos()


@dlt.resource(write_disposition="replace", primary_key="id")
def users():
    yield requests.get(f"{BASE}/users").json()


@dlt.resource(write_disposition="replace", primary_key="id")
def posts():
    yield requests.get(f"{BASE}/posts").json()


@dlt.resource(write_disposition="replace", primary_key="id")
def comments():
    yield requests.get(f"{BASE}/comments").json()


@dlt.resource(write_disposition="replace", primary_key="id")
def todos():
    yield requests.get(f"{BASE}/todos").json()
