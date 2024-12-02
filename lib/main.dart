import 'package:citi_guide_app/aboutUs.dart';
import 'package:citi_guide_app/admin_user_fatch.dart';
import 'package:citi_guide_app/profile_page.dart';
import 'package:citi_guide_app/sign-up.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'admin.dart';
//import 'aboutUs.dart';
//import 'faqs.dart';
import 'a_category_form.dart';
import 'admin.dart';
import 'admin_attraction_fatch.dart';
import 'admin_attraction_form.dart';
import 'admin_city_fatch.dart';
import 'admin_review_attrctn_fatch.dart';
import 'attraction_fetch.dart';
import 'cities_form.dart';
import 'faqs.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'login.dart';
//import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100.0,
          title: Padding(
            padding: const EdgeInsets.only(
              top: 12.0,
              left: 10.0,
            ),
            child: Row(
  children: [
    Padding(
      padding: const EdgeInsets.only(bottom: 30.0), 
      child: Image.network(
        'https://res.cloudinary.com/dgexlc4gh/image/upload/v1733056082/logo_aijv6o.png',
        height: 60,
        width: 60,
        fit: BoxFit.contain,
      ),
    ),
    const SizedBox(width: 25),
  ],
),

          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        ),
        body: const Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 25.0),
          child: HomePage(),
      
        ),
      ),
    );
  }
}
