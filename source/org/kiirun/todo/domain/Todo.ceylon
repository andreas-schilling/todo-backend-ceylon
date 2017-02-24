import ceylon.json {
    JsonObject
}
import java.net {
    URI
}

shared class Todo {
    shared Integer id;
    String title;
    Integer? order;
    Boolean completed;
    URI url;
    
    shared new (Integer id, URI url, String? title, Integer? order, Boolean? completed = false) {
        assert (exists title);
        
        this.id = id;
        this.title = title;
        this.order = order;
        this.completed = completed else false;
        this.url = url;
    }
    
    shared new from(Integer id, URI baseUrl, TodoData todo)
            extends Todo(id, baseUrl.resolve("``baseUrl.path``/``id``"), todo.title, todo.order, todo.completed) {
    }
    
    shared Todo patch(TodoData patchData) {
        return Todo(id,
            url,
            patchData.title else this.title,
            patchData.order else this.order,
            patchData.completed else this.completed);
    }
    
    shared JsonObject toJson() {
        return JsonObject {
            "id"->id,
            "title"->title,
            "order"->order,
            "completed"->completed,
            "url"->url.string
        };
    }
    
    shared actual String string {
        return "``id``: ``title`` [`` completed then "X" else "" ``]";
    }
}