import 'package:flutter/material.dart';
import 'package:mohil_matrimony_app/screens/edit_user_screen.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../constants/app_colors.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  final bool showOnlyFavorites;

  UserListScreen({this.showOnlyFavorites = false});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _insertDefaultUsersIfEmpty();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _insertDefaultUsersIfEmpty() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
    
    print('Current user count: $count'); // Debug print
    
    if (count == 0) {
      final defaultUsers = [
        User(
          name: 'John Doe',
          email: 'john.doe@example.com',
          phone: '1234567890',
          city: 'New York',
          isFavorite: false,
          password: 'password123',
          birthdate: DateTime(1990, 1, 1),
          gender: 'Male',
          hobbies: ['Reading', 'sports', 'music'],
        ),
        User(
          name: 'Jane Smith',
          email: 'jane.smith@example.com',
          phone: '9876543210',
          city: 'Los Angeles',
          isFavorite: false,
          password: 'password456',
          birthdate: DateTime(1992, 5, 15),
          gender: 'Female',
          hobbies: ['Reading', 'sports', 'music'],
        ),
        User(
          name: 'Mike Johnson',
          email: 'mike.johnson@example.com',
          phone: '5555555555',
          city: 'Chicago',
          isFavorite: false,
          password: 'mohil@123',
          birthdate: DateTime(2005, 2, 15),
          gender: 'Male',
          hobbies: ['Reading', 'sports', 'music'],
        ),
      ];

      for (var user in defaultUsers) {
        try {
          await db.insert('users', user.toMap());
          print('Successfully inserted user: ${user.name}'); // Debug print
        } catch (e) {
          print('Error inserting user: $e'); // Debug print
        }
      }
      setState(() {});
    }
  }

  Future<List<User>> _getUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    print('Retrieved ${maps.length} users from database'); // Debug print
    print('User data: $maps'); // Debug print
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<void> _deleteUser(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    setState(() {});
  }

  Future<void> _toggleFavorite(int id) async {
    try {
      await _dbHelper.toggleFavorite(id);
      setState(() {}); // Refresh the UI after toggling
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling favorite status')),
      );
    }
  }

  List<User> _filterUsers(List<User> users) {
    // First apply favorites filter if needed
    List<User> filteredUsers = widget.showOnlyFavorites 
        ? users.where((user) => user.isFavorite).toList()
        : users;
    
    // Then apply search filter
    if (_searchQuery.isEmpty) return filteredUsers;
    
    return filteredUsers.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.phone.contains(_searchQuery) ||
             user.hobbies.any((hobby) => hobby.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Users',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Users',
                  hintText: 'Search by name, email, city, phone, or hobbies',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('Error loading users: ${snapshot.error}'); // Debug print
                    return Center(child: Text('Error loading users: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No users found'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _insertDefaultUsersIfEmpty();
                              });
                            },
                            child: Text('Add Default Users'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredUsers = _filterUsers(snapshot.data!);
                  print('Filtered users count: ${filteredUsers.length}'); // Debug print

                  if (filteredUsers.isEmpty) {
                    return Center(child: Text('No matching users found'));
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailScreen(user: user),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        user.name[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${user.gender} • ${DateTime.now().year - user.birthdate.year} years',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        user.isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: user.isFavorite ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () => _toggleFavorite(user.id!),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      user.city,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.interests_outlined, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Hobbies: ${user.hobbies.join(", ")}',
                                        style: TextStyle(color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: Icon(Icons.edit_outlined),
                                      label: Text('Edit'),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddEditUserScreen(user: user),
                                          ),
                                        );
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: Icon(Icons.delete_outline, color: Colors.red),
                                      label: Text('Delete', style: TextStyle(color: Colors.red)),
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Delete User'),
                                          content: Text('Are you sure you want to delete ${user.name}?'),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                            TextButton(
                                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                                              onPressed: () {
                                                _deleteUser(user.id!);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}