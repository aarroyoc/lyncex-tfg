from behave import step
import requests

@step("I submit form '{url}' with data '{param}={value}'")
def step_visit_post_data(context, url, param, value):
    context.request = requests.post(f"http://lyncex:11011{url}", data={param : value})