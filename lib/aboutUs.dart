import 'package:citi_guide_app/contactus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 252, 255),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            Text(
              'About Us',
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Welcome to our app! We are dedicated to making your city exploration experience extraordinary. '
                'Our platform is your ultimate guide to discovering the best places to eat, visit, and enjoy in the city.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 5, 5, 5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
    const SizedBox(height: 25),
           
            Text(
              'Explore. Discover. Experience..',
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 18,
             
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

         
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(227, 242, 253, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Choose Us?',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '✔ Personalized recommendations to suit your tastes.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 5, 5, 5),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '✔ Real-time updates and reviews from trusted users.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 5, 5, 5),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '✔ Seamless navigation and easy-to-use interface.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 5, 5, 5),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '✔ A community of explorers sharing their experiences.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 5, 5, 5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

         
            const Divider(
              color: Color.fromARGB(255, 182, 238, 255),
              thickness: 2,
              indent: 50,
              endIndent: 50,
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Ready to Explore?',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Join thousands of users who trust us to make their city adventures unforgettable. Start your journey today!',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 5, 5, 5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

         
            ElevatedButton(
  onPressed: () {
    // Navigate to the Contactus page when the button is clicked
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Contactus()),
    );
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
    backgroundColor: const Color.fromARGB(255, 0, 149, 255),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 5,
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  child: const Text('Contact Us'),
),


            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
