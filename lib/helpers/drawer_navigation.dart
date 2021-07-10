import 'package:flutter/material.dart';
import 'package:todo2/screens/categories_screen.dart';
import 'package:todo2/screens/home_screen.dart';
import 'package:todo2/screens/todos_by_category.dart';
import 'package:todo2/services/category_service.dart';

class DrawerNavigation extends StatefulWidget {
  @override
  _DrawerNavigationState createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  List<Widget> _categoryList = List<Widget>.empty(growable: true);
  CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    getAllCategories();
  }

  getAllCategories() async {
    var categories = await _categoryService.getCategories();
    categories.forEach((category) {
      setState(() {
        _categoryList.add(InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TodosByCategory(category: category["name"])));
            },
            child: ListTile(
              title: Text(category["name"]),
            )));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("ToDo App"),
              accountEmail: Text("Categories & Priorities"),
              currentAccountPicture: GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.filter_list,
                    color: Colors.white,
                  ),
                ),
              ),
              decoration: BoxDecoration(color: Colors.orange),
            ),
            ListTile(
              title: Text("Home"),
              leading: Icon(Icons.home),
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (context) => new HomeScreen()));
              },
            ),
            ListTile(
              title: Text("Categories"),
              leading: Icon(Icons.view_list),
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (context) => new CategoriesScreen()));
              },
            ),
            Divider(),
            Column(
              children: _categoryList,
            ),
          ],
        ),
      ),
    );
  }
}
