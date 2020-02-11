# API

Lyncex is both a database and a web framework. The main way to interact with Lyncex is through the REST API.

API listens at _api

GET /_api
Prolog query

POST /_api
Turtle text file

```
curl -X POST -H "Content-Type: text/turtle" --data-binary "@data.ttl" http://localhost:11011/_api
```

DELETE
Prolog Text File