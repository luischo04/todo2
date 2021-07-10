import 'package:flutter/material.dart';
import 'package:todo2/helpers/drawer_navigation.dart';
import 'package:todo2/models/todo.dart';
import 'package:todo2/screens/todo_screen.dart';
import 'package:todo2/services/todo_service.dart';
import 'package:todo2/services/category_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TodoService _todoService;
  List<Todo> _todoList = List<Todo>.empty(growable: true);
  var _editTodoTitle = TextEditingController();
  var _editTodoDescription = TextEditingController();
  var _editTodoDate = TextEditingController();
  var _editSelectedValue;
  var todo;
  var _todo = Todo();
  List<DropdownMenuItem> _categories =
      List<DropdownMenuItem>.empty(growable: true);

  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    getAllTodos();
    _loadCategories();
  }

  getAllTodos() async {
    _todoService = TodoService();
    _todoList = List<Todo>.empty(growable: true);
    var todos = await _todoService.getTodos();
    todos.forEach((todo) {
      setState(() {
        var model = Todo();
        model.id = todo["id"];
        model.title = todo["title"];
        model.description = todo["description"];
        model.category = todo["category"];
        model.todoDate = todo["todoDate"];
        model.isFinished = todo["isFinished"];
        _todoList.add(model);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo App"),
      ),
      body: ListView.builder(
          itemCount: _todoList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                  leading: Checkbox(
                 
                    onChanged: (bool value) {  }, value: true,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_todoList[index].title),
                      IconButton(
                          icon: Icon(Icons.edit), // Cada elemento
                          onPressed: () {
                            //tiene un botón de editar y borrar al igual que el nombre de la categoría
                            _editTodo(
                                context,
                                _todoList[index]
                                    .id); //llamada al metodo que busca en la bd
                          }),
                      IconButton(
                          // Tanto el botón de editar y borrar mostrarán un cuadro de dialogo
                          icon: Icon(Icons
                              .delete), //Que contienen los botones para cancelar o realizar la operación
                          onPressed: () {
                            _deleteTodoDialog(context, _todoList[index].id);
                          }),
                    ],
                  )),
            );
          }),
      drawer: DrawerNavigation(), // Text(_todoList[index].title ?? "No title"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => TodoScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _editTodo(BuildContext context, todoId) async {
    todo = await _todoService.getTodosById(todoId);
    setState(() {
      _editTodoTitle.text = todo[0]['title'] ?? 'No name';
      _editTodoDescription.text = todo[0]['description'] ?? 'No description';
      _editTodoDate.text = todo[0]['todoDate'];
      _editSelectedValue = todo[0]['category'];
    });
    _editTodoDialog(context);
  }

  _editTodoDialog(BuildContext context) {
    // método para mostrar el formulario de edición
    return showDialog(
        // Muestra un cuadro de dialogo generado
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            // Dialogo tipo alerta
            actions: [
              // Con botones
              TextButton(
                //Boton de actualizar.
                onPressed: () async {
                  //Al presionar asignará datos para actualizar del form.
                  _todo.id = todo[0]['id'];
                  _todo.title = _editTodoTitle.text;
                  _todo.description = _editTodoDescription.text;
                  _todo.todoDate = _editTodoDate.text;
                  _todo.category = _editSelectedValue;
                  var result =
                      await _todoService.updateTodo(_todo); //usando el service
                  if (result > 0) {
                    // Si se actualizo a partir de service
                    Navigator.pop(context);

                    _showSnackBar(
                        "Updated successful!"); // muestra un mensaje de snack

                    getAllTodos(); // Actualiza la lista con los cambios.
                  }
                },
                child: Text("Update"),
              ),
              TextButton(
                onPressed: () {
                  // en caso de cancelar solo mostará la pantalla con la lista
                  Navigator.pop(context, "Operation Canceled");
                },
                child: Text("Cancel"),
              ),
            ],
            title: Text("Todo Edit Form"),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Todo title",
                      labelText: "Cook food",
                    ),
                    controller: _editTodoTitle,
                  ),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText: "Todo Description",
                        labelText: "Cook rice and curry"),
                    controller: _editTodoDescription,
                  ),
                  TextField(
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
                    controller: _editTodoDate,
                  ),
                  DropdownButtonFormField(
                    value: _editSelectedValue,
                    items: _categories,
                    hint: Text("Select one category"),
                    onChanged: (value) {
                      setState(() {
                        _editSelectedValue = value;
                      });
                    },
                  )
                ],
              ),
            ),
          );
        });
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
        _editTodoDate.text = DateFormat("yyyy-MM-dd").format(_pickedDate);
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

  _deleteTodoDialog(BuildContext context, todoId) {
    //Dialogo para borrar un elemento
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            // Se genera a partir de sus partes
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Se coloca estilo para mejorar la experiencia
                  primary: Colors.green, // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () async {
                  // Al presionar borrar se eliminara el registro
                  var result = await _todoService.deleteTodo(todoId);
                  if (result > 0) {
                    // Permitirá actualizar la lista con el cambio realizado
                    Navigator.pop(context);
                    _showSnackBar('Deleted!');
                     getAllTodos();
                  }
                },
                child: Text('Delete'),
              ),
            ],
            title: Text("Are you sure you want to delete?"),
          );
        });
  }
}
