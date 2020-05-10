from behave import step
import requests
import rdflib
from rdflib.compare import similar
import tempfile

@step("I have an empty Lyncex instance")
def step_start_lyncex(context):
   step_delete_request(context)

@step("I do a GET request")
def step_get_request(context):
    context.request = requests.get("http://lyncex:11011/_api/query")

@step("I get a {code:d} status code")
def step_check_response(context, code):
    assert context.request.status_code == code

@step("I get an empty response")
def step_check_empty_response(context):
    step_check_response(context, "")

@step("I get a '{text}' response")
def step_check_response(context, text):
    response_text = context.request.text.replace("\n","")
    print(text)
    print(response_text)
    assert response_text == text

@step("I do a POST request with '{file}' data")
def step_post_request(context, file):
    with open(file) as f:
        data = f.read()
    context.request = requests.post(
        "http://lyncex:11011/_api",
        data=data,
        headers={"Content-Type": "text/turtle"}
    )

@step("I get the contents of '{file}'")
def step_diff_content(context, file):
    f = tempfile.NamedTemporaryFile()
    f.write(context.request.content)

    a = rdflib.Graph()
    a.parse(file, format="turtle")
    b = rdflib.Graph()
    b.parse(f.name, format="turtle")
    assert similar(a, b)
    
@step("I do a DELETE request")
def step_delete_request(context):
    r = requests.delete("http://lyncex:11011/_api/delete")
    assert r.status_code == 200

@step("I do a filtered (subject='{subject}') DELETE request")
def step_delete_request_filter(context, subject):
    r = requests.delete(f"http://lyncex:11011/_api/delete?subject={subject}")
    context.request = r

@step("I get a '{mime}' response type")
def step_check_mimetype(context, mime):
    assert mime in context.request.headers['content-type']