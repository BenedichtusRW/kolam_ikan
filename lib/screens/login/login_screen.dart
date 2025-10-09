import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/auth_provider.dart';
import '../../utils/routes.dart';
import '../navigation/main_navigation_screen.dart';
import '../navigation/admin_main_navigation_screen.dart';
import '../auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success = await authProvider.loginUser(email, password);

    if (!mounted) return;
    if (success) {
      if (authProvider.userProfile?.isAdmin == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminMainNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigationScreen()),
        );
      }
    } else {
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!)),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.signInWithGoogle();

    if (!mounted) return;
    if (success) {
      if (authProvider.userProfile?.isAdmin == true) {
        Navigator.pushReplacementNamed(context, Routes.adminDashboard);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigationScreen()),
        );
      }
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 540),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Logo
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  right: 8,
                                                  top: 12,
                                                  child: Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[600],
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'KOLAM IKAN',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),
                                    Text(
                                      'Kolam Ikan Monitor',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                          ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Email field
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: const Icon(Icons.email),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Email tidak boleh kosong';
                                        }
                                        final emailRegex = RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                        );
                                        if (!emailRegex.hasMatch(value.trim())) {
                                          return 'Format email tidak valid';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),

                                    // Password field
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock),
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

                                    const SizedBox(height: 20),

                                    // Login button
                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, child) {
                                        return SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: authProvider.isLoading
                                                ? null
                                                : _handleLogin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[600],
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: authProvider.isLoading
                                                ? const SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                                    ),
                                                  )
                                                : const Text(
                                                    'Masuk',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 18),

                                    Row(
                                      children: [
                                        Expanded(child: Divider(color: Colors.grey[300])),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text('atau masuk dengan',
                                              style: TextStyle(color: Colors.grey[600])),
                                        ),
                                        Expanded(child: Divider(color: Colors.grey[300])),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Google sign-in (warna biru)
                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, child) {
                                        return SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: authProvider.isLoading
                                                ? null
                                                : _signInWithGoogle,
                                            icon: SvgPicture.asset(
                                              'assets/images/google_logo.svg',
                                              height: 20,
                                              width: 20,
                                            ),
                                            label: const Text(
                                              'Masuk dengan Google',
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 12),

                                    // Signup link
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text('Belum punya akun? ',
                                            style: TextStyle(color: Colors.grey[600])),
                                        TextButton(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const SignupScreen(),
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                          ),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
