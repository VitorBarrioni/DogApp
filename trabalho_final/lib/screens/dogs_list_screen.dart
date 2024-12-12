import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/dog.dart';
import 'dog_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DogsListScreen extends StatefulWidget {
  const DogsListScreen({super.key});

  @override
  State<DogsListScreen> createState() => _DogsListScreenState();
}

class _DogsListScreenState extends State<DogsListScreen> {
  List<Dog> dogs = [];
  bool isLoading = false;
  String? errorMessage;
  int currentPage = 0;
  final int limit = 12;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    fetchDogs();
  }

  Future<void> fetchDogs() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.thedogapi.com/v1/breeds'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> allData = json.decode(response.body);
        totalPages = (allData.length / limit).ceil();

        final int startIndex = currentPage * limit;
        final int endIndex = (startIndex + limit < allData.length)
            ? startIndex + limit
            : allData.length;

        final pageData = allData.sublist(startIndex, endIndex);
        final List<Dog> newDogs =
            pageData.map((json) => Dog.fromJson(json)).toList();

        for (var dog in newDogs) {
          await fetchDogImages(dog);
        }

        setState(() {
          dogs = newDogs;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load dogs: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> fetchDogImages(Dog dog) async {
    const apiKey = 'YOUR_API_KEY';
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.thedogapi.com/v1/images/search?breed_id=${dog.id}&limit=5'),
        headers: {
          'x-api-key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            dog.images = data
                .map((json) => DogImage.fromJson(json))
                .where((image) => image.isValid)
                .toList();

            if (dog.images.isNotEmpty &&
                (dog.imageUrl.isEmpty || !Uri.parse(dog.imageUrl).isAbsolute)) {
              dog.imageUrl = dog.images.first.url;
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching images for ${dog.name}: $e');
    }
  }

  void nextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
      });
      fetchDogs();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      fetchDogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Dog Breeds',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: errorMessage != null
                ? _buildErrorWidget()
                : isLoading
                    ? _buildLoadingWidget()
                    : _buildGridView(),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: fetchDogs,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Loading dog breeds...',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: dogs.length,
      itemBuilder: (context, index) {
        final dog = dogs[index];
        return _buildDogCard(dog);
      },
    );
  }

  Widget _buildDogCard(Dog dog) {
    return Card(
      elevation: 2,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DogDetailsScreen(dog: dog),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Hero(
                tag: 'dog_${dog.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: dog.bestImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.pets,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  dog.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: currentPage > 0 ? previousPage : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.blue.withOpacity(0.3),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Page ${currentPage + 1} of $totalPages',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: currentPage < totalPages - 1 ? nextPage : null,
            label: const Text('Next'),
            icon: const Icon(Icons.arrow_forward),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
