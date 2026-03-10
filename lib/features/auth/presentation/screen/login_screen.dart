import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // true = login, false = register
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<AuthBloc>();

    if (_isLogin) {
      bloc.add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    } else {
      bloc.add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          displayName: _displayNameController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Hiển thị lỗi nếu có
          if (state.status == AuthStatus.error &&
              state.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  Icon(
                    Icons.chat_bubble_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? 'Đăng nhập' : 'Đăng ký',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Display Name (chỉ hiện khi đăng ký)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên hiển thị',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (!_isLogin && (value == null || value.isEmpty)) {
                          return 'Vui lòng nhập tên hiển thị';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu tối thiểu 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.status == AuthStatus.loading;
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Google Sign In
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          AuthGoogleLoginRequested(),
                        );
                      },
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Đăng nhập bằng Google'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle Login/Register
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Chưa có tài khoản? Đăng ký'
                          : 'Đã có tài khoản? Đăng nhập',
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
