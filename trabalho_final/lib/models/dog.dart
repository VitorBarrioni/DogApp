class DogImage {
  final String id;
  final String url;
  final int width;
  final int height;

  DogImage({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
  });

  factory DogImage.fromJson(Map<String, dynamic> json) {
    return DogImage(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }

  bool get isValid =>
      url.isNotEmpty && Uri.parse(url).isAbsolute && width > 0 && height > 0;
}

class Dog {
  final String id;
  final String name;
  final String breedGroup;
  final String temperament;
  String imageUrl;
  final String lifeSpan;
  List<DogImage> images;

  Dog({
    required this.id,
    required this.name,
    required this.breedGroup,
    required this.temperament,
    required this.imageUrl,
    required this.lifeSpan,
    this.images = const [],
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      breedGroup: json['breed_group'] ?? '',
      temperament: json['temperament'] ?? 'No information available',
      imageUrl: json['image']?['url'] ?? '',
      lifeSpan: json['life_span'] ?? 'Unknown',
    );
  }

  String get bestImageUrl {
    // First try the images array for valid images
    if (images.isNotEmpty) {
      final validImage = images.firstWhere(
        (img) => img.isValid,
        orElse: () => DogImage(id: '', url: '', width: 0, height: 0),
      );
      if (validImage.isValid) return validImage.url;
    }

    // Then try the main imageUrl
    if (imageUrl.isNotEmpty && Uri.parse(imageUrl).isAbsolute) {
      return imageUrl;
    }

    // Fallback to a placeholder
    return 'https://via.placeholder.com/300x300?text=${Uri.encodeComponent(name)}';
  }
}
