import 'dart:io';
import 'package:citi_guide_app/review_attraction.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AttractionFetch extends StatefulWidget {
  final String? cityId;

  const AttractionFetch({super.key, this.cityId});

  @override
  State<AttractionFetch> createState() => _AttractionState();
}

class _AttractionState extends State<AttractionFetch> {
  final DatabaseReference _categoryRef =
      FirebaseDatabase.instance.ref().child('attraction_category');
  final DatabaseReference attractionRef =
      FirebaseDatabase.instance.ref().child('attraction');
  final DatabaseReference attractionReviewRef =
      FirebaseDatabase.instance.ref().child('review_attraction');
  Map<String, String> _categories = {};
  String? _selectedCategoryKey;
  String _searchQuery = '';
  List<Map<String, dynamic>> _attractions = [];
  bool _isLoading = false;
  String _sortOption = 'Highest Rated';

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await _categoryRef.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> categoriesMap = snapshot.value as Map;
        setState(() {
          _categories = categoriesMap.map((key, value) =>
              MapEntry(key.toString(), value['a_category'].toString()));
        });
      }
    } catch (e) {
      stdout.write('Error fetching categories: $e');
    }
  }

  Future<void> _fetchAttractions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final attractionsSnapshot = await attractionRef.get();
      final reviewsSnapshot = await attractionReviewRef.get();

      if (attractionsSnapshot.exists) {
        final Map<dynamic, dynamic> attractionsMap =
            attractionsSnapshot.value as Map;

        Map<String, List<int>> attractionRatings = {};

        if (reviewsSnapshot.exists) {
          final Map<dynamic, dynamic> reviewsMap = reviewsSnapshot.value as Map;
          for (var review in reviewsMap.values) {
            final attractionId = review['attraction'] as String;
            final rating = (review['rating'] as num).toInt();
            attractionRatings.putIfAbsent(attractionId, () => []).add(rating);
          }
        }

        setState(() {
          _attractions = attractionsMap.entries.where((entry) {
            if (widget.cityId != null) {
              return entry.value['city_key'] == widget.cityId;
            } else {
              return true;
            }
          }).map((entry) {
            final ratings = attractionRatings[entry.key] ?? [];
            final averageRating = ratings.isNotEmpty
                ? ratings.reduce((a, b) => a + b) / ratings.length
                : 0.0;

            return {
              'id': entry.key,
              'title': entry.value['title'],
              'description': entry.value['description'],
              'image': entry.value['image'],
              'category_key': entry.value['category_key'],
              'latitude': entry.value['latitude'],
              'longitude': entry.value['longitude'],
              'average_rating': averageRating,
            };
          }).toList();
        });
      }
    } catch (e) {
      stdout.write('Error fetching attractions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMapPopup(String? latitude, String? longitude) {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid location data')),
      );
      return;
    }

    try {
      final double lat = double.parse(latitude);
      final double lng = double.parse(longitude);

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 18,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('selectedLocation'),
                  position: LatLng(lat, lng),
                ),
              },
              mapType: MapType.normal,
              buildingsEnabled: true,
              indoorViewEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                controller.setMapStyle(null);
              },
            ),
          );
        },
      );
    } catch (e) {
      print('Error parsing location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error displaying location: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAttractions();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAttractions = _attractions.where((item) {
      final matchesCategory = _selectedCategoryKey == null ||
          item['category_key'] == _selectedCategoryKey;
      final matchesSearchQuery =
          item['title']!.toLowerCase().contains(_searchQuery) ||
              item['description']!.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearchQuery;
    }).toList();

    if (_sortOption == 'Highest Rated') {
      filteredAttractions.sort((a, b) => (b['average_rating'] as double)
          .compareTo(a['average_rating'] as double));
    } else if (_sortOption == 'Lowest Rated') {
      filteredAttractions.sort((a, b) => (a['average_rating'] as double)
          .compareTo(b['average_rating'] as double));
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search attractions...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    cursorColor: const Color.fromARGB(255, 0, 149, 255),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 149, 255),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: DropdownButton<String>(
                      dropdownColor: const Color.fromARGB(255, 0, 149, 255),
                      value: _selectedCategoryKey,
                      hint: const Text(
                        'Category',
                        style: TextStyle(color: Colors.white),
                      ),
                      items: _categories.entries
                          .map((entry) => DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryKey = value;
                        });
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      iconSize: 24,
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 149, 255),
            borderRadius: BorderRadius.circular(12),
          ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortOption,
          items: const [
            DropdownMenuItem(
              value: 'Highest Rated',
              child: Text(
                'Highest Rated',
                style: TextStyle(color: Colors.white),

              ),
            ),
            DropdownMenuItem(
              value: 'Lowest Rated',
              child: Text(
                'Lowest Rated',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _sortOption = value!;
            });
          },
          dropdownColor: const Color.fromARGB(255, 0, 149, 255), // Dropdown menu background color
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white, // Icon color
          ),
          style: const TextStyle(
            color: Colors.white, // Dropdown text color
            fontSize: 16,
          ),
        ),
            ),
          ),
      ),
    _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 0, 149, 255),
                ))
              : filteredAttractions.isEmpty
                  ? const Center(
                      child: Text(
                        "No attractions found",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: filteredAttractions.length,
                          itemBuilder: (context, index) {
                            final item = filteredAttractions[index];
                            return Card(
                              elevation: 12,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      item['image']!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']!,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item['description']!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color:
                                                Color.fromARGB(255, 70, 70, 70),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 20),
                                            const SizedBox(width: 4),
                                            Text(
                                              item['average_rating']!
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _showMapPopup(
                                                      item['latitude'],
                                                      item['longitude']);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 0, 149, 255),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "View Location",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReviewAttraction(
                                                              attractionId:
                                                                  item['id']),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 0, 149, 255),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Review",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
        ],
      ),
    );
  }
}