import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/user_stats.dart';
import '../models/sort_item.dart';
import '../services/data_storage.dart';
import '../services/gemini_service.dart';
import '../services/theme_provider.dart';
import 'result_screen.dart';
import 'score_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final DataStorage _dataStorage = DataStorage();
  final GeminiService _geminiService = GeminiService();
  UserStats _userStats = UserStats.initial();
  bool _isLoading = false;
  int _selectedIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
    _initializeGemini();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/gallery');
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/score');
    }
  }

  Future<void> _loadUserStats() async {
    final stats = await _dataStorage.getUserStats();
    setState(() {
      _userStats = stats;
    });
  }

  Future<void> _initializeGemini() async {
    await _geminiService.initialize(); // No API key needed since it's hardcoded
  }

  Future<void> _takePhoto() async {
    if (!_geminiService.isInitialized) {
      await _initializeGemini();
      if (!_geminiService.isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize AI service. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (photo != null) {
      await _processImage(File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    if (!_geminiService.isInitialized) {
      await _initializeGemini();
      if (!_geminiService.isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize AI service. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      await _processImage(File(image.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ScanItem? sortItem = await _geminiService.classifyImage(imageFile);

      if (sortItem != null) {
        await _dataStorage.saveScanItem(sortItem);

        await _dataStorage.updateUserStats(sortItem);

        await _loadUserStats();

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(sortItem: sortItem),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(const Color(0xFF232526), const Color(0xFF7F53AC),
                        _controller.value)!,
                    Color.lerp(const Color(0xFF7F53AC), const Color(0xFF647DEE),
                        _controller.value)!,
                  ],
                ),
              ),
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyzing your item...',
                          style: TextStyle(
                              fontFamily: 'Caveat', color: Colors.white)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ScaleTransition(
                                scale: Tween(begin: 1.0, end: 1.2).animate(
                                    CurvedAnimation(
                                        parent: _controller,
                                        curve: Curves.easeInOut)),
                                child: const Icon(
                                  Icons.eco,
                                  size: 48,
                                  color: Color(0xFF7F53AC),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Welcome to ScanIt!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Caveat',
                                      color: Colors.amber,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                                  return Text(
                                    'Take a photo of any item to learn how to sort it properly and discover creative reuse ideas.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Caveat',
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black87),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Take Photo',
                                  style: TextStyle(fontFamily: 'Caveat')),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return ElevatedButton.icon(
                                  onPressed: _pickFromGallery,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Gallery',
                                      style: TextStyle(fontFamily: 'Caveat')),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: themeProvider.isDarkMode
                                        ? Colors.deepPurple[200]
                                        : Colors.deepPurple[100],
                                    foregroundColor: themeProvider.isDarkMode
                                        ? Colors.black87
                                        : Colors.deepPurple[900],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Progress',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Caveat',
                                      color: Colors.amber,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatItem(
                                      'Total Score',
                                      '${_userStats.totalScore}',
                                      Icons.star,
                                      Colors.amber,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStatItem(
                                      'Items Sorted',
                                      '${_userStats.itemsSorted}',
                                      Icons.recycling,
                                      Colors.blue,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStatItem(
                                      'Level',
                                      _userStats.sustainabilityLevel,
                                      Icons.emoji_events,
                                      Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              'View Score',
                              Icons.analytics,
                              Colors.green,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScoreScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionCard(
                              'History',
                              Icons.history,
                              Colors.orange,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HistoryScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Caveat',
              ),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontFamily: 'Caveat'),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Caveat',
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
