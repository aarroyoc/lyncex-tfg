from behave import step
import requests

@step("I visit '{url}'")
def step_visit_url(context, url):
    context.request = requests.get(f"http://lyncex:11011{url}")