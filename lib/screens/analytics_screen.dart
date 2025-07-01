import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../database/database_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<Map<String, dynamic>> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadAnalytics();
  }

  Future<Map<String, dynamic>> _loadAnalytics() async {
    final db = await _dbHelper.database;
    
    // Total Users
    final totalUsers = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users')
    ) ?? 0;
    
    // Favorite Users
    final favoriteUsers = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users WHERE isFavorite = 1')
    ) ?? 0;
    
    // Gender Distribution
    final maleUsers = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users WHERE gender = "Male"')
    ) ?? 0;
    
    final femaleUsers = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users WHERE gender = "Female"')
    ) ?? 0;

    // Age Groups
    final now = DateTime.now();
    final under25 = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM users WHERE (? - strftime("%Y", birthdate)) < 25',
        [now.year]
      )
    ) ?? 0;
    
    final age25to35 = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM users WHERE (? - strftime("%Y", birthdate)) BETWEEN 25 AND 35',
        [now.year]
      )
    ) ?? 0;
    
    final above35 = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM users WHERE (? - strftime("%Y", birthdate)) > 35',
        [now.year]
      )
    ) ?? 0;

    // Hobbies Distribution
    final hobbiesResult = await db.rawQuery('''
      WITH RECURSIVE split(hobby, rest) AS (
        SELECT '', hobbies || ','
        FROM users
        UNION ALL
        SELECT
          substr(rest, 0, instr(rest, ',')),
          substr(rest, instr(rest, ',') + 1)
        FROM split
        WHERE rest <> ''
      )
      SELECT hobby, COUNT(*) as count
      FROM split
      WHERE hobby <> ''
      GROUP BY hobby
      ORDER BY count DESC
      LIMIT 5
    ''');

    final List<Map<String, dynamic>> hobbies = hobbiesResult.map((row) {
      return {
        'hobby': row['hobby'],
        'count': row['count'],
      };
    }).toList();

    // Find max count for percentage calculation
    final maxCount = hobbies.isEmpty ? 1 : hobbies.map((h) => h['count'] as int).reduce(max);

    return {
      'totalUsers': totalUsers,
      'favoriteUsers': favoriteUsers,
      'maleUsers': maleUsers,
      'femaleUsers': femaleUsers,
      'under25': under25,
      'age25to35': age25to35,
      'above35': above35,
      'hobbies': hobbies,
      'maxHobbyCount': maxCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _analyticsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Error loading analytics'));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(data),
                  SizedBox(height: 24),
                  _buildGenderDistribution(data),
                  SizedBox(height: 24),
                  _buildAgeDistribution(data),
                  SizedBox(height: 24),
                  _buildHobbiesDistribution(data),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Users',
          data['totalUsers'].toString(),
          Icons.people_outline,
        ),
        _buildStatCard(
          'Favorites',
          data['favoriteUsers'].toString(),
          Icons.favorite_border,
        ),
      ],
    );
  }

  Widget _buildGenderDistribution(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGenderStat(
                    'Male',
                    data['maleUsers'],
                    Icons.male,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildGenderStat(
                    'Female',
                    data['femaleUsers'],
                    Icons.female,
                    Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeDistribution(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Age Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            _buildAgeGroup('Under 25', data['under25']),
            SizedBox(height: 8),
            _buildAgeGroup('25-35', data['age25to35']),
            SizedBox(height: 8),
            _buildAgeGroup('Above 35', data['above35']),
          ],
        ),
      ),
    );
  }

  Widget _buildHobbiesDistribution(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> hobbies = List<Map<String, dynamic>>.from(data['hobbies']);
    final int totalCount = hobbies.fold(0, (sum, hobby) => sum + (hobby['count'] as int));
    
    // Generate sections for pie chart
    final sections = hobbies.asMap().entries.map((entry) {
      final hobby = entry.value;
      final double percentage = (hobby['count'] as int) / totalCount * 100;
      
      // Generate different colors for each section
      final Color color = Colors.primaries[entry.key % Colors.primaries.length];
      
      return PieChartSectionData(
        color: color.withOpacity(0.8),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hobbies Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            SizedBox(height: 24),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: hobbies.asMap().entries.map((entry) {
                final hobby = entry.value;
                final color = Colors.primaries[entry.key % Colors.primaries.length];
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${hobby['hobby']} (${hobby['count']})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
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
  }

  Widget _buildHobbiesChartWithTooltip(List<Map<String, dynamic>> hobbies) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
        ),
        sections: [], // Your sections here
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderStat(String gender, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          gender,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAgeGroup(String label, int count) {
    final total = count + 0.0001; // Avoid division by zero
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: count / total,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 