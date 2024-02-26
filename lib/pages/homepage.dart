import 'package:firebase_demo/blocs/todo/todo_bloc.dart';
import 'package:firebase_demo/blocs/todo/todo_event.dart';
import 'package:firebase_demo/blocs/todo/todo_state.dart';
import 'package:firebase_demo/model/todo.dart';
import 'package:firebase_demo/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'signin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    BlocProvider.of<TodoBloc>(context).add(LoadTodos());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TodoBloc _todoBloc = BlocProvider.of<TodoBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ToDo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.appColor,
        actions: [
          InkWell(
              onTap: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              child: const Icon(Icons.logout_outlined, color: Colors.white))
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UnAuthenticated) {
            // Navigate to the sign in screen when the user Signs Out
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const SignIn()),
              (route) => false,
            );
          }
        },
        child: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state is TodoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TodoLoaded) {
              final todos = state.todos;
              return Container(
                   color: Colors.grey[200],
                child: ListView.builder(
                  itemCount: todos.length,
                
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 5.0,
                            offset:
                                Offset(0, 5), // shadow direction: bottom right
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          todo.title,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.appColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Text(todo.description),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red[900],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  todo.date,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showAddTodoDialog(context, true, todo);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.withOpacity(0.5),
                              ),
                              onPressed: () {
                                _todoBloc.add(DeleteTodo(todo.id!));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is TodoOperationSuccess) {
              _todoBloc.add(LoadTodos()); // Reload todos
              return Container(); // Or display a success message
            } else if (state is TodoError) {
              return Center(child: Text(state.errorMessage));
            } else {
              return Container();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.appColor,
        onPressed: () {
          _showAddTodoDialog(context, false, null);
        },
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, bool isEdit, Todo? todos) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    if (isEdit) {
      titleController.text = todos!.title;
      descriptionController.text = todos.description;
      dateController.text = todos.date;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    hintText: 'Task',
                    hintStyle: const TextStyle(fontSize: 14),
                    icon: const Icon(CupertinoIcons.square_list,
                        color: AppColors.appColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    hintText: 'Description',
                    hintStyle: const TextStyle(fontSize: 14),
                    icon: const Icon(CupertinoIcons.bubble_left_bubble_right,
                        color: AppColors.appColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller:
                      dateController, //editing controller of this TextField
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    hintText: 'Date',
                    hintStyle: const TextStyle(fontSize: 14),
                    icon: const Icon(CupertinoIcons.calendar,
                        color: AppColors.appColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  readOnly: true, // when true user cannot edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(), //get today's date
                        firstDate: DateTime(
                            2000), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2101));

                    if (pickedDate != null) {
                      //get the picked date in the format => 2022-07-04 00:00:00.000
                      String formattedDate = DateFormat('yyyy-MM-dd').format(
                          pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                      print(
                          formattedDate); //formatted date output using intl package =>  2022-07-04
                      //You can format date as per your need

                      setState(() {
                        dateController.text =
                            formattedDate; //set foratted date to TextField value.
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text(isEdit ? 'Update' : 'Add'),
              onPressed: () {
                final todo = isEdit
                    ? Todo(
                        id: todos!.id!,
                        title: titleController.text,
                        description: descriptionController.text,
                        date: dateController.text,
                        completed: titleController.text.isEmpty)
                    : Todo(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        description: descriptionController.text,
                        date: dateController.text,
                        completed: false,
                      );
                if (isEdit) {
                  var updatedTo =
                      todo.copyWith(completed: titleController.text.isNotEmpty);
                  BlocProvider.of<TodoBloc>(context)
                      .add(UpdateTodo(todo.id!, updatedTo));
                  Navigator.pop(context);
                } else {
                  BlocProvider.of<TodoBloc>(context).add(AddTodo(todo));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
