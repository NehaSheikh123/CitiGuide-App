import 'package:citi_guide_app/attraction_fetch.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _citiesRef =
      FirebaseDatabase.instance.ref().child('cities');
  List<Map<String, dynamic>> cities = [];
  bool isLoading = true;
  String _searchQuery = '';
  Future<void> fetchCities() async {
    try {
      final snapshot = await _citiesRef.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> citiesMap = snapshot.value as Map;
        setState(() {
          cities = citiesMap.entries.map((entry) {
            final data = entry.value as Map;
            return {
              'id': entry.key,
              'city': data['city'],
              'description': data['description'],
              'image': data['image'],
            };
          }).toList();
          isLoading = false; // Data loaded
        });
      } else {
        setState(() {
          isLoading = false; // No data
        });
      }
    } catch (e) {
      print("Error fetching cities: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAttractions = cities.where((item) {
      final matchesSearchQuery =
          item['city']!.toLowerCase().contains(_searchQuery) ||
              item['description']!.toLowerCase().contains(_searchQuery);
      return matchesSearchQuery;
    }).toList();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: "Search City",
                              border: InputBorder.none,
                            ),
                            cursorColor:const Color.fromARGB(255, 0, 149, 255),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Center(
                child: Text("Cities",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
            isLoading
                ? const Center(child: CircularProgressIndicator(color:  Color.fromARGB(255, 0, 149, 255),))
                : cities.isEmpty
                    ? const Center(child: Text("No cities available"))
                    :
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAttractions.length,
              itemBuilder: (context, index) {
                final city = filteredAttractions[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Card(
                    elevation: 9.5,
                    margin: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (city['image'] != null && city['image'].isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              city['image'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city['city'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                city['description'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AttractionFetch(cityId: city['id']),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 0, 149, 255),
                                ),
                                child: const Text("Show Attractions", style: TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
