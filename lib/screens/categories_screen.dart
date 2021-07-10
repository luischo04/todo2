import 'package:flutter/material.dart';
import 'package:todo2/models/category.dart';
import 'package:todo2/screens/home_screen.dart';
import 'package:todo2/services/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  var _categoryName = TextEditingController();
  var _categoryDescription = TextEditingController();
  var _category = Category();
  var _categoryService = CategoryService();
  List<Category> _categoryList = List<Category>.empty(growable: true);
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  var _editCategoryName = TextEditingController();
  var _editCategoryDescription = TextEditingController();
  var category;

  getAllCategories() async {
    _categoryList.clear();
    var categories = await _categoryService.getCategories();
    categories.forEach((category) {
      setState(() {
        var model = Category();
        model.id = category['id'];
        model.name = category['name'];
        model.description = category['description'];
        _categoryList.add(model);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getAllCategories();
  }

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }


  _showFormInDialog(BuildContext context) {  //Muestra el formulario para guardar
    return showDialog( //retorna un dialog
        context: context, //El elemento actual
        barrierDismissible: true, //Que se pueda salir al dar tap fuera de su area
        builder: (param) { // método que lo genera
          return AlertDialog( // Estilo tipo alerta
            actions: [TextButton( // Botones
                onPressed: () async { //Al presionar
                  _category.name = _categoryName.text; //asignale al modelo lo del form
                  _category.description = _categoryDescription.text;
                  var result = await _categoryService.saveCategory(_category); //Usando el servicio de category para persistencia
                  if (result > 0) {
                    Navigator.pop(context); //Sal del cuadro de dialogo.
                    _showSnackBar("Saved successful!"); //Muestra el mensaje en la barra de snack
                    getAllCategories();}}, //Actualiza el listado de categorias
                child: Text("Save"), //Texto que se despliega para el botón
              ), TextButton(
                onPressed: () { //Al cancelar cierra solo el cuadro de dialogo.
                  Navigator.pop(context);
                },
                child: Text("Cancel"),),],
            title: Text("Category Form"), // Título del cuadro de dialogo
            content: SingleChildScrollView(
              child: Column( // Muestra en una columna cajas de texto para registrar una categoria
                children: [TextField(
                    decoration: InputDecoration(
                        labelText: "Category name:",
                        hintText: "Write category name"),
                    controller: _categoryName,
                  ), TextField(decoration: InputDecoration(
                        labelText: "Category description:",
                        hintText: "Write category description"),
                    controller: _categoryDescription,)],),),);
        });
  }

  _editCategoryDialog(BuildContext context) { // método para mostrar el formulario de edición
    return showDialog( // Muestra un cuadro de dialogo generado
        context: context, barrierDismissible: true, builder: (param) {
          return AlertDialog( // Dialogo tipo alerta
            actions: [ // Con botones
              TextButton(  //Boton de actualizar.
                onPressed: () async { //Al presionar asignará datos para actualizar del form.
                  _category.id = category[0]['id'];
                  _category.name = _editCategoryName.text;
                  _category.description = _editCategoryDescription.text;
                  var result = await _categoryService.updateCategory(_category); //usando el service
                  if (result > 0) { // Si se actualizo a partir de service
                    Navigator.pop(context);
                    _showSnackBar("Updated successful!"); // muestra un mensaje de snack
                    getAllCategories(); // Actualiza la lista con los cambios.
                  }},
                child: Text("Update"),), TextButton(
                onPressed: () { // en caso de cancelar solo mostará la pantalla con la lista
                  Navigator.pop(context, "Operation Canceled");
                }, child: Text("Cancel"),),],
            title: Text("Category Edit Form"),
            content: SingleChildScrollView(
              child: Column(
                children: [TextField(
                    decoration: InputDecoration( //Cajas de texto
                        labelText: "Category name:",
                        hintText: "Write category name"),
                    controller: _editCategoryName,
                  ), TextField(
                    decoration: InputDecoration(labelText: "Category description:",
                        hintText: "Write category description"),
                    controller: _editCategoryDescription,),],),),);
        });
  }

  _deleteCategoryDialog(BuildContext context, categoryId) { //Dialogo para borrar un elemento
    return showDialog(context: context, barrierDismissible: true, builder: (param) {
          return AlertDialog( // Se genera a partir de sus partes
            actions: <Widget>[ElevatedButton(
                style: ElevatedButton.styleFrom( // Se coloca estilo para mejorar la experiencia
                  primary: Colors.green, // background
                  onPrimary: Colors.white, // foreground
                ), onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ), ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background
                  onPrimary: Colors.white, // foreground
                ), onPressed: () async { // Al presionar borrar se eliminara el registro
                  var result =
                  await _categoryService.deleteCategory(categoryId);
                  if (result > 0) { // Permitirá actualizar la lista con el cambio realizado
                    Navigator.pop(context);
                    getAllCategories();
                    _showSnackBar('Deleted!');
                  }}, child: Text('Delete'),
              ),
            ],
            title: Text("Are you sure you want to delete?"),);
        });
  }

  _editCategory(BuildContext context, categoryId) async {
    category = await _categoryService.getCategoryById(categoryId);
    setState(() {
      _editCategoryName.text = category[0]['name'] ?? 'No name';
      _editCategoryDescription.text =
          category[0]['description'] ?? 'No description';
    });
    _editCategoryDialog(context);
  }

  @override
  Widget build(BuildContext context) { // Método para construir los elementos del estado del Widget
    return Scaffold( key: scaffoldMessengerKey, // El key es para permitir los mensajes en la barra snack
      appBar: AppBar(title: Text("Categories"), // Barra de aplicación
        leading: ElevatedButton(child: Icon(Icons.arrow_back, color: Colors.white), //Botón de la barra
          onPressed: () { //Al ser presionado ira a la pantalla de inicio
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
            },),),
      body: ListView.builder( // El ListView mostrar todas las categorías registradas
          itemCount: _categoryList.length, itemBuilder: (context, index) {
            return Card(child: ListTile(leading: IconButton(icon: Icon(Icons.edit), // Cada elemento
                      onPressed: () { //tiene un botón de editar y borrar al igual que el nombre de la categoría
                        _editCategory(context, _categoryList[index].id); //llamada al metodo que busca en la bd
                      }),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(_categoryList[index].name),
                      IconButton( // Tanto el botón de editar y borrar mostrarán un cuadro de dialogo
                          icon: Icon(Icons.delete), //Que contienen los botones para cancelar o realizar la operación
                          onPressed: () {
                            _deleteCategoryDialog( context, _categoryList[index].id);
                          }),],)),);}),
      floatingActionButton: FloatingActionButton( //El botón flotante servirá para mostrar el dialogo de registro nuevo
        onPressed: () {_showFormInDialog(context);}, child: Icon(Icons.add),),);
  }



}
