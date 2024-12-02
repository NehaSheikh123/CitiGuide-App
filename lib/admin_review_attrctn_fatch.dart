import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminReviewAttrctnFatch extends StatefulWidget {
  const AdminReviewAttrctnFatch({super.key});

  @override
  State<AdminReviewAttrctnFatch> createState() => _AdminReviewAttrctnFatchState();
}

class _AdminReviewAttrctnFatchState extends State<AdminReviewAttrctnFatch> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('review_attraction');
  List<Map<String, dynamic>> reviews = [];

  
  Future<void> fetchReviews() async {
    try {
      final snapshot = await _databaseReference.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> reviewMap = snapshot.value as Map;
        setState(() {
          reviews = reviewMap.entries
              .map((entry) => {
                    'user': entry.value['user'],
                    'rating': entry.value['rating'],
                    'review': entry.value['review'],
                    'attraction': entry.value['attraction'],
                    'id': entry.key, 
                  })
              .toList();
        });
      }
    } catch (e) {
      stdout.write('Error fetching reviews: $e');
    }
  }


  Future<void> deleteReview(String reviewId) async {
    try {
      await _databaseReference.child(reviewId).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully!')),
      );
      fetchReviews(); 
    } catch (e) {
      print('Error deleting review: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Review Management'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Reviews:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              reviews.isEmpty
                  ? const Text('No reviews yet.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${review['user']} - ${review['rating']}★',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  review['review'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        deleteReview(review['id']);
                                      },
                                    ),
                                  ],
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
      ),
    );
  }
}
