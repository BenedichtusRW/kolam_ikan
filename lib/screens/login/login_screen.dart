import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/auth_provider.dart';
import '../../utils/routes.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      bool success = await authProvider.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        // Navigate berdasarkan role user
        String homeRoute = Routes.getHomeRoute(
          authProvider.userProfile?.role ?? 'user'
        );
        Navigator.pushReplacementNamed(context, homeRoute);
      }
    }
  }

  void _signInWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    bool success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      // Navigate based on user role
      if (authProvider.userProfile?.isAdmin == true) {
        Navigator.pushReplacementNamed(context, Routes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, Routes.userDashboard);
      }
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo atau judul aplikasi
                      Icon(
                        Icons.water_drop,
                        size: 80,
                        color: Colors.blue[600],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Kolam Ikan Monitor',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          // Regex pattern untuk validasi email yang lebih akurat
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                ? Icons.visibility 
                                : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      // Login button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: authProvider.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Masuk',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                            ),
                          );
                        },
                      ),

                      // Error message
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.errorMessage != null) {
                            return Container(
                              margin: EdgeInsets.only(top: 16),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red[600], size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: TextStyle(color: Colors.red[800]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),

                      SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[400])),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'atau masuk dengan',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[400])),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Social Login Buttons
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Column(
                            children: [
                              // Google Sign In Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: authProvider.isLoading ? null : _signInWithGoogle,
                                  icon: SvgPicture.asset(
                                    'assets/images/google_logo.svg',
                                    height: 20,
                                    width: 20,
                                  ),
                                  label: Text('Masuk dengan Google'),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 12),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 32),

                      // Signup Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.signup);
                            },
                            child: Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Development Login Hints
                      Container(
                        margin: EdgeInsets.only(top: 24),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Login untuk Testing',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildLoginHint('Admin', 'admin@kolamikan.com', 'admin123'),
                            SizedBox(height: 8),
                            _buildLoginHint('User', 'user@kolamikan.com', 'user123'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginHint(String role, String email, String password) {
    return GestureDetector(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = password;
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.blue[600], size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue[800],
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Tap to use',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}