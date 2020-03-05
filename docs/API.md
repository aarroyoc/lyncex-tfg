# API

Lyncex is both a database and a web framework. The main way to interact with Lyncex is through the REST API. With the API you can retrieve, add and delete content from the database. All API endpoints are under /_api

## Retrieve data

GET /_api/query

Optional parameters

subject 
predicate
object

Remember to URL Encode all the Parameters!

## Add data
**POST** /_api

With Turtle text file as body content

Example:
```
curl -X POST -H "Content-Type: text/turtle" --data-binary "@data.ttl" http://localhost:11011/_api
```

## Delete data
**DELETE** /_api/delete

Optional URL parameters:
* subject
* predicate
* object

If there are no URL parameters, it deletes ALL the database.

Example (delete ALL):
```
curl -X DELETE http://localhost:11011/_api/delete
```

Example delete with filters:
```
curl -G -X DELETE --data-urlencode "predicate=http://www.w3.org/1999/02/22-rdf-syntax-ns\#type" http://localhost:11011/_api/delete
```
