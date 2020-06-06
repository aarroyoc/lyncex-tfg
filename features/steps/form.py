from behave import step
import requests

@step("I submit the form '{url}' with data '_id={id}' and 'name={name}'")
def step_submit_form_name(context, url, id, name):
    context.request = requests.post(f"http://lyncex:11011{url}", data={
        "_id" : id,
        "https://app.lyncex.com/name": name
    })
    assert context.request.status_code == 200

@step("I submit the form '{url}' with data '_id={id}' and 'xname={name}'")
def step_submit_form_xname(context, url, id, name):
    context.request = requests.post(f"http://lyncex:11011{url}", data={
        "_id" : id,
        "https://app.lyncex.com/xname": name
    })

@step("I submit the form '{url}' with data '_id={id}' and 'author=small'")
def step_submit_form_cervantes(context, url, id):
    context.request = requests.post(f"http://lyncex:11011{url}", data={
        "_id" : id,
        "https://app.lyncex.com/author": "Cervantes\nLope de Vega"
    })

@step("I submit the form '{url}' with data '_id={id}' and 'author=large'")
def step_submit_form_pepito(context, url, id):
    context.request = requests.post(f"http://lyncex:11011{url}", data={
        "_id" : id,
        "https://app.lyncex.com/author": "Cervantes\nLope de Vega\nPepito"
    })

@step("I submit the form '{url}' with data '_id={id}' and 'friend={name}'")
def step_submit_form_friend(context, url, id, name):
    context.request = requests.post(f"http://lyncex:11011{url}", data={
        "_id" : id,
        "https://app.lyncex.com/friend": name
    })