import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:citi_guide_app/login.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  String? profileImageURL;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('Users').child(user.uid);
    DataSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      Map userData = snapshot.value as Map;
      setState(() {
        nameController.text = userData['name'] ?? '';
        emailController.text = userData['email'] ?? '';
        phoneController.text = userData['phone'] ?? '';
        profileImageURL = userData['imageUrl']; // Fetching the profile image URL
      });
    }
  }
}


  Future<void> _updateProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await prefs.setString("name", nameController.text);
      await prefs.setString("email", emailController.text);
      await prefs.setString("phone", phoneController.text);

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('Users').child(user.uid);
      await userRef.update({
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in!")),
      );
    }
  }

  // Logout Function
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear any shared preferences data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()), // Navigate to login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
radius: 40,
  backgroundColor: Colors.blue,
  backgroundImage: profileImageURL != null
      ? NetworkImage(profileImageURL!)
      : null,
  child: profileImageURL == null
      ? const Icon(Icons.person, size: 40, color: Colors.white)
      : null,
),
              const SizedBox(height: 10),
              Text(
                nameController.text.isEmpty ? 'Username' : nameController.text,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 20),
              _buildTextField(nameController, 'Name', Icons.person),
              const SizedBox(height: 15),
              _buildTextField(emailController, 'Email', Icons.email),
              const SizedBox(height: 15),
              _buildTextField(phoneController, 'Phone Number', Icons.phone),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _updateProfileData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Save Changes"),
              ),
              const SizedBox(height: 20),
              // Logout Button
              ElevatedButton(
                onPressed: () async {
                  await _logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red for logout
                  foregroundColor: Colors.white,
                ),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blue),
      hintText: hint,
      fillColor: Colors.blue.shade50, 
      filled: true, 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0), 
        borderSide: BorderSide.none, 
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0), 
        borderSide: BorderSide.none, 
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none, 
      ),
    ),
  );
}


}
