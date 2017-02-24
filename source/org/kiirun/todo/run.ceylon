import org.kiirun.todo.service {
    TodoResource
}

"Runs the TODO backend application"
shared void run() {
    TodoResource().start();
}
