import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/entities/todo_model.dart';
import 'package:todo_list_app/services/auth_service.dart';

void main() {
  runApp(const MaterialApp(title: "Lista de Tarefas", home: Home()));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();

  List _todoList = [];
  Map<String, dynamic> _lastRemoved = {};
  int _lastRemovedPos = 0;
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  void logout() async {
    await context.read<AuthService>().logout();
  }

  void addTodo() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      setState(() {
        Map<String, dynamic> newTodo = {};
        newTodo["title"] = _todoController.text;
        _todoController.text = "";
        newTodo["ok"] = false;
        _todoList.add(newTodo);
        _saveData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Lista de Tarefas"),
            actions: [
              GestureDetector(
                onTap: logout,
                child: const Icon(Icons.logout_outlined),
              ),
            ],
            backgroundColor: Colors.red,
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          validator: (value) => value!.isEmpty
                              ? "Tarefa não pode ser vazia"
                              : null,
                          controller: _todoController,
                          decoration: const InputDecoration(
                            labelText: "Nova Tarefa",
                            labelStyle: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      RawMaterialButton(
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        shape: const CircleBorder(),
                        fillColor: Colors.red,
                        onPressed: addTodo,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10.0),
                        itemCount: _todoList.length,
                        itemBuilder: buildItem),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget buildItem(context, index) {
    TodoModel item =
        TodoModel(title: _todoList[index]['title'], ok: _todoList[index]['ok']);
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: ListTile(
          onTap: () {
            checkTodo(index, !item.ok);
          },
          title: Text(
            item.title,
            style: TextStyle(
                fontSize: 18,
                color: item.ok ? Colors.grey : Colors.black,
                decoration:
                    item.ok ? TextDecoration.lineThrough : TextDecoration.none),
          ),
          trailing: Checkbox(
            shape: const CircleBorder(),
            fillColor: MaterialStateProperty.all(Colors.red),
            value: item.ok,
            onChanged: (c) {
              checkTodo(index, c);
            },
          )),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} removida."),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _todoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    final file = await _getFile();
    return file.readAsString();
  }

  void checkTodo(index, c) {
    setState(() {
      _todoList[index]["ok"] = c;
      _saveData();
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _todoList.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]) {
          return -1;
        } else {
          return 0;
        }
      });
      _saveData();
    });
  }
}
