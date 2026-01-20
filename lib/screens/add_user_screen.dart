import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  bool _isLoading = false;

  // التحقق من صحة البريد الإلكتروني
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // التحقق من تكرار البريد الإلكتروني
  Future<bool> isEmailUnique(String email) async {
    try {
      final snapshot = await _usersRef
          .orderByChild('email')
          .equalTo(email.toLowerCase())
          .once();

      return snapshot.snapshot.value == null;
    } catch (error) {
      return true;
    }
  }

  // دالة إضافة مستخدم جديد
  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String name = _nameController.text.trim();
        final String email = _emailController.text.trim().toLowerCase();

        // التحقق من عدم تكرار البريد الإلكتروني
        final bool emailIsUnique = await isEmailUnique(email);

        if (!emailIsUnique) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('This email address is already registered!'),
              backgroundColor: Colors.orange.shade700,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // إنشاء معرف فريد للمستخدم
        final DatabaseReference newUserRef = _usersRef.push();

        // تحضير البيانات للحفظ
        final Map<String, dynamic> userData = {
          'id': newUserRef.key,
          'name': name,
          'email': email,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        };

        // حفظ البيانات في Realtime Database
        await newUserRef.set(userData);

        // عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('The user has been added successfully!'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );

        // مسح الحقول بعد الإضافة
        _nameController.clear();
        _emailController.clear();

        // العودة للقائمة بعد ثانيتين
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });

      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new user'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة أو أيقونة
              Container(
                margin: const EdgeInsets.only(bottom: 30, top: 20),
                child: const Icon(
                  Icons.person_add_alt_1,
                  size: 100,
                  color: Colors.blue,
                ),
              ),

              // حقل الاسم
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'full name',
                  hintText: 'Enter username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.length < 3) {
                    return 'The name must be at least 3 letters long.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // حقل البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@email.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!isValidEmail(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // زر الإضافة
              ElevatedButton(
                onPressed: _isLoading ? null : _addUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 10),
                    Text(
                      'Save user',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // زر الإلغاء
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Colors.blue.shade800),
                ),
                child: const Text(
                  'Cancel and Return',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              // معلومات إضافية
              Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Data is automatically verified and email duplication is avoided.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}