import 'package:flutter/material.dart';
import 'package:todo2/models/todo.dart';
import 'package:todo2/services/category_service.dart';
import 'package:todo2/services/todo_service.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  var _todoTitle = TextEditingController();
  var _todoDescription = TextEditingController();
  var _todoDate = TextEditingController();
  var _selectedValue;
  var _todoService = TodoService();


  List<DropdownMenuItem> _categories =
      List<DropdownMenuItem>.empty(growable: true);

  DateTime _date = DateTime.now();
  

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  _selectTodoDate() async {
    var _pickedDate = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2099));
    if (_pickedDate != null) {
      setState(() {
        _date = _pickedDate;
        _todoDate.text = DateFormat("yyyy-MM-dd").format(_pickedDate);
      });
    }
  }

  _loadCategories() async {
    var _categoryService = CategoryService();
    var categories = await _categoryService.getCategories();
    categories.forEach((category) {
      setState(() {
        _categories.add(DropdownMenuItem(
          child: Text(category["name"]),
          value: category["name"],
        ));
      });
    });
  }

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        title: Text("Create Todo"),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _todoTitle,
            decoration: InputDecoration(
              hintText: "Todo title",
              labelText: "Cook food",
            ),
          ),
          TextField(
            controller: _todoDescription,
            maxLines: 3,
            decoration: InputDecoration(
                hintText: "Todo Description", labelText: "Cook rice and curry"),
          ),
          TextField(
            controller: _todoDate,
            decoration: InputDecoration(
              hintText: "YY-MM-DD",
              labelText: "YY-MM-DD",
              prefixIcon: InkWell(
                child: Icon(Icons.calendar_today),
                onTap: () {
                  _selectTodoDate();
                },
              ),
            ),
          ),
          DropdownButtonFormField(
            value: _selectedValue,
            items: _categories,
            hint: Text("Select one category"),
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
            },
          ),
          ElevatedButton(
              onPressed: () async {
                var todoObj = Todo();
                todoObj.title = _todoTitle.text;
                todoObj.description = _todoDescription.text;
                todoObj.todoDate = _todoDate.text;
                todoObj.category = _selectedValue;
                todoObj.isFinished = 0;

                var result = await _todoService.insertTodo(todoObj);
                if (result > 0) {
                  _showSnackBar("Successful save!");
                }
              },
              child: Text("Save"))
        ],
      ),
    );
  }
}
