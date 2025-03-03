import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentapp/model/student.dart';
import 'provider/student_provider.dart'; // เพิ่ม provider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => StudentProvider(),
      child: const StudentApp(),
    ),
  );
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}

// HomePage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student App'),
      ),
      body: studentProvider.students.isEmpty
          ? const Center(child: Text('ไม่มีข้อมูลนักเรียน'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: studentProvider.students.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(studentProvider.students[index].name),
                  onDismissed: (direction) {
                    studentProvider.removeStudent(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ลบนักเรียนเรียบร้อย')),
                    );
                  },
                  background: Container(color: Colors.red),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(studentProvider.students[index].name),
                      subtitle: Text(
                        'อายุ: ${studentProvider.students[index].age} | วันเกิด: ${DateFormat('dd/MM/yyyy').format(studentProvider.students[index].birthDate)} | ระดับชั้น: ${studentProvider.students[index].category}',
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// AddPage
class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  DateTime _birthDate = DateTime.now();
  String _category = 'กรุณาเลือกหมวดหมู่';
  final List<String> _categories = ['ประถม', 'มัธยม', 'อุดมศึกษา'];

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final enteredName = _nameController.text;
      final enteredAge = int.tryParse(_ageController.text);
      final enteredGradeLevel = _gradeLevelController.text;

      if (enteredAge == null || enteredAge <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกอายุให้ถูกต้อง')),
        );
        return;
      }

      if (_category == 'กรุณาเลือกหมวดหมู่') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')),
        );
        return;
      }

      final student = Student(
        name: enteredName,
        age: enteredAge,
        birthDate: _birthDate,
        category: _category,
      );

      Provider.of<StudentProvider>(context, listen: false).addStudent(student);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เพิ่มนักเรียน: $enteredName สำเร็จ')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('เพิ่มนักเรียน'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'ชื่อนักเรียน',
                      border: OutlineInputBorder(),
                    ),
                    controller: _nameController,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อนักเรียน';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'อายุ',
                      border: OutlineInputBorder(),
                    ),
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอายุ';
                      }
                      if (int.tryParse(value) == null) {
                        return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text('วันเกิด: ${DateFormat('dd/MM/yyyy').format(_birthDate)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _birthDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) setState(() => _birthDate = picked);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _category == 'กรุณาเลือกหมวดหมู่' ? null : _category,
                    items: _categories
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value!),
                    decoration: const InputDecoration(
                      labelText: 'กรุณาเลือกระดับชั้น',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('กรุณาเลือกระดับชั้น'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาเลือกระดับชั้น';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'เพิ่มนักเรียน',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _gradeLevelController.dispose();
    super.dispose();
  }
}