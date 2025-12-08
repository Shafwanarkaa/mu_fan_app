import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late Future<List<Map<String, dynamic>>> _standingsFuture;

  @override
  void initState() {
    super.initState();
    _standingsFuture = ApiService().fetchStandings();
  }

  Future<void> _refreshStandings() async {
    setState(() {
      _standingsFuture = ApiService().fetchStandings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Premier League',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStandings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStandings,
        color: AppTheme.muRed,
        backgroundColor: Colors.grey[900],
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _standingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.muRed),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No standings found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final standings = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Last Updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: DataTable(
                        columnSpacing: 16,
                        headingRowColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                        dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            return Colors.transparent;
                          },
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              '#',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Team',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'PL',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'W',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'D',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'L',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              '+/-',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'GD',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'PTS',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Form',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows:
                            standings.map((team) {
                              final isMU =
                                  team['strTeam'] == 'Manchester United' ||
                                  team['strTeam'] == 'Man Utd' ||
                                  team['strTeam'] == 'Manchester United FC';
                              final bgColor =
                                  isMU
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.transparent;

                              return DataRow(
                                color: MaterialStateProperty.all(bgColor),
                                cells: [
                                  DataCell(
                                    Text(
                                      team['intRank'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        Image.network(
                                          team['strBadge'] ?? '',
                                          width: 24,
                                          height: 24,
                                          errorBuilder:
                                              (_, __, ___) => const Icon(
                                                Icons.shield,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          team['strTeam'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                                isMU
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      team['intPlayed'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      team['intWin'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      team['intDraw'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      team['intLoss'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${team['intGoalsFor']}-${team['intGoalsAgainst']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      team['intGoalDifference'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      team['intPoints'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(_buildFormBadges(team['strForm'])),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormBadges(String? form) {
    if (form == null || form.isEmpty) return const SizedBox();

    // Take last 5 chars if longer
    final recentForm = form.length > 5 ? form.substring(form.length - 5) : form;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          recentForm.split('').map((char) {
            Color color;
            if (char == 'W')
              color = Colors.green;
            else if (char == 'D')
              color = Colors.grey;
            else
              color = Colors.red;

            return Container(
              margin: const EdgeInsets.only(right: 4),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                char,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
    );
  }
}
