import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentapp/model/student.dart';
import '../provider/student_provider.dart'; // ตรวจสอบว่ามีไฟล์นี้

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  DateTime? _birthDate; // เปลี่ยนเป็น nullable เพื่อบังคับเลือกวันที่
  String? _category; // เปลี่ยนเป็น nullable เพื่อบังคับเลือกหมวดหมู่
  final List<String> _categories = ['ประถม', 'มัธยม', 'อุดมศึกษา'];

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _submitData() {
    if (_formKey.currentState!.validate() && _birthDate != null && _category != null) {
      final enteredName = _nameController.text;
      final enteredAge = int.parse(_ageController.text); // มั่นใจว่าแปลงได้เพราะ validator ผ่านแล้ว

      final student = Student(
        name: enteredName,
        age: enteredAge,
        birthDate: _birthDate!,
        category: _category!,
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
                  if (value.length < 2) {
                    return 'ชื่อต้องมีอย่างน้อย 2 ตัวอักษร';
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
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 100) {
                    return 'อายุต้องอยู่ระหว่าง 1-100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _birthDate == null
                      ? 'เลือกวันเกิด'
                      : 'วันเกิด: ${DateFormat('dd/MM/yyyy').format(_birthDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('กรุณาเลือกระดับชั้น'),
                validator: (value) {
                  if (value == null) {
                    return 'กรุณาเลือกระดับชั้น';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: (_birthDate == null || _category == null)
                        ? null
                        : _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'เพิ่มนักเรียน',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ยกเลิก',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}