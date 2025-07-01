import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/profile/cubit/profile_cubit.dart';
import 'package:dear_flutter/presentation/profile/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            // Listener ini bisa digunakan untuk menampilkan notifikasi jika ada
          },
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ProfileStatus.failure) {
              return Center(child: Text(state.errorMessage ?? 'Gagal memuat profil'));
            }
            if (state.user == null) {
              return const Center(child: Text('Tidak ada data pengguna.'));
            }

            final user = state.user!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle, size: 100, color: Colors.blueGrey),
                    const SizedBox(height: 24),
                    Text(user.username, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(user.email, style: Theme.of(context).textTheme.bodyLarge),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        await context.read<ProfileCubit>().deleteAccount();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade900,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Hapus Akun'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await context.read<ProfileCubit>().logout();
                        // Kembali ke halaman login dan hapus semua halaman sebelumnya
                        if (context.mounted) {
                          context.go('/login'); 
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
