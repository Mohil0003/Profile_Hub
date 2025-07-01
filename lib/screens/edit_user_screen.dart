import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_colors.dart';

class AddEditUserScreen extends StatefulWidget {
  final User? user;
  AddEditUserScreen({this.user});

  @override
  _AddEditUserScreenState createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedGender = 'Male';
  String _selectedCity = 'Rajkot';
  Map<String, bool> _hobbies = {
    'Reading': false,
    'Sports': false,
    'Music': false,
    'Travel': false,
    'Cooking': false,
  };

  final List<String> _cities = [
    'Rajkot',
    'Ahemdabad',
    'Surat',
    'Morbi',
    'Jamnagar',
  ];

  final RegExp _nameRegex = RegExp(r'^[a-zA-Z\s]{3,50}$');
  final RegExp _phoneRegex = RegExp(r'^\d{10}$');
  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'
  );

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone;
      _selectedDate = widget.user!.birthdate;
      _selectedGender = widget.user!.gender;
      _selectedCity = widget.user!.city;
      for (String hobby in widget.user!.hobbies) {
        if (_hobbies.containsKey(hobby)) {
          _hobbies[hobby] = true;
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minDate = now.subtract(Duration(days: 365 * 80));
    final DateTime maxDate = now.subtract(Duration(days: 365 * 18));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? maxDate,
      firstDate: minDate,
      lastDate: maxDate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _isValidAge(DateTime birthdate) {
    final now = DateTime.now();
    final age = now.year - birthdate.year;
    return age >= 18 && age <= 80;
  }

  List<String> _getSelectedHobbies() {
    return _hobbies.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select birthdate')),
      );
      return;
    }

    if (!_isValidAge(_selectedDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Age must be between 18 and 80 years')),
      );
      return;
    }

    if (_getSelectedHobbies().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one hobby')),
      );
      return;
    }

    final db = await _dbHelper.database;
    final user = User(
      id: widget.user?.id,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      birthdate: _selectedDate!,
      gender: _selectedGender,
      city: _selectedCity,
      hobbies: _getSelectedHobbies(),
      password: _passwordController.text,
      isFavorite: widget.user?.isFavorite ?? false,
    );

    if (widget.user == null) {
      await db.insert('users', user.toMap());
      print("User added with id: ${user.id}");
    } else {
      await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user == null ? 'Add User' : 'Edit User',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
          textAlign: TextAlign.center,
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  'Name',
                  _nameController,
                  Icons.person,
                  isPassword: false,
                  showPassword: _showPassword,
                  onTogglePassword: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Name';
                    }
                    
                    if (!RegExp(r'^[a-zA-Z\s]{3,50}$').hasMatch(value)) {
                      return 'Name should only contain letters (3-50 characters)';
                    }
                    
                    return null;
                  },
                ),
                _buildTextField(
                  'Email',
                  _emailController,
                  Icons.email,
                  isPassword: false,
                  showPassword: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Email';
                    }
                    
                    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    
                    return null;
                  },
                ),
                _buildTextField(
                  'Phone Number',
                  _phoneController,
                  Icons.phone,
                  isPassword: false,
                  showPassword: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Phone Number';
                    }
                    
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    
                    return null;
                  },
                ),
                ListTile(
                  title: Text(
                    'Birthdate: ${_selectedDate?.toLocal().toString().split(' ')[0] ?? 'Not selected'}',
                    style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Age must be between 18-80 years', style: TextStyle(color: Colors.black)),
                  trailing: Icon(Icons.calendar_today, color: Colors.black),
                  onTap: () => _selectDate(context),
                ),
                _buildDropdownFormField('City', _selectedCity, _cities, (value) {
                  setState(() {
                    _selectedCity = value!;
                  });
                }),
                SizedBox(height: 16), // Add space between city and gender fields
                _buildDropdownFormField('Gender', _selectedGender, ['Male', 'Female', 'Other'], (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                }),
                _buildHobbiesSection(),
                _buildTextField(
                  'Password',
                  _passwordController,
                  Icons.lock,
                  isPassword: true,
                  showPassword: _showPassword,
                  onTogglePassword: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Password';
                    }
                    
                    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(value)) {
                      return 'Password must contain at least 8 characters, including uppercase, lowercase, number and special character';
                    }
                    
                    return null;
                  },
                ),
                _buildTextField(
                  'Confirm Password',
                  _confirmPasswordController,
                  Icons.lock,
                  isPassword: true,
                  showPassword: _showPassword,
                  onTogglePassword: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Confirm Password';
                    }
                    
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveUser,
                  child: Text(widget.user == null ? 'Add' : 'Update' ,style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[400], // Button color to match the theme
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool? showPassword,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: AppColors.formFieldGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !(showPassword ?? false),
        keyboardType: label.toLowerCase().contains('phone') 
            ? TextInputType.phone 
            : TextInputType.text,
        inputFormatters: label == 'Name'
            ? [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  String text = newValue.text;
                  final words = text.split(' ');
                  final capitalizedWords = words.map((word) {
                    if (word.isEmpty) return '';
                    return word[0].toUpperCase() + word.substring(1).toLowerCase();
                  }).join(' ');
                  
                  return TextEditingValue(
                    text: capitalizedWords,
                    selection: newValue.selection,
                  );
                }),
              ]
            : label.toLowerCase().contains('phone')
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ]
                : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: label == 'Name' 
              ? 'Enter alphabets only'
              : 'Enter your ${label.toLowerCase()}',
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Icon(icon, color: AppColors.primary),
          ),
          suffixIcon: isPassword
              ? Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: IconButton(
                    icon: Icon(
                      showPassword ?? false
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.iconSecondary,
                    ),
                    onPressed: onTogglePassword,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          
          if (label == 'Name') {
            if (value.length < 3 || value.length > 50) {
              return 'Name should be between 3 and 50 characters';
            }
            if (!RegExp(r'^[A-Z][a-z]*( [A-Z][a-z]*)*$').hasMatch(value)) {
              return 'Name should start with capital letter after each space';
            }
          }
          
          if (label == 'Phone') {
            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
              return 'Please enter a valid 10-digit phone number';
            }
          }
          
          if (label == 'Email') {
            if (!value.toLowerCase().endsWith('@gmail.com')) {
              return 'Please enter a valid Gmail address';
            }
          }
          
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownFormField(String label, String selectedValue, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: AppColors.formFieldGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        items: items.map((value) => DropdownMenuItem(
          value: value,
          child: Text(value, style: TextStyle(color: AppColors.textDark)),
        )).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildHobbiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Hobbies:', style: TextStyle(color: AppColors.textPrimary)),
        ),
        ..._hobbies.entries.map(
          (entry) => CheckboxListTile(
            title: Text(entry.key, style: TextStyle(color: AppColors.textPrimary)),
            value: entry.value,
            onChanged: (bool? value) {
              setState(() {
                _hobbies[entry.key] = value!;
              });
            },
          ),
        ),
      ],
    );
  }
}

void main() => runApp(MaterialApp(home: AddEditUserScreen()));




