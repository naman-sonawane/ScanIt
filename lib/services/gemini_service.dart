import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;
import '../models/sort_item.dart';

class GeminiService {
  static const String _modelName = 'gemini-1.5-flash';
  static const String _apiKey = '[GEMINI_API_KEY_HERE]';
  late GenerativeModel _model;
  bool _isInitialized = false;

  Future<bool> initialize([String? apiKey]) async {
    try {
      _model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey, // Use hardcoded API key
      );
      _isInitialized = true;
      return true;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  Future<ScanItem?> classifyImage(File imageFile) async {
    if (!_isInitialized) {
      throw Exception(
          'Gemini service not initialized. Please set API key first.');
    }

    try {
      Uint8List imageBytes = await _processImage(imageFile);

      final prompt = '''
Analyze this image and classify the item for proper waste management. 

Please provide a JSON response with the following structure:
{
  "itemName": "Brief name of the item",
  "category": "One of: plastic, glass, compost, landfill, e-waste",
  "description": "Brief description of the item",
  "isRecyclable": true/false,
  "disposalInstructions": "Specific instructions for proper disposal",
  "reuseIdeas": ["Creative reuse idea 1", "Creative reuse idea 2", "Creative reuse idea 3"],
  "sustainabilityScore": 1-25
}

Guidelines for classification:
- plastic: Plastic containers, bottles, packaging
- glass: Glass bottles, jars, containers
- compost: Food waste, organic materials, paper towels
- landfill: Non-recyclable items, contaminated materials
- e-waste: Electronics, batteries, devices

For sustainability score:
- compost: 20 points
- e-waste: 25 points  
- glass: 15 points
- plastic: 10 points
- landfill: 5 points

Provide creative, practical reuse ideas that extend the item's life before disposal.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      return _parseClassificationResponse(responseText, imageFile.path);
    } catch (e) {
      throw Exception('Failed to classify image: $e');
    }
  }

  Future<Uint8List> _processImage(File imageFile) async {
    Uint8List bytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    img.Image resizedImage;
    if (originalImage.width > 1024 || originalImage.height > 1024) {
      resizedImage = img.copyResize(
        originalImage,
        width: originalImage.width > originalImage.height ? 1024 : null,
        height: originalImage.height > originalImage.width ? 1024 : null,
      );
    } else {
      resizedImage = originalImage;
    }

    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));
  }

  ScanItem _parseClassificationResponse(String responseText, String imagePath) {
    try {
      String jsonString = _extractJsonFromResponse(responseText);
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      String id = DateTime.now().millisecondsSinceEpoch.toString();

      return ScanItem(
        id: id,
        imagePath: imagePath,
        itemName: jsonData['itemName'] ?? 'Unknown Item',
        category: jsonData['category']?.toLowerCase() ?? 'landfill',
        reuseIdeas: List<String>.from(jsonData['reuseIdeas'] ?? []),
        scannedAt: DateTime.now(),
        sustainabilityScore: jsonData['sustainabilityScore'] ?? 5,
        description: jsonData['description'] ?? 'No description available',
        isRecyclable: jsonData['isRecyclable'] ?? false,
        disposalInstructions: jsonData['disposalInstructions'] ??
            'Dispose according to local guidelines',
      );
    } catch (e) {
      return ScanItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        itemName: 'Unknown Item',
        category: 'landfill',
        reuseIdeas: [
          'Consider if this item can be repaired',
          'Check if local recycling accepts this material',
          'Look for creative reuse opportunities'
        ],
        scannedAt: DateTime.now(),
        sustainabilityScore: 5,
        description:
            'Unable to classify this item. Please dispose according to local guidelines.',
        isRecyclable: false,
        disposalInstructions:
            'Dispose according to local waste management guidelines.',
      );
    }
  }

  String _extractJsonFromResponse(String responseText) {
    int startIndex = responseText.indexOf('{');
    int endIndex = responseText.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return responseText.substring(startIndex, endIndex + 1);
    }

    return '''
    {
      "itemName": "Unknown Item",
      "category": "landfill",
      "description": "Unable to classify this item",
      "isRecyclable": false,
      "disposalInstructions": "Dispose according to local guidelines",
      "reuseIdeas": ["Consider repair", "Check local recycling", "Look for reuse opportunities"],
      "sustainabilityScore": 5
    }
    ''';
  }

  bool get isInitialized => _isInitialized;
}
