class UserStats {
  final int totalScore;
  final int itemsSorted;
  final Map<String, int> categoryCounts;
  final List<String> achievements;
  final DateTime lastActive;
  final int streakDays;

  UserStats({
    required this.totalScore,
    required this.itemsSorted,
    required this.categoryCounts,
    required this.achievements,
    required this.lastActive,
    required this.streakDays,
  });

  factory UserStats.initial() {
    return UserStats(
      totalScore: 0,
      itemsSorted: 0,
      categoryCounts: {
        'plastic': 0,
        'glass': 0,
        'compost': 0,
        'landfill': 0,
        'e-waste': 0,
      },
      achievements: [],
      lastActive: DateTime.now(),
      streakDays: 0,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalScore: json['totalScore'] ?? 0,
      itemsSorted: json['itemsSorted'] ?? 0,
      categoryCounts: Map<String, int>.from(json['categoryCounts'] ?? {}),
      achievements: List<String>.from(json['achievements'] ?? []),
      lastActive: DateTime.parse(
          json['lastActive'] ?? DateTime.now().toIso8601String()),
      streakDays: json['streakDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'itemsSorted': itemsSorted,
      'categoryCounts': categoryCounts,
      'achievements': achievements,
      'lastActive': lastActive.toIso8601String(),
      'streakDays': streakDays,
    };
  }

  UserStats copyWith({
    int? totalScore,
    int? itemsSorted,
    Map<String, int>? categoryCounts,
    List<String>? achievements,
    DateTime? lastActive,
    int? streakDays,
  }) {
    return UserStats(
      totalScore: totalScore ?? this.totalScore,
      itemsSorted: itemsSorted ?? this.itemsSorted,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      achievements: achievements ?? this.achievements,
      lastActive: lastActive ?? this.lastActive,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  double get averageScore => itemsSorted > 0 ? totalScore / itemsSorted : 0.0;

  String get sustainabilityLevel {
    if (totalScore >= 1000) return 'Eco Warrior';
    if (totalScore >= 500) return 'Green Champion';
    if (totalScore >= 200) return 'Sustainability Advocate';
    if (totalScore >= 50) return 'Eco Beginner';
    return 'Getting Started';
  }
}
