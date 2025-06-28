import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/auth/cubit/register_cubit.dart';
import 'package:dear_flutter/presentation/auth/cubit/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterCubit>(),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            // Jika registrasi & login otomatis berhasil, pergi ke beranda
            context.go('/home');
          }
          if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Registrasi Gagal')),
              );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Daftar Akun Baru')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                BlocBuilder<RegisterCubit, RegisterState>(
                  builder: (context, state) {
                    if (state.status == AuthStatus.loading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: () {
                        context.read<RegisterCubit>().register(
                              username: _usernameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                      },
                      child: const Text('Daftar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
