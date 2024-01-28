import 'package:flutter/material.dart';
import '../../model/todo.dart';


@immutable
abstract class TodoEvent {}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final Todo todo;

  AddTodo(this.todo);
}


class UpdateTodo extends TodoEvent {
  final String todoId;
  final Todo todo;
  UpdateTodo(this.todoId,this.todo);
}
class DeleteTodo extends TodoEvent {
  final String todoId;

  DeleteTodo(this.todoId);
}