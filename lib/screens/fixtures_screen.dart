import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../data/dummy_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class FixturesScreen extends StatefulWidget {
  const FixturesScreen({super.key});

  @override
  State<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends State<FixturesScreen> {
  late Future<List<Map<String, dynamic>>> _fixturesFuture;

  @override
  void initState() {
    super.initState();
    _fixturesFuture = _fetchFixturesHybrid();
  }

  Future<List<Map<String, dynamic>>> _fetchFixturesHybrid() async {
    try {
      // Use Unified API (RapidAPI -> FD -> Dummy)
      final unifiedMatches = await ApiService().getUnifiedFixtures();

      if (unifiedMatches.isNotEmpty) {
        return unifiedMatches;
      }

      // Fallback to Dummy Data if all APIs fail
      return DummyData.fixtures;
    } catch (e) {
      debugPrint('Error fetching fixtures: $e');
      return DummyData.fixtures;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('FIXTURES'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fixturesFuture,
        builder: (context, snapshot) {
          final fixturesList = snapshot.data ?? DummyData.fixtures;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                isWide
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildFixturesList(fixturesList),
                        ),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildSidePanel()),
                      ],
                    )
                    : Column(
                      children: [
                        _buildSidePanel(),
                        const SizedBox(height: 24),
                        _buildFixturesList(fixturesList),
                      ],
                    ),
          );
        },
      ),
    );
  }

  Widget _buildFixturesList(List<Map<String, dynamic>> fixtures) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fixtures',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...fixtures.asMap().entries.map((entry) {
          final index = entry.key;
          final match = entry.value;
          return FadeInLeft(
            delay: Duration(milliseconds: index * 30),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  // Date
                  SizedBox(
                    width: 80,
                    child: Text(
                      match['date'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ),
                  // Teams & Score
                  Expanded(
                    child: Row(
                      children: [
                        // Home Team
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  match['homeTeam'],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight:
                                        match['homeTeam'] == 'Man United' ||
                                                match['homeTeam'] ==
                                                    'Manchester United'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildTeamLogo(match['logoHome']),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Score or Time Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                match['status'] == 'played'
                                    ? (match['homeScore'] >
                                                    match['awayScore'] &&
                                                (match['homeTeam'] ==
                                                        'Man United' ||
                                                    match['homeTeam'] ==
                                                        'Manchester United') ||
                                            match['awayScore'] >
                                                    match['homeScore'] &&
                                                (match['awayTeam'] ==
                                                        'Man United' ||
                                                    match['awayTeam'] ==
                                                        'Manchester United')
                                        ? Colors.green.withOpacity(0.2)
                                        : (match['homeScore'] ==
                                                match['awayScore']
                                            ? Colors.grey.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2)))
                                    : Colors.grey[900],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            match['status'] == 'played'
                                ? '${match['homeScore']} - ${match['awayScore']}'
                                : match['time'],
                            style: TextStyle(
                              color:
                                  match['status'] == 'played'
                                      ? Colors.white
                                      : AppTheme.muGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Away Team
                        Expanded(
                          child: Row(
                            children: [
                              _buildTeamLogo(match['logoAway']),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  match['awayTeam'],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight:
                                        match['awayTeam'] == 'Man United' ||
                                                match['awayTeam'] ==
                                                    'Manchester United'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTeamLogo(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.shield_outlined, color: Colors.grey, size: 20);
    }
    return Image.network(
      url,
      width: 20,
      height: 20,
      errorBuilder:
          (context, error, stackTrace) =>
              const Icon(Icons.shield_outlined, color: Colors.grey, size: 20),
    );
  }

  Widget _buildSidePanel() {
    return Column(
      children: [
        _buildFixtureDifficulty(),
        const SizedBox(height: 24),
        _buildNextMatchCard(),
      ],
    );
  }

  Widget _buildFixtureDifficulty() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fixture difficulty',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: const [
                  Text(
                    'Next five matches',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.info_outline, color: Colors.grey, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                DummyData.fixtureDifficulty.map((item) {
                  Color bgColor;
                  switch (item['diff']) {
                    case 'easy':
                      bgColor = Colors.white;
                      break;
                    case 'medium':
                      bgColor = const Color(0xFFE57373);
                      break;
                    case 'hard':
                      bgColor = const Color(0xFFC62828);
                      break;
                    default:
                      bgColor = Colors.grey;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          item['team']!,
                          style: TextStyle(
                            color:
                                item['diff'] == 'easy'
                                    ? Colors.black
                                    : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['loc']!,
                          style: TextStyle(
                            color:
                                item['diff'] == 'easy'
                                    ? Colors.black54
                                    : Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMatchCard() {
    final stats = DummyData.nextMatchStats;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Next match',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    stats['league'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.public, color: Colors.grey, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (stats['logoHome'] != null)
                      Image.network(
                        stats['logoHome'],
                        width: 50,
                        height: 50,
                        errorBuilder:
                            (c, e, s) => const Icon(
                              Icons.shield,
                              color: Colors.orange,
                              size: 40,
                            ),
                      )
                    else
                      const Icon(Icons.shield, color: Colors.orange, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      stats['homeTeam'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    stats['time'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats['date'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    if (stats['logoAway'] != null)
                      Image.network(
                        stats['logoAway'],
                        width: 50,
                        height: 50,
                        errorBuilder:
                            (c, e, s) => const Icon(
                              Icons.shield,
                              color: Colors.red,
                              size: 40,
                            ),
                      )
                    else
                      const Icon(Icons.shield, color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      stats['awayTeam'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          _buildStatRow(
            'Table position',
            stats['homePos'].toString(),
            stats['awayPos'].toString(),
            reverse: true,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Goals per match',
            stats['homeGPM'].toString(),
            stats['awayGPM'].toString(),
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Goals conceded per match',
            stats['homeGCPM'].toString(),
            stats['awayGCPM'].toString(),
            reverse: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String homeVal,
    String awayVal, {
    bool reverse = false,
  }) {
    final homeBetter =
        reverse
            ? double.parse(homeVal) < double.parse(awayVal)
            : double.parse(homeVal) > double.parse(awayVal);
    final awayBetter =
        reverse
            ? double.parse(awayVal) < double.parse(homeVal)
            : double.parse(awayVal) > double.parse(homeVal);

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            homeVal,
            style: TextStyle(
              color: homeBetter ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            awayVal,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: awayBetter ? Colors.red : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
