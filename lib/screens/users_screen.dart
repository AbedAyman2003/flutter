import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'add_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Reference إلى Realtime Database
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // دالة حذف مستخدم
  Future<void> _deleteUser(String userId) async {
    try {
      await _usersRef.child(userId).remove();

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('The user was successfully deleted'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deletion error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة تحديث بيانات المستخدم
  Future<void> _updateUser(String userId, Map userData) async {
    TextEditingController nameController = TextEditingController(text: userData['name']);
    TextEditingController emailController = TextEditingController(text: userData['email']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit user data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                try {
                  await _usersRef.child(userId).update({
                    'name': nameController.text,
                    'email': emailController.text,
                    'updatedAt': DateTime.now().millisecondsSinceEpoch,
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('The data was successfully updated'),
                      backgroundColor: Colors.green.shade700,
                    ),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update error: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Update the list',
          ),
        ],
      ),
      body: Column(
        children: [
          // رأس الصفحة
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(
                  Icons.group,
                  color: Colors.blue,
                  size: 30,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Registered users',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                StreamBuilder<DatabaseEvent>(
                  stream: _usersRef.onValue,
                  builder: (context, snapshot) {
                    int userCount = 0;
                    if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                      final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
                      userCount = data?.length ?? 0;
                    }
                    return Chip(
                      label: Text(
                        '$userCount user',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                    );
                  },
                ),
              ],
            ),
          ),

          // قائمة المستخدمين
          Expanded(
            child: FirebaseAnimatedList(
              query: _usersRef,
              defaultChild: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading user data...'),
                  ],
                ),
              ),
              itemBuilder: (context, snapshot, animation, index) {
                final userData = Map<String, dynamic>.from(snapshot.value as Map);
                final userId = snapshot.key!;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      userData['name'] ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userData['email'] ?? 'No mail'),
                        const SizedBox(height: 4),
                        Text(
                          'Added: ${_formatTimestamp(userData['createdAt'])}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                          onPressed: () => _updateUser(userId, userData),
                          tooltip: 'amendment',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm deletion'),
                                content: const Text('Are you sure you want to delete this user?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('No'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteUser(userId);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Yes, delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'delete',
                        ),
                      ],
                    ),
                    onTap: () {
                      _showUserDetails(userData);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUserScreen()),
          );
        },
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add user'),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'unknown';

    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'unknown';
    }
  }

  void _showUserDetails(Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailRow(icon: Icons.person, text: 'name: ${userData['name']}'),
            const SizedBox(height: 10),
            DetailRow(icon: Icons.email, text: 'email: ${userData['email']}'),
            const SizedBox(height: 10),
            DetailRow(
              icon: Icons.calendar_today,
              text: 'Date Added: ${_formatTimestamp(userData['createdAt'])}',
            ),
            if (userData['updatedAt'] != null)
              Column(
                children: [
                  const SizedBox(height: 10),
                  DetailRow(
                    icon: Icons.update,
                    text: 'Last update: ${_formatTimestamp(userData['updatedAt'])}',
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('closing'),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const DetailRow({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}