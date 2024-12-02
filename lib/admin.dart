import 'package:citi_guide_app/admin_attraction_fatch.dart';
import 'package:citi_guide_app/admin_city_fatch.dart';
import 'package:citi_guide_app/review_attraction.dart';
import 'package:flutter/material.dart';
import 'a_category_form.dart';
import 'admin_review_attrctn_fatch.dart';
import 'admin_attraction_form.dart';
import 'admin_user_fatch.dart';
import 'cities_form.dart';

void main() {
  runApp(const AdminPanelApp());
}

class AdminPanelApp extends StatelessWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City Guide Admin',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Admin Attraction Form'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttractionForm(),
                  ),
                );
              },
            ),
  
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Manage Reviews'),
              onTap: () {
                String attractionId = 'example-attraction-id'; 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewAttraction(attractionId: attractionId),
                  ),
                );
              },
            ),
        
            ListTile(
              leading: const Icon(Icons.attractions),
              title: const Text('Manage Attractions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminAttractionFetch(),
                  ),
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.attractions),
              title: const Text('Manage Cities'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CitiesForm(),
                  ),
                );
              },
            ),
               ListTile(
              leading: const Icon(Icons.attractions),
              title: const Text('Category Form'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ACategoryForm(),
                  ),
                );
              },
            ),
           
           
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            
            _buildAdminCard(
              context,
              icon: Icons.place,
              title: 'Attractions',
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminCityFatch(),
                  ),
                );
              },
            ),
        
            _buildAdminCard(
              context,
              icon: Icons.rate_review,
              title: 'Reviews',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminReviewAttrctnFatch(),
                  ),
                );
              },
            ),
                  _buildAdminCard(
              context,
              icon: Icons.person,
              title: 'Registered Users',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminUserFatch(),
                  ),
                );
              },
            ),

              _buildAdminCard(
              context,
              icon: Icons.location_city_rounded,
              title: 'Cities Management',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CitiesForm(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
