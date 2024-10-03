import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app_name/Services/auth_service.dart';
import 'package:your_app_name/Screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

/// The screen for authentication.
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLogin = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller and fade animation.
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose the animation controller.
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the authentication service from the provider.
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.purple.shade500],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  // Show a notification icon with a fade-in animation.
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Icon(
                      Icons.notifications_active,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Show the title with a fade-in animation.
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email field with a fade-in animation.
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.email, color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                            onSaved: (value) => _email = value!,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Password field with a fade-in animation.
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.lock, color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: true,
                            style: TextStyle(color: Colors.white),
                            validator: (value) => value!.length < 6 ? 'Enter a password 6+ chars long' : null,
                            onSaved: (value) => _password = value!,
                          ),
                        ),
                        SizedBox(height: 30),
                        // Sign in or sign up button with a fade-in animation.
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ElevatedButton(
                            child: Text(_isLogin ? 'Sign In' : 'Sign Up'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue.shade700,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                try {
                                  if (_isLogin) {
                                    await authService.signInWithEmailAndPassword(_email, _password);
                                  } else {
                                    await authService.signUpWithEmailAndPassword(_email, _password);
                                  }
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Authentication failed: ${e.toString()}')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        // Toggle sign in and sign up buttons with a fade-in animation.
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: TextButton(
                            child: Text(
                              _isLogin ? 'Create an account' : 'Already have an account? Sign in',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        // Sign in with Google button with a fade-in animation.
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.login),
                            label: Text('Sign In with Google'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                final result = await authService.signInWithGoogle();
                                if (result != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to sign in with Google: ${e.toString()}')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}