import ceylon.buffer.charset {
    charsetsByAlias
}
import ceylon.http.common {
    get,
    post,
    delete,
    contentType,
    Method,
    parseMethod,
    Header,
    options
}
import ceylon.http.server {
    newServer,
    Endpoint,
    Response,
    Request,
    Server,
    equals,
    template,
    Options,
    startsWith,
    isRoot,
    AsynchronousEndpoint
}
import ceylon.http.server.endpoints {
    redirect
}
import ceylon.io {
    SocketAddress
}
import ceylon.json {
    JsonArray
}

import java.net {
    URI
}

import org.kiirun.todo.domain {
    TodoData
}

shared Method patch = parseMethod("PATCH");

shared class TodoResource() {
    import ceylon.http.server {
        equals
    }
    
    Todos todos = Todos();
    
    String? externalUrl = process.environmentVariableValue("EXTERNAL_URL");
    
    shared void start() {
        Server server = newServer {
            endpoints = {
                redirectToApi(),
                optionsRequest(),
                getAllTodos(),
                getUpdateDeleteOneTodo(),
                createTodo(),
                deleteAllTodos()
            };
        };
        
        value parsedPort = Integer.parse(process.environmentVariableValue("PORT") else "8080");
        String host = process.environmentVariableValue("PORT") exists then "0.0.0.0" else "localhost";
        server.start(SocketAddress(host, if (is Integer parsedPort) then parsedPort else 8080), Options());
    }
    
    void jsonResponse(Response response, Integer status, String? responseContent) {
        defaultResponse(response, responseContent exists then status else 404);
        response.addHeader(contentType("application/json", charsetsByAlias["UTF-8"]));
        if (exists responseContent) {
            response.writeString(responseContent);
        }
    }
    
    void defaultResponse(Response response, Integer status) {
        response.addHeader(Header("Access-Control-Allow-Origin", "*"));
        response.status = status;
    }
    
    AsynchronousEndpoint redirectToApi() {
        return AsynchronousEndpoint {
            path = isRoot();
            acceptMethod = { get };
            service = redirect("/todo");
        };
    }
    
    Endpoint optionsRequest() {
        return Endpoint {
            path = isRoot().or(startsWith("/todo"));
            acceptMethod = { options };
            optionsService;
        };
    }
    
    void optionsService(Request request, Response response) {
        defaultResponse(response, 200);
        response.addHeader(contentType("text/html", charsetsByAlias["UTF-8"]));
        response.addHeader(Header("Access-Control-Allow-Headers", "Content-Type"));
        response.addHeader(Header("Access-Control-Allow-Methods", "GET, POST, PATCH, DELETE, OPTIONS"));
    }
    
    Endpoint getAllTodos() {
        return Endpoint {
            path = equals("/todo");
            acceptMethod = { get };
            void service(Request request, Response response) {
                jsonResponse(response, 200, JsonArray({ for (todo in todos.all()) todo.toJson() }).pretty);
            }
        };
    }
    
    Endpoint getUpdateDeleteOneTodo() {
        return Endpoint {
            path = template("/todo/{id}");
            acceptMethod = { get, delete, patch };
            void service(Request request, Response response) {
                if (exists idValue = request.pathParameter("id"), is Integer id = Integer.parse(idValue)) {
                    switch (request.method)
                    case (get) {
                        jsonResponse(response, 200, todos.byId(id)?.toJson()?.pretty);
                    }
                    case (delete) {
                        defaultResponse(response, todos.remove(id) exists then 204 else 404);
                    }
                    else {
                        handlePatchOrElseMethodNotAllowed(request, response, id);
                    }
                } else {
                    defaultResponse(response, 422);
                }
            }
        };
    }
    
    void handlePatchOrElseMethodNotAllowed(Request request, Response response, Integer id) {
        if (request.method == patch) {
            if (exists todoData = TodoData.fromJson(request.read())) {
                jsonResponse(response, 201, todos.update(id, todoData)?.toJson()?.pretty);
            } else {
                defaultResponse(response, 422);
            }
        } else if (request.method == options) {
            optionsService(request, response);
        } else {
            defaultResponse(response, 405);
        }
    }
    
    Endpoint createTodo() {
        return Endpoint {
            path = equals("/todo");
            acceptMethod = { post };
            void service(Request request, Response response) {
                try {
                    assert (is TodoData todoData = TodoData.fromJson(request.read()));
                    URI baseUrl = URI(request.scheme, externalUrl else request.destinationAddress.address, request.path, null);
                    jsonResponse(response, 201, todos.add(baseUrl, todoData).toJson().pretty);
                } catch (AssertionError e) {
                    defaultResponse(response, 422);
                }
            }
        };
    }
    
    Endpoint deleteAllTodos() {
        return Endpoint {
            path = equals("/todo");
            acceptMethod = { delete };
            void service(Request request, Response response) {
                todos.clear();
                defaultResponse(response, 204);
            }
        };
    }
}