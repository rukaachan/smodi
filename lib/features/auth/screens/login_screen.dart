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
  // ... (form keys, controllers, and _signIn method remain the same) ...
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Welcome to Smodi',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Sign in to continue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 48),
                TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter an email' : null),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signIn, child: const Text('Sign In')),
                const SizedBox(height: 16),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const RegisterScreen()));
                    },
                    child: const Text('Don\'t have an account? Sign Up')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // This button always shows the QR code for the new device to be authorized.
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const DisplayConnectionQrScreen()));
                  },
                  child: const Text('Sign In with another device (Offline)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
