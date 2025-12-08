import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _nextMatchFuture;
  late Future<List<Map<String, dynamic>>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _nextMatchFuture = ApiService().fetchNextFixtures();
    _newsFuture = ApiService().fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'MANCHESTER UNITED',
                style: GoogleFonts.bebasNeue(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppTheme.muRed,
                    child: Center(
                      child: Icon(
                        Icons.sports_soccer,
                        size: 150,
                        color: AppTheme.muBlack.withOpacity(0.2),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    child: Text(
                      'NEWS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.muGold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _newsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.muRed,
                          ),
                        );
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Text('No news found.');
                      }
                      // Limit to 5-7 news articles
                      final newsList = snapshot.data!.take(7).toList();
                      return Column(
                        children:
                            newsList
                                .map((news) => _buildNewsCard(context, news))
                                .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'UPCOMING MATCH',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.muGold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _nextMatchFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.muRed,
                          ),
                        );
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Text('No upcoming matches found.');
                      }
                      return _buildMatchCard(context, snapshot.data!.first);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> news) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(bottom: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['title']?.toString() ?? 'No Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        news['source']?.toString() ?? '',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Text(
                        news['date']?.toString() ?? '',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                news['image']?.toString() ?? '',
                width: 100,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 100,
                      height: 60,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Map<String, dynamic> match) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.muRed, Color(0xFF8A1A11)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.muRed.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  if (match['logoHome'] != null &&
                      match['logoHome'].toString().isNotEmpty)
                    Image.network(
                      match['logoHome'],
                      width: 50,
                      height: 50,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.shield,
                            size: 40,
                            color: Colors.white,
                          ),
                    )
                  else
                    const Icon(Icons.shield, size: 40, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    match['homeTeam'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  match['time'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.muGold,
                  ),
                ),
                Text(
                  match['date'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    match['league'] ?? '',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  if (match['logoAway'] != null &&
                      match['logoAway'].toString().isNotEmpty)
                    Image.network(
                      match['logoAway'],
                      width: 50,
                      height: 50,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.shield_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                    )
                  else
                    const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    match['awayTeam'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
