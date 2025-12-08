import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Squad'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: 'Table'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Fixtures'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.outfit(),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/squad')) return 1;
    if (location.startsWith('/standings')) return 2;
    if (location.startsWith('/fixtures')) return 3;
    if (location.startsWith('/news')) return 4;
    if (location.startsWith('/forum')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/squad');
        break;
      case 2:
        context.go('/standings');
        break;
      case 3:
        context.go('/fixtures');
        break;
      case 4:
        context.go('/news');
        break;
      case 5:
        context.go('/forum');
        break;
    }
  }
}
