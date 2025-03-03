import 'package:flutter/foundation.dart';
import '../model/student.dart'; // เปลี่ยนจาก social_work.dart เป็น student.dart

class StudentProvider with ChangeNotifier {
  final List<Student> _students = [
    Student(
      name: 'น้องหนึ่ง',
      age: 15,
      birthDate: DateTime.now(),
      category: 'มัธยม',
    ),
    Student(
      name: 'น้องสอง',
      age: 12,
      birthDate: DateTime.now(),
      category: 'ประถม',
    ),
  ];

  List<Student> get students => _students;

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void removeStudent(int index) {
    _students.removeAt(index);
    notifyListeners();
  }
}