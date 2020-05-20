from behave import step
import requests

@step("I submit the form '{url}' with data '_id={id}' and 'name={name}'")
def step_submit_form(context, url, id, name):
    context.request = requests.post(f"http://lyncex:11011{url}", data={
        "_id" : id,
        "https://app.lyncex.com/name": name
    })
    assert context.request.status_code == 200

@step("I submit the form '{url}' with data '_id={id}' and 'xname={name}'")
def step_submit_form(context, url, id, name):
    context.request = requests.post(f"http://lyncex:11011{url}", data={
        "_id" : id,
        "https://app.lyncex.com/xname": name
    })

@step("I submit the form '{url}' with data '_id={id}' and 'author={name}'")
def step_submit_form(context, url, id, name):
    print(name)
    context.request = requests.post(f"http://lyncex:11011{url}", data={
        "_id" : id,
        "https://app.lyncex.com/author": "Cervantes\nLope de Vega"
    })