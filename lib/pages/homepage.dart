import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_demo/blocs/todo/todo_bloc.dart';
import 'package:firebase_demo/blocs/todo/todo_event.dart';
import 'package:firebase_demo/blocs/todo/todo_state.dart';
import 'package:firebase_demo/model/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        title: const Text('Firestore'),
        actions: [
          InkWell(
              onTap: ()  {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              child: const Text("Logout"))
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
              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return ListTile(
                    title: Text(todo.title),
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
                  );
                },
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
        onPressed: () {
          _showAddTodoDialog(context, false, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, bool isEdit, Todo? todos) {
    final _titleController = TextEditingController();
    if (isEdit) {
      _titleController.text = todos!.title;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Todo title'),
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
                        title: _titleController.text,
                        completed: _titleController.text.isEmpty)
                    : Todo(
                        id: DateTime.now().toString(),
                        title: _titleController.text,
                        completed: false,
                      );
                if (isEdit) {
                  var updatedTo = todo.copyWith(
                      completed: _titleController.text.isNotEmpty);
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
