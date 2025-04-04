import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_app/data/database.dart';
import 'package:to_do_app/todo_tile.dart';
import 'package:to_do_app/util/dialog_box.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // reference the hive box
  final _myBox = Hive.box('mybox');


  @override
  void initState() {
    // if this is the first time opemimg the app, then create default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialdata();
    
    } else{
      // there already exist data
      db.loadData();

    }
    super.initState();
  }

  // text controller
  final _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

 ToDoDataBase db = ToDoDataBase();

  // checkbox was changed
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();
  }

  //save a neew task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    _listKey.currentState?.insertItem(
      db.toDoList.length - 1,
      duration: const Duration(milliseconds: 600), // Smooth add animation
    );
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  //create a new task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

// delete a task
  void deleteTask(BuildContext context, int index) {
    final removedItem = db.toDoList[index];

    // Close the slidable before starting the animation
    Slidable.of(context)?.close();

    // Animate the removed item (fading)
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          child: ScaleTransition(
            scale: animation.drive(
              Tween<double>(begin: 0.0, end: 1.0) // Shrinks smoothly
              .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: ToDoTile(
              taskName: removedItem[0],
              taskCompleted: removedItem[1],
              onChanged: (value) {},
              deleteFunction: (context) {},
            ),
          ),
        ),
      ),
      duration: const Duration(
        milliseconds: 600,
      ), // Matches the adding animation
    );

    // Remove item from the list AFTER triggering the animation
    setState(() {
      db.toDoList.removeAt(index);
    });

    db.updateDataBase();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        centerTitle: true,
        title: const Text('TO DO'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.add),
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: db.toDoList.length,
        itemBuilder: (context, index, animation) {
          return ScaleTransition(
            scale: animation.drive(
              Tween<double>(begin: 0.8, end: 1.0).chain(
                CurveTween(
                  curve: Curves.elasticOut,
                ), // Bounce effect when adding
              ),
            ),
            child: ToDoTile(
              taskName: db.toDoList[index][0],
              taskCompleted: db.toDoList[index][1],
              onChanged: (value) => checkBoxChanged(value, index),
              deleteFunction: (context) => deleteTask(context, index),
            ),
          );
        },
      ),
    );
  }
}
