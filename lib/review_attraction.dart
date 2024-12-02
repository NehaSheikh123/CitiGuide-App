import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ReviewAttraction extends StatefulWidget {
  final String? attractionId;
  const ReviewAttraction({super.key, required this.attractionId});

  @override
  State<ReviewAttraction> createState() => _ReviewAttractionState();
}

class _ReviewAttractionState extends State<ReviewAttraction> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('review_attraction');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;
  List<Map<String, dynamic>> reviews = [];

  // Fetch reviews from Firebase
  Future<void> fetchReviews() async {
    try {
      final snapshot = await _databaseReference.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> reviewMap = snapshot.value as Map;
        setState(() {
          reviews = reviewMap.entries
              .where(
                  (entry) => entry.value['attraction'] == widget.attractionId)
              .map((entry) => {
                    'key': entry.key,
                    'user': entry.value['user'],
                    'rating': entry.value['rating'],
                    'review': entry.value['review'],
                    'attraction': entry.value['attraction'],
                    'likes': entry.value['likes'] ?? 0,
                  })
              .toList();
        });
      }
    } catch (e) {
      stdout.write('Error fetching reviews: $e');
    }
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final reviewText = _reviewController.text;

      try {
        await _databaseReference.push().set({
          'user': name,
          'rating': _rating,
          'review': reviewText,
          'attraction': widget.attractionId,
          'likes': 0, // Initialize with 0 likes
        });
        _nameController.clear();
        _reviewController.clear();
        setState(() {
          _rating = 3.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );

        await fetchReviews();
      } catch (e) {
        print('Error submitting review: $e');
      }
    }
  }

  Future<void> _likeReview(String reviewKey, int currentLikes) async {
    try {
      await _databaseReference
          .child(reviewKey)
          .update({'likes': currentLikes + 1});
      fetchReviews(); // Refresh the reviews
    } catch (e) {
      print('Error liking review: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Widget buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = (index + 1).toDouble();
            });
          },
          icon: Icon(
            Icons.star,
            color: index < _rating ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Attraction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submit a Review',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 30, 30, 30)),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _reviewController,
                          decoration: const InputDecoration(
                            labelText: 'Review',
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 30, 30, 30)),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your review'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'Rating:',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            buildStarRating(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submitReview,
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 149, 255),),
                          child: const Text(
                            'Submit Review',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Text(
                'Reviews:',
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
                                  children: [
                                    IconButton(
                                      onPressed: () => _likeReview(
                                          review['key'], review['likes']),
                                      icon: const Icon(Icons.thumb_up),
                                      color: Colors.blue,
                                    ),
                                    Text('${review['likes']} likes'),
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
