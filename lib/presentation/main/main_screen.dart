import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/journal/screens/journal_editor_screen.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeFeedCubit>(
          create: (_) => getIt<HomeFeedCubit>()..fetchHomeFeed(),
        ),
        // Tambahkan cubit lain jika perlu
      ],
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.blueGrey.shade50,
                Colors.blueGrey.shade100,
              ],
            ),
          ),
          child: child,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey.shade500,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(index, context),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline),
                  activeIcon: Icon(Icons.chat_bubble),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  activeIcon: Icon(Icons.add_circle),
                  label: 'Jurnal',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.psychology_outlined),
                  activeIcon: Icon(Icons.psychology),
                  label: 'Psy',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: selectedIndex == 2
            ? Container(
                margin: const EdgeInsets.only(bottom: 80), // Space for bottom nav
                child: FloatingActionButton.extended(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  highlightElevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, size: 18),
                  ),
                  label: const Text(
                    'Tulis Jurnal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const JournalEditorScreen()),
                    );
                    // Refresh journal list if needed
                  },
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// Menentukan index navigasi aktif berdasarkan lokasi saat ini
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/journal')) return 2;
    if (location.startsWith('/psy')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  /// Navigasi ke rute berdasarkan tab yang diklik
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/journal');
        break;
      case 3:
        context.go('/psy');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
