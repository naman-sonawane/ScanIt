class ScanItem {
  final String id;
  final String imagePath;
  final String itemName;
  final String category; // plastic, glass, compost, landfill, e-waste
  final List<String> reuseIdeas;
  final DateTime scannedAt;
  final int sustainabilityScore;
  final String description;
  final bool isRecyclable;
  final String disposalInstructions;

  ScanItem({
    required this.id,
    required this.imagePath,
    required this.itemName,
    required this.category,
    required this.reuseIdeas,
    required this.scannedAt,
    required this.sustainabilityScore,
    required this.description,
    required this.isRecyclable,
    required this.disposalInstructions,
  });

  factory ScanItem.fromJson(Map<String, dynamic> json) {
    return ScanItem(
      id: json['id'],
      imagePath: json['imagePath'],
      itemName: json['itemName'],
      category: json['category'],
      reuseIdeas: List<String>.from(json['reuseIdeas']),
      scannedAt: DateTime.parse(json['scannedAt']),
      sustainabilityScore: json['sustainabilityScore'],
      description: json['description'],
      isRecyclable: json['isRecyclable'],
      disposalInstructions: json['disposalInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'itemName': itemName,
      'category': category,
      'reuseIdeas': reuseIdeas,
      'scannedAt': scannedAt.toIso8601String(),
      'sustainabilityScore': sustainabilityScore,
      'description': description,
      'isRecyclable': isRecyclable,
      'disposalInstructions': disposalInstructions,
    };
  }

  ScanItem copyWith({
    String? id,
    String? imagePath,
    String? itemName,
    String? category,
    List<String>? reuseIdeas,
    DateTime? scannedAt,
    int? sustainabilityScore,
    String? description,
    bool? isRecyclable,
    String? disposalInstructions,
  }) {
    return ScanItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      reuseIdeas: reuseIdeas ?? this.reuseIdeas,
      scannedAt: scannedAt ?? this.scannedAt,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      description: description ?? this.description,
      isRecyclable: isRecyclable ?? this.isRecyclable,
      disposalInstructions: disposalInstructions ?? this.disposalInstructions,
    );
  }
}
