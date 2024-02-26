import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_demo/model/todo.dart';

class FirestoreService {
  final CollectionReference _todosCollection =
      FirebaseFirestore.instance.collection('todos'); // Use a fixed collection name

  String get currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ?? 'default';

  Stream<List<Todo>> getTodos() {
    return _todosCollection
        .doc(currentUserId)
        .collection('user_todos')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Todo(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          date: data['date'],
          completed: data['completed'],
        );
      }).toList();
    });
  }

  Future<void> addTodo(Todo todo) {
    return _todosCollection
        .doc(currentUserId)
        .collection('user_todos')
        .add({
      'title': todo.title,
      'description':todo.description,
      'date':todo.date,
      'completed': todo.completed,
    
    });
  }

  Future<void> updateTodo(String todoId, Todo todo) {
    return _todosCollection
        .doc(currentUserId)
        .collection('user_todos')
        .doc(todoId)
        .update({
      'title': todo.title,
        'description':todo.description,
      'date':todo.date,
      'completed': todo.completed,
    });
  }

  Future<void> deleteTodo(String todoId) {
    return _todosCollection
        .doc(currentUserId)
        .collection('user_todos')
        .doc(todoId)
        .delete();
  }
}



//  class FirestoreService {

  
//   final CollectionReference _todosCollection =
//   FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.email!);


//   Stream<List<Todo>> getTodos() {
//     return _todosCollection.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         return Todo(
//           id: doc.id,
//           title: data['title'],
//           completed: data['completed'],
//         );
//       }).toList();
//     });
//   }

//   Future<void> addTodo(Todo todo) {
//     return _todosCollection.add({
//       'title': todo.title,
//       'completed': todo.completed,
//     });
//   }

//   Future<void> updateTodo(String todoId,Todo todo) {
//     return _todosCollection.doc(todoId).update({
//       'title': todo.title,
//       'completed': todo.completed,
//     });
//   }
//   Future<void> deleteTodo(String todoId) {
//     return _todosCollection.doc(todoId).delete();
//   }
// }