import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../data/dummy_data.dart';
import '../services/api_service.dart';

class SquadScreen extends StatefulWidget {
  const SquadScreen({super.key});

  @override
  State<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> {
  late Future<List<Map<String, dynamic>>> _squadFuture;

  @override
  void initState() {
    super.initState();
    _squadFuture = _fetchSquad();
  }

  Future<List<Map<String, dynamic>>> _fetchSquad() async {
    try {
      debugPrint('🔥 FETCHING FROM API...');
      final unifiedSquad = await ApiService().getUnifiedSquad();
      debugPrint('✅ API RETURNED: ${unifiedSquad.length} players');

      // FORCE API ONLY - NO FALLBACK
      return unifiedSquad;
    } catch (e) {
      debugPrint('❌ ERROR: $e');
      // Return empty if API fails - DON'T use DummyData
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _squadFuture,
        builder: (context, snapshot) {
          final squadList = snapshot.data ?? DummyData.squad;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Row
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white24)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Player',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(child: _buildSortableHeader('Position')),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(child: _buildSortableHeader('Country')),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(child: _buildSortableHeader('Shirt')),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(child: _buildSortableHeader('Age')),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'Height',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Market value',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),

                // List of Players
                ...squadList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white10),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Player Name & Image
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[800],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child:
                                      (player['image'] != null &&
                                              player['image']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? Image.network(
                                            player['image'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return const Icon(
                                                Icons.person,
                                                color: Colors.white54,
                                              );
                                            },
                                          )
                                          : const Icon(
                                            Icons.person,
                                            color: Colors.white54,
                                          ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (player['status'] != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.local_hospital,
                                              color: Colors.red,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                player['status'],
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 10,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Position
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                player['position'] ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Country (Flag CDN)
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.grey[800],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child:
                                      (player['countryCode'] != null &&
                                              player['countryCode']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? Image.network(
                                            'https://flagcdn.com/w40/${player['countryCode'].toString().toLowerCase()}.png',
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Center(
                                                child: Text(
                                                  player['countryCode'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 6,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                          : const SizedBox(),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    player['country'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Shirt
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                player['shirt'] ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          // Age
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '${player['age'] ?? '-'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          // Height
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                player['height'] ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          // Market Value
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                player['marketValue'] ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortableHeader(String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 12),
      ],
    );
  }
}
