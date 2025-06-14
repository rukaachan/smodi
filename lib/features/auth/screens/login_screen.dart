import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/features/auth/screens/app_shell.dart';
import 'package:smodi/features/auth/screens/register_screen.dart';
import 'package:smodi/features/sync/screens/display_connection_qr_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false; // State for 'Remember me' checkbox

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final connectivityResult = await sl<Connectivity>().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('No internet connection. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error));
        setState(() => _isLoading = false);
      }
      return;
    }
    try {
      await sl<AuthService>().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppShell()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Sign in failed: Invalid credentials.'),
            backgroundColor: Color(0xFFB00020)));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Added BoxDecoration for gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFDFF2F1),
              Color(0xFFFDB69F),
              Color(0xFF011D3A),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 'Let's get started!' text
                  Text(
                    'Let\'s get started!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF011D3A), // Changed text color for contrast
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 'Login or sign up to explore our app' text
                  Text(
                    'Login or sign up to explore our app',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF011D3A), // Changed text color for contrast
                    ),
                  ),
                  const SizedBox(height: 48), // Adjusted spacing here

                  // Removed Login/Sign Up tabs as per request

                  // Email/Username field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'username/email',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9), // White background for input
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter a username or email' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'password',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9), // White background for input
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    ),
                    obscureText: true,
                    validator: (value) => value!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Remember me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _rememberMe = newValue!;
                              });
                            },
                            activeColor: Colors.white, // Color when checked
                            checkColor: const Color(0xFF011D3A), // Checkmark color
                          ),
                          Text(
                            'Remember me',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF011D3A),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement Forgot Password logic
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Forgot Password pressed! (Not implemented)')));
                        },
                        child: Text(
                          'Forgot password?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.deepPurpleAccent, // Changed text color for contrast
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Sign In button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF011D3A)))
                      : ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF011D3A), // White button background
                      foregroundColor: Colors.white, // Purple text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25), // More rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 5,
                    ),
                    child: Text(
                      'Login', // Changed text from 'Sign In' to 'Login'
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 'Don't have an account? Sign Up'
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const RegisterScreen()));
                    },
                    child: Text(
                      'Don\'t have an account? Sign Up',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontSize: 15
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 'Login as Guest' (formerly 'Sign In with another device (Offline)')
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const DisplayConnectionQrScreen()));
                    },
                    child: Text(
                      'Sign In with another device (Offline)',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontSize: 15
                      ),
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
