import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_stats.dart';
import '../services/data_storage.dart';
import '../services/theme_provider.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final DataStorage _dataStorage = DataStorage();
  UserStats _userStats = UserStats.initial();

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final stats = await _dataStorage.getUserStats();
    setState(() {
      _userStats = stats;
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'compost':
        return Colors.brown;
      case 'glass':
        return Colors.blue;
      case 'plastic':
        return Colors.orange;
      case 'e-waste':
        return Colors.red;
      case 'landfill':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sustainability Score',
            style: TextStyle(fontFamily: 'Caveat')),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserStats,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: themeProvider.isDarkMode
                      ? const [
                          Color(0xFF232526),
                          Color(0xFF7F53AC),
                          Color(0xFF647DEE)
                        ]
                      : const [
                          Color(0xFFE3F2FD),
                          Color(0xFFF3E5F5),
                          Color(0xFFE8EAF6)
                        ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: 64,
                              color: Colors.amber,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userStats.sustainabilityLevel,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_userStats.totalScore} points',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4CAF50),
                                  ),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: _getProgressValue(),
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4CAF50)),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return Text(
                                  '${_getNextLevelPoints()} points to next level',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: themeProvider.isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Items Sorted',
                            '${_userStats.itemsSorted}',
                            Icons.recycling,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Average Score',
                            '${_userStats.averageScore.toStringAsFixed(1)}',
                            Icons.star,
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Streak Days',
                            '${_userStats.streakDays}',
                            Icons.local_fire_department,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Achievements',
                            '${_userStats.achievements.length}',
                            Icons.workspace_premium,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category Breakdown',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            ..._userStats.categoryCounts.entries.map((entry) {
                              String category = entry.key;
                              int count = entry.value;
                              double percentage = _userStats.itemsSorted > 0
                                  ? (count / _userStats.itemsSorted) * 100
                                  : 0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(category),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            category.toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          '$count items',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          _getCategoryColor(category)),
                                      minHeight: 4,
                                    ),
                                    const SizedBox(height: 4),
                                    Consumer<ThemeProvider>(
                                      builder: (context, themeProvider, child) {
                                        return Text(
                                          '${percentage.toStringAsFixed(1)}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: themeProvider.isDarkMode
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_userStats.achievements.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Achievements',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              ..._userStats.achievements
                                  .map((achievement) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.workspace_premium,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                achievement,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Card(
                          color: themeProvider.isDarkMode
                              ? Colors.deepPurple[700]?.withOpacity(0.8)
                              : Colors.deepPurple[100]?.withOpacity(0.8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_outline,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Tips to Improve Your Score',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Caveat',
                                              color: Colors.amber,
                                            ),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...[
                                  'Compost food waste and organic materials (+20 points)',
                                  'Properly dispose of e-waste (+25 points)',
                                  'Recycle glass and plastic (+15-10 points)',
                                  'Sort items daily to maintain your streak',
                                  'Look for creative reuse opportunities before disposal',
                                ].map((tip) => _buildTip(tip)).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 500),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontFamily: 'Caveat',
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 18,
                      ),
                  child: Text(tip),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _getProgressValue() {
    if (_userStats.totalScore >= 1000) return 1.0;
    if (_userStats.totalScore >= 500) return 0.8;
    if (_userStats.totalScore >= 200) return 0.6;
    if (_userStats.totalScore >= 50) return 0.4;
    return _userStats.totalScore / 50;
  }

  int _getNextLevelPoints() {
    if (_userStats.totalScore >= 1000) return 0;
    if (_userStats.totalScore >= 500) return 1000 - _userStats.totalScore;
    if (_userStats.totalScore >= 200) return 500 - _userStats.totalScore;
    if (_userStats.totalScore >= 50) return 200 - _userStats.totalScore;
    return 50 - _userStats.totalScore;
  }
}
