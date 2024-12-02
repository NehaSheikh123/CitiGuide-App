import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "https://images.pexels.com/photos/18482986/pexels-photo-18482986/free-photo-of-people-at-a-concert-on-a-stadium.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"),
                  opacity: 0.5,
                  fit: BoxFit.cover,
                ),
                color: Colors.black,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Explore Great Places",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0), 
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFE0E0E0), 
                        borderRadius:
                            BorderRadius.circular(30), 
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16.0), 
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search City",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(244, 65, 83, 1),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              )),
                              minimumSize: const Size(
                                  100, 60), 
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16), 
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Search",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),],
        ),
      ),
    );
  }
}