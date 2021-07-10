import 'package:todo2/models/todo.dart';
import 'package:todo2/repositories/repository.dart';

class TodoService{
  Repository _repository;
  TodoService(){
    _repository = Repository();
  }
  insertTodo(Todo todo) async{
    return await _repository.save("todos", todo.todoMap());
  }

  getTodos() async{
    return await _repository.getAll("todos");
  }

  getTodosById(todoId) async {
    return await _repository.getById("todos", todoId);
  }

  todosByCategory(String category) async{
    return await _repository.getByColumnName("todos", "category", category);
  }
  updateTodo(Todo todo) async {
    return await _repository.update('todos', todo.todoMap());
  }
  deleteTodo(todoId) async{
    return await _repository.delete('todos', todoId);
  }
}  