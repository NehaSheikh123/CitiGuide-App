import 'package:flutter/material.dart';

class Faqs extends StatefulWidget {
  const Faqs({super.key});

  @override
  State<Faqs> createState() => _FaqsState();
}

class _FaqsState extends State<Faqs> {
  final List<bool> _isExpanded = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 252, 255),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const SizedBox(height: 20),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            _buildFAQCategory(
              'How do I get around the city?',
              0,
              Icons.restaurant,
              ' The city offers convenient transportation options, including buses, trains, and bike rentals, making it easy to explore all the top attractions.',
            ),
            _buildFAQCategory(
              'How do I book a hotel?',
              1,
              Icons.hotel,
              'Booking a hotel is easy with platforms like Booking.com, Expedia, or Airbnb. These websites allow you to compare prices, check reviews, and make reservations with ease.',
            ),
            _buildFAQCategory(
              'What are the must-visit tourist spots?',
              2,
              Icons.place,
              'Must-visit spots depend on the city, but popular tourist attractions include landmarks like the Eiffel Tower, Great Wall of China, and Machu Picchu. For local recommendations, check online travel blogs and guides.',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCategory(
      String title, int index, IconData questionIcon, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded[index] = !_isExpanded[index];
            });
          },
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          Icon(
                            questionIcon,
                            color: Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth - 50,
                            ),
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Icon(
                    _isExpanded[index] ? Icons.remove : Icons.add,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded[index]) ...[
          const SizedBox(height: 10),
          _buildFAQAnswer(answer),
        ],
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildFAQAnswer(String answer) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 227, 242, 253),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
      child: Text(
        answer,
        style: const TextStyle(
          fontSize: 16,
          color: Color.fromARGB(255, 5, 5, 5),
        ),
      ),
    );
  }
}
