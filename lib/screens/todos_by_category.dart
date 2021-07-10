import 'package:flutter/material.dart';
import 'package:todo2/models/todo.dart';
import 'package:todo2/services/todo_service.dart';

class TodosByCategory extends StatefulWidget {
  final String category;
  TodosByCategory({this.category});
  @override
  _TodosByCategoryState createState() => _TodosByCategoryState();
}

class _TodosByCategoryState extends State<TodosByCategory> {
  List<Todo> _todoList = List<Todo>.empty(growable: true);
  TodoService _todoService = TodoService();


  getTodosByCategory() async{
    var todos = await _todoService.todosByCategory(this.widget.category);
    todos.forEach(
        (todo){
          setState(() {
            var model = Todo();
            model.title = todo["title"];
            _todoList.add(model);
          });
        }
    );
  }

  @override
  void initState() {
    super.initState();
    getTodosByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todos by category"),
      ),
      body: Column(
        children: <Widget>[
          Text(this.widget.category),
          Expanded(child:
          ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index){
                return Card(
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(_todoList[index].title ?? "No title"),
                      ],
                    ),
                  ),
                );
              }),
          ),
        ],
      ),

    );
  }
}
