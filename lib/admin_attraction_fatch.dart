import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminAttractionFetch extends StatefulWidget {
  const AdminAttractionFetch({super.key});

  @override
  State<AdminAttractionFetch> createState() => _AdminAttractionFetchState();
}

class _AdminAttractionFetchState extends State<AdminAttractionFetch> {
  final DatabaseReference attractionRef =
      FirebaseDatabase.instance.ref().child('attraction');
  final ImagePicker _picker = ImagePicker();
  final cloudinary = CloudinaryPublic('djhjm9vtp', 'images', cache: false);

  List<Map<String, dynamic>> attractions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttractions();
  }

  Future<void> fetchAttractions() async {
    try {
      final snapshot = await attractionRef.get();
      if (snapshot.value == null) {
        setState(() {
          attractions = [];
          isLoading = false;
        });
        print('No data available');
        return;
      }

      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

      setState(() {
        attractions = data.entries.map((entry) {
          final value = Map<String, dynamic>.from(entry.value);
          return {
            'key': entry.key,
            ...value,
            'opening_hour': value['open_time'], 
            'closing_hour': value['close_time'], 
            'website_url': value['website_Link'], 
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching attractions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteAttraction(String key) async {
    try {
      await attractionRef.child(key).remove();
      setState(() {
        attractions.removeWhere((attraction) => attraction['key'] == key);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attraction deleted successfully')),
      );
    } catch (e) {
      print('Error deleting attraction: $e');
    }
  }

  Future<void> openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the URL')),
      );
    }
  }

  Future<void> showEditDialog(Map<String, dynamic> attraction) async {
    final TextEditingController titleController =
        TextEditingController(text: attraction['title']);
    final TextEditingController descriptionController =
        TextEditingController(text: attraction['description']);
    final TextEditingController openingHourController =
        TextEditingController(text: attraction['opening_hour']);
    final TextEditingController closingHourController =
        TextEditingController(text: attraction['closing_hour']);
    final TextEditingController websiteUrlController =
        TextEditingController(text: attraction['website_url']);
    String updatedImageUrl = attraction['image'];

    Future<void> selectAndUploadImage() async {
      try {
        final XFile? pickedImage =
            await _picker.pickImage(source: ImageSource.gallery);

        if (pickedImage != null) {
          final uploadResult = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(pickedImage.path),
          );
          setState(() {
            updatedImageUrl = uploadResult.secureUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully')),
          );
        }
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Attraction'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: openingHourController,
                  decoration: const InputDecoration(labelText: 'Opening Hour'),
                ),
                TextField(
                  controller: closingHourController,
                  decoration: const InputDecoration(labelText: 'Closing Hour'),
                ),
                TextField(
                  controller: websiteUrlController,
                  decoration: const InputDecoration(labelText: 'Website URL'),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: selectAndUploadImage,
                  child: updatedImageUrl.isEmpty
                      ? const Icon(Icons.image, size: 80)
                      : Image.network(
                          updatedImageUrl,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tap on the image to upload a new one',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
  onPressed: () {
    Navigator.pop(context);
  },
  style: TextButton.styleFrom(
    backgroundColor: Colors.blueAccent, // Background color
    foregroundColor: Colors.white, // Text color for contrast
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  child: const Text('Cancel'),
),
TextButton(
  onPressed: () async {
    final updatedAttraction = {
      'title': titleController.text,
      'description': descriptionController.text,
      'open_time': openingHourController.text,
      'close_time': closingHourController.text,
      'website_Link': websiteUrlController.text,
      'image': updatedImageUrl,
    };

    try {
      await attractionRef
          .child(attraction['key'])
          .update(updatedAttraction);
      setState(() {
        attraction['title'] = titleController.text;
        attraction['description'] = descriptionController.text;
        attraction['opening_hour'] = openingHourController.text;
        attraction['closing_hour'] = closingHourController.text;
        attraction['website_url'] = websiteUrlController.text;
        attraction['image'] = updatedImageUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attraction updated successfully')),
      );
    } catch (e) {
      print('Error updating attraction: $e');
    }

    Navigator.pop(context);
  },
  style: TextButton.styleFrom(
    backgroundColor: Colors.blueAccent, // Background color
    foregroundColor: Colors.white, // Text color for contrast
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  child: const Text('Save'),
),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Attractions',
        style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),),
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : attractions.isEmpty
              ? const Center(child: Text('No attractions available'))
              : ListView.builder(
                  itemCount: attractions.length,
                  itemBuilder: (context, index) {
                    final attraction = attractions[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attraction['title'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                attraction['image'],
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(attraction['description']),
                            const SizedBox(height: 10),
                            Text(
                                'Opening Hour: ${attraction['opening_hour'] ?? "Not available"}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            Text(
                                'Closing Hour: ${attraction['closing_hour'] ?? "Not available"}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                if (attraction['website_url'] != null &&
                                    attraction['website_url'].isNotEmpty) {
                                  openUrl(attraction['website_url']);
                                }
                              },
                              child: Text(
                                'Website: ${attraction['website_url'] ?? "Not available"}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => showEditDialog(attraction),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      deleteAttraction(attraction['key']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
