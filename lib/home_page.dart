import 'package:flutter/material.dart';
import 'package:to_do_app/todo_tile.dart';
import 'package:to_do_app/util/dialog_box.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<List<dynamic>> toDoList = [
    ["Pet Stella", false],
    ["Pet ofelia", false],
  ];

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
    });
  }

  void saveNewTask() {
    setState(() {
      toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    _listKey.currentState?.insertItem(
      toDoList.length - 1,
      duration: const Duration(milliseconds: 600), // Smooth add animation
    );
    Navigator.of(context).pop();
  }

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

  void deleteTask(BuildContext context, int index) {
    final removedItem = toDoList[index];

    // Close the slidable before starting the animation
    Slidable.of(context)?.close();

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => FadeTransition(
        opacity: animation, // Gradually fades out
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut), // Smooth shrink effect
            ),
          ),
          child: ToDoTile(
            taskName: removedItem[0],
            taskCompleted: removedItem[1],
            onChanged: (value) {},
            deleteFunction: (context) {},
          ),
        ),
      ),
      duration: const Duration(milliseconds: 600), // Same duration as adding
    );

    setState(() {
      toDoList.removeAt(index);
    });
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
        initialItemCount: toDoList.length,
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
              taskName: toDoList[index][0],
              taskCompleted: toDoList[index][1],
              onChanged: (value) => checkBoxChanged(value, index),
              deleteFunction: (context) => deleteTask(context, index),
            ),
          );
        },
      ),
    );
  }
}
