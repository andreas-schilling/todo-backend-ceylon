import ceylon.json {
    parse,
    Object,
    InvalidTypeException
}

shared class TodoData {
    static
    shared TodoData? fromJson(String json) {
        assert (is Object parsedTodo = parse(json));
        try {
            String? title = parsedTodo.getStringOrNull("title");
            Integer? order = parsedTodo.getIntegerOrNull("order");
            Boolean? completed = parsedTodo.getBooleanOrNull("completed");
            return TodoData(title, order, completed);
        } catch (InvalidTypeException e) {
        }
        return null;
    }
    
    shared String? title;
    shared Integer? order;
    shared Boolean? completed;
    
    shared new (String? title, Integer? order, Boolean? completed = false) {
        this.title = title;
        this.order = order;
        this.completed = completed;
    }
}