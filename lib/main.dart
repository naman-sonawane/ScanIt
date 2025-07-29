import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/score_screen.dart';
import 'screens/settings_screen.dart';
import 'services/data_storage.dart';
import 'services/theme_provider.dart';
import 'models/user_stats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ScanItApp());
}

class ScanItApp extends StatelessWidget {
  const ScanItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ScanIt - Sustainability App',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: _GradientBackground(child: MainNavShell()),
          );
        },
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  final Widget child;
  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF232526),
                  Color(0xFF7F53AC),
                  Color(0xFF647DEE),
                ]
              : const [
                  Color(0xFFE3F2FD),
                  Color(0xFFF3E5F5),
                  Color(0xFFE8EAF6),
                ],
        ),
      ),
      child: child,
    );
  }
}

class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key});
  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _backgroundController;
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;

  final List<Widget> _pages = [
    HomeScreen(),
    HistoryScreen(),
    ScoreScreen(), // Will be renamed to ProfileScreen in the future
    GraphScreen(), // To be implemented
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.forward().then((_) {
        _pageController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            final themeProvider =
                Provider.of<ThemeProvider>(context, listen: false);
            final isDark = themeProvider.isDarkMode;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color.lerp(
                              const Color(0xFF232526),
                              const Color(0xFF7F53AC),
                              _backgroundController.value)!,
                          Color.lerp(
                              const Color(0xFF7F53AC),
                              const Color(0xFF647DEE),
                              _backgroundController.value)!,
                        ]
                      : [
                          Color.lerp(
                              const Color(0xFFE3F2FD),
                              const Color(0xFFF3E5F5),
                              _backgroundController.value)!,
                          Color.lerp(
                              const Color(0xFFF3E5F5),
                              const Color(0xFFE8EAF6),
                              _backgroundController.value)!,
                        ],
                ),
              ),
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                ),
              );
            },
            child: _pages[_selectedIndex],
          ),
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: BottomNavigationBar(
              backgroundColor: Colors.deepPurple[900]?.withOpacity(0.8),
              selectedItemColor: Colors.amber,
              unselectedItemColor: Colors.white70,
              selectedLabelStyle: const TextStyle(fontFamily: 'Caveat'),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Caveat'),
              currentIndex: _selectedIndex,
              onTap: _onNavBarTap,
              type: BottomNavigationBarType.fixed,
              elevation: 8,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  label: 'Graph',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _chartController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  UserStats? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeInOut),
    );

    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final dataStorage = DataStorage();
    final stats = await dataStorage.getUserStats();
    setState(() {
      _userStats = stats;
      _isLoading = false;
    });

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
              ? Colors.amber
              : Colors.deepPurple,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Your Sustainability Stats',
                          textStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .isDarkMode
                                ? Colors.white
                                : Colors.black87,
                            fontFamily: 'Caveat',
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildOverallStats(),
                  const SizedBox(height: 24),
                  _buildCategoryChart(),
                  const SizedBox(height: 24),
                  _buildProgressIndicators(),
                  const SizedBox(height: 24),
                  _buildAchievementsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStats() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_chartAnimation.value * 0.2),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Score',
                  '${_userStats!.totalScore}',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Items Sorted',
                  '${_userStats!.itemsSorted}',
                  Icons.recycling,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Streak Days',
                  '${_userStats!.streakDays}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(isDark ? 0.2 : 0.1),
              color.withOpacity(isDark ? 0.1 : 0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: 'Caveat',
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                fontFamily: 'Caveat',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart() {
    final categoryData = _userStats!.categoryCounts.entries.toList();
    final totalItems = _userStats!.itemsSorted;

    if (totalItems == 0) {
      return Card(
        elevation: 8,
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'No data to display yet.\nStart sorting items to see your progress!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: 'Caveat',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Card(
          elevation: 8,
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category Distribution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Caveat',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: categoryData.map((entry) {
                        final percentage = totalItems > 0
                            ? (entry.value / totalItems) * 100
                            : 0.0;
                        return PieChartSectionData(
                          color: _getCategoryColor(entry.key),
                          value: entry.value.toDouble() * _chartAnimation.value,
                          title: '${entry.value}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Caveat',
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: categoryData.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.key.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontFamily: 'Caveat',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicators() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Card(
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Caveat',
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressBar(
                  'Sustainability Level',
                  _userStats!.sustainabilityLevel,
                  _getLevelProgress(_userStats!.totalScore),
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildProgressBar(
                  'Average Score',
                  '${_userStats!.averageScore.toStringAsFixed(1)}',
                  (_userStats!.averageScore / 100).clamp(0.0, 1.0),
                  Colors.blue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(
      String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontFamily: 'Caveat',
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
                fontFamily: 'Caveat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress * _chartAnimation.value,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Card(
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Caveat',
                  ),
                ),
                const SizedBox(height: 16),
                if (_userStats!.achievements.isEmpty)
                  const Text(
                    'No achievements yet. Keep sorting to unlock achievements!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontFamily: 'Caveat',
                    ),
                  )
                else
                  ...(_userStats!.achievements
                      .map((achievement) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    achievement,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily: 'Caveat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList()),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'plastic':
        return Colors.blue;
      case 'glass':
        return Colors.green;
      case 'compost':
        return Colors.brown;
      case 'landfill':
        return Colors.grey;
      case 'e-waste':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  double _getLevelProgress(int score) {
    if (score >= 1000) return 1.0;
    if (score >= 500) return 0.8;
    if (score >= 200) return 0.6;
    if (score >= 50) return 0.4;
    return score / 50.0;
  }
}
