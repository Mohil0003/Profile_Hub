import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'user_list_screen.dart';
import 'edit_user_screen.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'about_screen.dart';
import '../utils/page_transitions.dart';
import 'package:flutter/services.dart';
import 'analytics_screen.dart';
import 'user_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final User currentUser;

  DashboardScreen({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.backgroundGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          currentUser.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        currentUser.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currentUser.email,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.person_outline),
                        title: Text('My Profile'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            SlideUpPageRoute(
                              page: UserDetailScreen(user: currentUser),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit Profile'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            SlideUpPageRoute(
                              page: AddEditUserScreen(user: currentUser),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.people_outline),
                        title: Text('User List'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            ScalePageRoute(
                              page: UserListScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.favorite_border),
                        title: Text('Favorites'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            SlideUpPageRoute(
                              page: UserListScreen(showOnlyFavorites: true),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.analytics_outlined),
                        title: Text('Analytics'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            ScalePageRoute(
                              page: AnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.info_outline),
                        title: Text('About Us'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            ScalePageRoute(
                              page: AboutScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text('Logout', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Logout'),
                              content: Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()),
                                      (route) => false,
                                    );
                                  },
                                  child: Text('Logout', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card - Now Clickable
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideUpPageRoute(
                      page: AddEditUserScreen(user: currentUser),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${currentUser.name}!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Find your perfect match today',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Dashboard Options
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      context,
                      'Add User',
                      Icons.person_add_outlined,
                      () {
                        Navigator.push(
                          context,
                          SlideUpPageRoute(
                            page: AddEditUserScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      'User List',
                      Icons.people_outline,
                      () {
                        Navigator.push(
                          context,
                          ScalePageRoute(
                            page: UserListScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      'Favorites',
                      Icons.favorite_border,
                      () {
                        Navigator.push(
                          context,
                          SlideUpPageRoute(
                            page: UserListScreen(showOnlyFavorites: true),
                          ),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      'About Us',
                      Icons.info_outline,
                      () {
                        Navigator.push(
                          context,
                          ScalePageRoute(
                            page: AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          Future.delayed(Duration(milliseconds: 100), onTap);
        },
        borderRadius: BorderRadius.circular(15),
        splashColor: AppColors.primaryLight.withOpacity(0.3),
        highlightColor: AppColors.primaryLight.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.3),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                duration: Duration(milliseconds: 200),
                tween: Tween<double>(begin: 1, end: 1.1),
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}