import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/dog.dart';

class DogDetailsScreen extends StatelessWidget {
  final Dog dog;

  const DogDetailsScreen({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                dog.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Hero(
                tag: 'dog_${dog.id}',
                child: CachedNetworkImage(
                  imageUrl: dog.bestImageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 1200,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('Error loading image: $url - $error');
                    return Container(
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.pets,
                        size: 100,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoSection('Breed Group', dog.breedGroup),
                const SizedBox(height: 16),
                _buildInfoSection('Temperament', dog.temperament),
                const SizedBox(height: 16),
                _buildInfoSection('Life Span', dog.lifeSpan),
                if (dog.images.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'More Photos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dog.images.length,
                      itemBuilder: (context, index) {
                        final image = dog.images[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: image.url,
                              width: 200,
                              fit: BoxFit.cover,
                              memCacheWidth: 400,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print('Error loading thumbnail: $url - $error');
                                return Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.pets,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Blue accent color
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
