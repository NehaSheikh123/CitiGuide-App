import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminCityFatch extends StatefulWidget {
  const AdminCityFatch({super.key});

  @override
  State<AdminCityFatch> createState() => _AdminCityFatchState();
}

class _AdminCityFatchState extends State<AdminCityFatch> {
  final DatabaseReference citiesRef =
      FirebaseDatabase.instance.ref().child('cities');
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _imageUrl;
  bool _isUploading = false;

  final cloudinary = CloudinaryPublic(
    'djhjm9vtp', 
    'images', 
    cache: false,
  );

  
  List<Map<String, dynamic>> _cities = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    citiesRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final List<Map<String, dynamic>> cities = [];
        data.forEach((key, value) {
          final city = {'key': key, ...Map<String, dynamic>.from(value)};
          cities.add(city);
        });
        setState(() {
          _cities = cities;
        });
      }
    });
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
            folder: 'cities',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      } else {
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _image!.path,
            folder: 'cities',
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

  Future<void> updateCity(String cityKey, String cityName, String cityDesc) async {
    if (cityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      if (_image != null) {
        _imageUrl = await _uploadToCloudinary();
        if (_imageUrl == null) throw Exception('Failed to upload image');
      }

      final cityData = {
        'city': cityName,
        'description': cityDesc,
        'image': _imageUrl ?? '',
      };

      await citiesRef.child(cityKey).update(cityData);

      setState(() {
        _image = null;
        _imageUrl = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> deleteCity(String cityKey) async {
    try {
      await citiesRef.child(cityKey).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting city: $e')),
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> city) {
    final cityController = TextEditingController(text: city['city']);
    final citydesc = TextEditingController(text: city['description']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit City'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: cityController,
                      cursorColor: const Color.fromRGBO(244, 65, 83, 1),
                      decoration: InputDecoration(
                        labelText: "City Name",
                        hintText: "Enter city name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelStyle: TextStyle(color: Colors.grey[900]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: citydesc,
                      minLines: 5,
                      maxLines: 7,
                      cursorColor: const Color.fromRGBO(244, 65, 83, 1),
                      decoration: InputDecoration(
                        labelText: "City Description",
                        hintText: "Enter city Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelStyle: TextStyle(color: Colors.grey[900]),
                      ),
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
                              backgroundColor:
                                  const Color.fromARGB(255, 68, 138, 255),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_imageUrl != null)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.network(_imageUrl!, fit: BoxFit.cover),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
                  },
                  style: TextButton.styleFrom(
                        backgroundColor: Colors.blueAccent, 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: _isUploading
                      ? null
                      : () {
                          updateCity(city['key'], cityController.text,
                              citydesc.text);
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.blueAccent, // Background color
                            foregroundColor: Colors.white, // Text color for contrast
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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
                "Manage Cities",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                "Existing Cities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._cities.map((city) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        city['city'],
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                   
                    if (city['image'] != '')
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage(city['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    
                    if (city['description'] != '')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          city['description'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(city);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteCity(city['key']);
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
