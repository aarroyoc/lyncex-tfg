from behave import step
import requests
import hashlib

@step("I visit '{url}'")
def step_visit_url(context, url):
    context.request = requests.get(f"http://lyncex:11011{url}")

@step("I get the photo '{photo}'")
def step_get_photo(context, photo):
    m = hashlib.sha1()
    m.update(context.request.content)
    n = hashlib.sha1()
    with open(photo, "rb") as f:
        n.update(f.read())
    assert m.digest() == n.digest()