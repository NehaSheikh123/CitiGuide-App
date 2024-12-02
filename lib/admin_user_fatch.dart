import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminUserFatch extends StatefulWidget {
  const AdminUserFatch({super.key});

  @override
  State<AdminUserFatch> createState() => _AdminUserFatchState();
}

class _AdminUserFatchState extends State<AdminUserFatch> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('Users');

  List<Map<String, dynamic>> _usersList = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      DatabaseEvent event = await _usersRef.once();

      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

        List<Map<String, dynamic>> users = [];
        data.forEach((key, value) {
          users.add({
            'uid': key,
            'name': value['name'],
            'email': value['email'],
            'phone': value['phone'],
            'imageUrl': value['imageUrl'],
          });
        });

        setState(() {
          _usersList = users;
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Users',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          )),
        backgroundColor: Color.fromARGB(0, 182, 238, 255),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        centerTitle: true,
      ),
      body: _usersList.isEmpty
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              itemCount: _usersList.length,
              itemBuilder: (context, index) {
                var user = _usersList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['imageUrl'] ?? 'https://via.placeholder.com/150'),
                    ),
                    title: Text(user['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      
                        Text("Email: ${user['email']}"),
                        const SizedBox(height: 5),
                    
                        Text("Phone: ${user['phone']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
