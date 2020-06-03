from behave import step
import requests

@step("I login at '{url}'")
def step_login(context, url):
    context.request = requests.post(f"http://lyncex:11011{url}", data={
        "user": "aarroyoc",
        "password": "123456"
    })
    context.cookies = context.request.cookies

@step("I visit with cookies '{url}'")
def step_visit_cookies(context, url):
    context.request = requests.get(f"http://lyncex:11011{url}", cookies=context.cookies)