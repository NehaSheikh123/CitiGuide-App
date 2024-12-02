import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttractionForm extends StatefulWidget {
  const AttractionForm({super.key});

  @override
  State<AttractionForm> createState() => _AttractionFormState();
}

class _AttractionFormState extends State<AttractionForm> {
  final TextEditingController AttractionController = TextEditingController();
  final TextEditingController Attractiondesc = TextEditingController();
  final TextEditingController Attractionlatitude = TextEditingController();
  final TextEditingController Attractionlongitude = TextEditingController();
  final TextEditingController AttractionOpenTime = TextEditingController();
  final TextEditingController AttractionCloseTime = TextEditingController();
  final TextEditingController Link = TextEditingController();
  final DatabaseReference attractionRef =
      FirebaseDatabase.instance.ref().child('attraction');
  final DatabaseReference citiesRef =
      FirebaseDatabase.instance.ref().child('cities');
  final DatabaseReference _categoryRef =
      FirebaseDatabase.instance.ref().child('attraction_category');

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _imageUrl;
  bool _isUploading = false;

  final cloudinary = CloudinaryPublic(
    'djhjm9vtp',
    'images',
    cache: false,
  );

  Map<String, String> _categories = {};
  String? _selectedCategoryKey;
  Map<String, String> _cities = {};
  String? _selectedCityKey;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchCities();
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 182, 238, 255),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await _categoryRef.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> categoriesMap = snapshot.value as Map;
        setState(() {
          _categories = categoriesMap.map(
            (key, value) =>
                MapEntry(key.toString(), value['a_category'].toString()),
          );
        });
      }
    } catch (e) {
      stdout.write('Error fetching categories: $e');
    }
  }

  Future<void> _fetchCities() async {
    try {
      final snapshot = await citiesRef.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> citiesMap = snapshot.value as Map;
        setState(() {
          _cities = citiesMap.map(
            (key, value) => MapEntry(key.toString(), value['city'].toString()),
          );
        });
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<String?> _uploadToCloudinary() async {
    if (_image == null) return null;

    try {
      CloudinaryResponse response;

      if (kIsWeb) {
        final bytes = await _image!.readAsBytes();
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            bytes,
            identifier: 'upload',
            folder: 'attraction',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      } else {
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _image!.path,
            folder: 'attraction',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      }

      return response.secureUrl;
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> addAttraction() async {
    if (AttractionController.text.isEmpty ||
        Link.text.isEmpty ||
        _image == null ||
        _selectedCategoryKey == null ||
        _selectedCityKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please complete all fields and ensure the rating is between 1 and 5'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      _imageUrl = await _uploadToCloudinary();

      if (_imageUrl == null) throw Exception('Failed to upload image');

      await attractionRef.push().set({
        'title': AttractionController.text,
        'open_time': AttractionOpenTime.text,
        'close_time': AttractionCloseTime.text,
        'website_Link': Link.text,
        'image': _imageUrl,
        'description': Attractiondesc.text,
        'latitude': Attractionlatitude.text,
        'longitude': Attractionlongitude.text,
        'category_key': _selectedCategoryKey,
        'city_key': _selectedCityKey,
      });
      AttractionController.clear();
      Attractiondesc.clear();
      Attractionlatitude.clear();
      Attractionlongitude.clear();

      setState(() {
        _image = null;
        _imageUrl = null;
        _selectedCategoryKey = null;
        _selectedCityKey = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attraction added successfully')),
      );
    } on FirebaseException catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add Attraction: ${e.message}')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unknown error: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Attraction Form",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: AttractionController,
                decoration: _buildInputDecoration(
                    "Attraction Name", "Enter Attraction name"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Choose Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 149, 255),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_image != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: kIsWeb
                        ? Image.network(
                            _image!.path,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_image!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: Attractiondesc,
                minLines: 5,
                maxLines: 7,
                decoration: _buildInputDecoration(
                    "Attraction Description", "Enter Attraction Description"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: AttractionOpenTime,
                readOnly: true,
                onTap: () => _pickTime(AttractionOpenTime),
                decoration: _buildInputDecoration(
                    "Attraction Open Time", "Select Attraction Open Time"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: AttractionCloseTime,
                readOnly: true,
                onTap: () => _pickTime(AttractionCloseTime),
                decoration: _buildInputDecoration(
                    "Attraction Close Time", "Select Attraction Close Time"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: Attractionlatitude,
                decoration: _buildInputDecoration(
                    "Attraction Latitude", "Enter Attraction Latitude"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: Attractionlongitude,
                decoration: _buildInputDecoration(
                    "Attraction Longitude", "Enter Attraction Longitude"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: Link,
                decoration: _buildInputDecoration(
                    "Attraction Website Link", "Enter Attraction Website Link"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryKey,
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
                decoration:
                    _buildInputDecoration("Category", "Select a category"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCityKey,
                items: _cities.entries
                    .map((entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCityKey = value;
                  });
                },
                decoration: _buildInputDecoration("City", "Select a City"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isUploading ? null : addAttraction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 149, 255),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color.fromRGBO(227, 242, 253, 1),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(15),
        ),
        labelStyle: TextStyle(color: Colors.grey[900]));
  }
}
