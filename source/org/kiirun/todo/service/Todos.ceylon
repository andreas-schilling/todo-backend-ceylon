import ceylon.collection {
    HashMap,
    MutableMap
}

import org.kiirun.todo.domain {
    Todo,
    TodoData
}
import java.net {
    URI
}

shared class Todos() {
    MutableMap<Integer,Todo> todos = HashMap<Integer,Todo>();
    
    variable Integer todoId = 0;
    
    shared Collection<Todo> all() {
        return todos.items;
    }
    
    shared Todo? byId(Integer id) {
        return todos.get(id);
    }
    
    shared Todo add(URI baseUrl, TodoData newTodoData) {
        Todo newTodo = Todo.from(++todoId, baseUrl, newTodoData);
        todos.put(newTodo.id, newTodo);
        return newTodo;
    }
    
    shared void clear() {
        todos.clear();
    }
    
    shared Todo? remove(Integer id) {
        return todos.remove(id);
    }
    
    shared Todo? update(Integer id, TodoData updatedTodo) {
        Todo? todo = todos.remove(id)?.patch(updatedTodo);
        if (exists todo) {
            todos.put(todo.id, todo);
        }
        return todo;
    }
}