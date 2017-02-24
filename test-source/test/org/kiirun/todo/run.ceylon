import org.kiirun.todo.domain {
    Todo
}
import ceylon.test {
    assertNotNull,
    test
}
import java.net {
    URI
}

test
shared void todoCanBeCreated() {
    Todo todo = Todo(1, URI("http://localhost/todo"), "Title", 10, false);
    assertNotNull(todo.toJson);
}