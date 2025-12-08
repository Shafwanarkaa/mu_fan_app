import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/dummy_data.dart';

class ApiService {
  // --- Keys & Config ---
  static const String _fdApiKey = 'eee805659bf74cab8f5b71da83ffbe4c';
  static const String _rapidApiKey = '6100d0f820a81af17c75fc65199f25e4';
  static const String _newsApiKey =
      '7c225cfdeda24ea2850c01cfd72eae8d'; // NewsAPI

  static const String _fdTeamId = '66'; // Man Utd (football-data.org)
  static const String _rapidTeamId = '33'; // Man Utd (API-Football)
  static const String _rapidSeason =
      '2023'; // API-Football Season (Free plan: 2021-2023 only)

  // --- Unified Methods ---

  Future<List<Map<String, dynamic>>> getUnifiedFixtures() async {
    try {
      final rapidData = await _fetchRapidFixtures();
      if (rapidData.isNotEmpty) return rapidData;
    } catch (e) {
      print('RapidAPI Fixtures Failed: $e');
    }

    try {
      final fdData = await _fetchFdFixtures();
      if (fdData.isNotEmpty) return fdData;
    } catch (e) {
      print('FD Fixtures Failed: $e');
    }

    return DummyData.fixtures;
  }

  Future<List<Map<String, dynamic>>> getUnifiedSquad() async {
    // Create a map of API photos for quick lookup
    Map<String, String> apiPhotos = {};

    try {
      // Fetch photos from API
      final response = await http.get(
        Uri.parse(
          'https://v3.football.api-sports.io/players/squads?team=$_rapidTeamId',
        ),
        headers: {
          'x-rapidapi-key': _rapidApiKey,
          'x-rapidapi-host': 'v3.football.api-sports.io',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null && (data['response'] as List).isNotEmpty) {
          final List<dynamic> apiPlayers = data['response'][0]['players'];

          // Build photo map with multiple keys for better matching
          for (var p in apiPlayers) {
            final name = p['name'].toString();
            final photo = p['photo']?.toString() ?? '';
            if (photo.isNotEmpty) {
              // Normalize: lowercase + remove accents
              final normalized = name
                  .toLowerCase()
                  .replaceAll('á', 'a')
                  .replaceAll('é', 'e')
                  .replaceAll('í', 'i')
                  .replaceAll('ó', 'o')
                  .replaceAll('ú', 'u')
                  .replaceAll('ı', 'i')
                  .replaceAll('ñ', 'n')
                  .replaceAll('ç', 'c')
                  .replaceAll('š', 's')
                  .replaceAll('ž', 'z');

              // Store with normalized full name
              apiPhotos[normalized] = photo;

              // Also store with surname
              final parts = normalized.split(' ');
              if (parts.length > 1) {
                apiPhotos[parts.last] = photo;
                // Special: "Amad Diallo" → also store as "amad"
                if (parts.first == 'amad') apiPhotos['amad'] = photo;
              }

              // Store with first name
              if (parts.isNotEmpty) apiPhotos[parts.first] = photo;
            }
          }

          print('✅ Fetched ${apiPhotos.length} photos from API');
        }
      }
    } catch (e) {
      print('API Photo fetch failed: $e');
    }

    // Use DummyData as base, enrich with API photos
    final enrichedSquad =
        DummyData.squad.map((player) {
          final playerCopy = Map<String, dynamic>.from(player);

          // Whitelist: Players that should KEEP their DummyData photos
          final photoWhitelist = ['ruben amorim', 'amad', 'chido obi'];
          final playerName = player['name'].toString().toLowerCase();

          // Skip API photo for whitelisted players
          if (photoWhitelist.contains(playerName)) {
            return playerCopy; // Keep DummyData photo
          }

          // Try to find matching photo from API
          if (player['name'] != null) {
            // Normalize DummyData name (same as API)
            final dummyName = player['name']
                .toString()
                .toLowerCase()
                .replaceAll('á', 'a')
                .replaceAll('é', 'e')
                .replaceAll('í', 'i')
                .replaceAll('ó', 'o')
                .replaceAll('ú', 'u')
                .replaceAll('ı', 'i')
                .replaceAll('ñ', 'n')
                .replaceAll('ç', 'c')
                .replaceAll('š', 's')
                .replaceAll('ž', 'z');
            String? matchedPhoto;

            // Try exact full name match first (most accurate)
            if (apiPhotos.containsKey(dummyName)) {
              matchedPhoto = apiPhotos[dummyName];
            } else {
              // Try surname match
              final parts = dummyName.split(' ');
              if (parts.length > 1 && apiPhotos.containsKey(parts.last)) {
                matchedPhoto = apiPhotos[parts.last];
              } else if (parts.isNotEmpty &&
                  apiPhotos.containsKey(parts.first)) {
                // Try first name match (for "Amad", "Casemiro", etc)
                matchedPhoto = apiPhotos[parts.first];
              }
            }

            // Only update if we found a match, otherwise keep DummyData photo
            if (matchedPhoto != null && matchedPhoto.isNotEmpty) {
              playerCopy['image'] = matchedPhoto;
            }
            // If no match, keep original DummyData photo (Coach, Diego Leon, Sesko, etc)
          }

          return playerCopy;
        }).toList();

    print('✅ Enriched ${enrichedSquad.length} players with API photos');
    return enrichedSquad;
  }

  Future<List<Map<String, dynamic>>> fetchStandings() async {
    // FORCE USE DUMMY DATA (2025/2026 season)
    // API free plans don't support current season
    return _getDummyStandings();

    /* DISABLED - Free APIs don't support 2025/2026
    // Try Football-Data.org first (supports 2024/2025 season)
    try {
      final fdData = await _fetchFdStandings();
      if (fdData.isNotEmpty) return fdData;
    } catch (e) {
      print('FD Standings Failed: $e');
    }

    // Fallback to RapidAPI (free plan only 2021-2023)
    try {
      final response = await http.get(
        Uri.parse(
          'https://v3.football.api-sports.io/standings?league=39&season=$_rapidSeason',
        ),
        headers: {
          'x-rapidapi-key': _rapidApiKey,
          'x-rapidapi-host': 'v3.football.api-sports.io',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null && data['response'].isNotEmpty) {
          final standings = data['response'][0]['league']['standings'][0];
          return List<Map<String, dynamic>>.from(
            standings.map(
              (s) => {
                'strTeam': s['team']['name'],
                'strBadge': s['team']['logo'],
                'intRank': s['rank'].toString(),
                'intPlayed': s['all']['played'].toString(),
                'intWin': s['all']['win'].toString(),
                'intDraw': s['all']['draw'].toString(),
                'intLoss': s['all']['lose'].toString(),
                'intGoalDifference': s['goalsDiff'].toString(),
                'intPoints': s['points'].toString(),
                'strForm': s['form'],
                'intGoalsFor': s['all']['goals']['for'].toString(),
                'intGoalsAgainst': s['all']['goals']['against'].toString(),
              },
            ),
          );
        }
      }
    } catch (e) {
      print('RapidAPI Standings Failed: $e');
    }

    return _getDummyStandings();
    */
  }

  Future<List<Map<String, dynamic>>> _fetchFdStandings() async {
    String url = 'https://api.football-data.org/v4/competitions/PL/standings';

    if (kIsWeb) {
      url = 'https://corsproxy.io/?' + Uri.encodeComponent(url);
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'X-Auth-Token': _fdApiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final standings = data['standings'][0]['table'];

      return List<Map<String, dynamic>>.from(
        standings.map((s) {
          String mockForm = '';
          if (s['team']['shortName'] == 'Man United' ||
              s['team']['name'] == 'Manchester United FC') {
            mockForm = 'WLDWW';
          }

          return {
            'strTeam': s['team']['name'],
            'strBadge': s['team']['crest'],
            'intRank': s['position'].toString(),
            'intPlayed': s['playedGames'].toString(),
            'intWin': s['won'].toString(),
            'intDraw': s['draw'].toString(),
            'intLoss': s['lost'].toString(),
            'intGoalDifference': s['goalDifference'].toString(),
            'intPoints': s['points'].toString(),
            'strForm': s['form'] ?? mockForm,
            'intGoalsFor': s['goalsFor'].toString(),
            'intGoalsAgainst': s['goalsAgainst'].toString(),
          };
        }),
      );
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _fetchRapidFixtures() async {
    final response = await http.get(
      Uri.parse(
        'https://v3.football.api-sports.io/fixtures?team=$_rapidTeamId&season=$_rapidSeason&next=10',
      ),
      headers: {
        'x-rapidapi-key': _rapidApiKey,
        'x-rapidapi-host': 'v3.football.api-sports.io',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> fixtures = List.from(data['response'] ?? []);

      try {
        final lastResponse = await http.get(
          Uri.parse(
            'https://v3.football.api-sports.io/fixtures?team=$_rapidTeamId&season=$_rapidSeason&last=5',
          ),
          headers: {
            'x-rapidapi-key': _rapidApiKey,
            'x-rapidapi-host': 'v3.football.api-sports.io',
          },
        );

        if (lastResponse.statusCode == 200) {
          final lastData = json.decode(lastResponse.body);
          fixtures.addAll(List.from(lastData['response'] ?? []));
        }
      } catch (e) {
        print('Error fetching last results RapidAPI: $e');
      }

      fixtures.sort(
        (a, b) => a['fixture']['date'].compareTo(b['fixture']['date']),
      );

      return fixtures.map((match) {
        final fixture = match['fixture'];
        final league = match['league'];
        final teams = match['teams'];
        final goals = match['goals'];

        final isHome = teams['home']['id'].toString() == _rapidTeamId;

        return {
          'date': _formatDate(fixture['date']),
          'homeTeam': teams['home']['name'],
          'awayTeam': teams['away']['name'],
          'homeScore': goals['home'] ?? 0,
          'awayScore': goals['away'] ?? 0,
          'time':
              fixture['status']['short'] == 'FT'
                  ? 'FT'
                  : _formatTime(fixture['date']),
          'league': league['name'],
          'isHome': isHome,
          'status': fixture['status']['short'] == 'FT' ? 'played' : 'upcoming',
          'logoHome': teams['home']['logo'],
          'logoAway': teams['away']['logo'],
        };
      }).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _fetchFdFixtures() async {
    final response = await http.get(
      Uri.parse(
        'https://api.football-data.org/v4/teams/$_fdTeamId/matches?status=SCHEDULED,FINISHED&limit=20',
      ),
      headers: {'X-Auth-Token': _fdApiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final matches = List<dynamic>.from(data['matches'] ?? []);

      return matches.map((match) {
        final isHome = match['homeTeam']['name'] == 'Manchester United FC';
        return {
          'date': _formatDate(match['utcDate']),
          'homeTeam':
              match['homeTeam']['shortName'] ?? match['homeTeam']['name'],
          'awayTeam':
              match['awayTeam']['shortName'] ?? match['awayTeam']['name'],
          'homeScore': match['score']['fullTime']['home'] ?? 0,
          'awayScore': match['score']['fullTime']['away'] ?? 0,
          'time':
              match['status'] == 'FINISHED'
                  ? 'FT'
                  : _formatTime(match['utcDate']),
          'league': match['competition']['name'] ?? 'Premier League',
          'isHome': isHome,
          'status': match['status'] == 'FINISHED' ? 'played' : 'upcoming',
          'logoHome': match['homeTeam']['crest'],
          'logoAway': match['awayTeam']['crest'],
        };
      }).toList();
    }
    return [];
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      if (timeStr.contains('T')) {
        final date = DateTime.parse(timeStr);
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  Future<List<Map<String, dynamic>>> fetchNextFixtures() async {
    final allFixtures = await getUnifiedFixtures();
    final upcoming =
        allFixtures
            .where(
              (m) =>
                  m['status'] == 'upcoming' ||
                  m['status'] == 'TIMED' ||
                  m['status'] == 'SCHEDULED',
            )
            .toList();

    return upcoming;
  }

  Future<List<Map<String, dynamic>>> fetchLastResults() async {
    return getUnifiedFixtures();
  }

  List<Map<String, dynamic>> _getDummyStandings() {
    return [
      {
        'strTeam': 'Arsenal',
        'strBadge': 'https://media.api-sports.io/football/teams/42.png',
        'intRank': '1',
        'intPlayed': '15',
        'intWin': '10',
        'intDraw': '3',
        'intLoss': '2',
        'intGoalDifference': '+19',
        'intPoints': '33',
        'strForm': 'WWDWL',
        'intGoalsFor': '29',
        'intGoalsAgainst': '10',
      },
      {
        'strTeam': 'Manchester City',
        'strBadge': 'https://media.api-sports.io/football/teams/50.png',
        'intRank': '2',
        'intPlayed': '15',
        'intWin': '10',
        'intDraw': '1',
        'intLoss': '4',
        'intGoalDifference': '+19',
        'intPoints': '31',
        'strForm': 'LWWWW',
        'intGoalsFor': '35',
        'intGoalsAgainst': '16',
      },
      {
        'strTeam': 'Aston Villa',
        'strBadge': 'https://media.api-sports.io/football/teams/66.png',
        'intRank': '3',
        'intPlayed': '15',
        'intWin': '9',
        'intDraw': '3',
        'intLoss': '3',
        'intGoalDifference': '+7',
        'intPoints': '30',
        'strForm': 'WWWWW',
        'intGoalsFor': '25',
        'intGoalsAgainst': '18',
      },
      {
        'strTeam': 'Chelsea',
        'strBadge': 'https://media.api-sports.io/football/teams/49.png',
        'intRank': '4',
        'intPlayed': '15',
        'intWin': '7',
        'intDraw': '4',
        'intLoss': '4',
        'intGoalDifference': '+10',
        'intPoints': '25',
        'strForm': 'WWDLL',
        'intGoalsFor': '25',
        'intGoalsAgainst': '15',
      },
      {
        'strTeam': 'Liverpool',
        'strBadge': 'https://media.api-sports.io/football/teams/40.png',
        'intRank': '5',
        'intPlayed': '15',
        'intWin': '8',
        'intDraw': '1',
        'intLoss': '6',
        'intGoalDifference': '+9',
        'intPoints': '25',
        'strForm': 'WWLWW',
        'intGoalsFor': '23',
        'intGoalsAgainst': '14',
      },
      {
        'strTeam': 'Everton',
        'strBadge': 'https://media.api-sports.io/football/teams/45.png',
        'intRank': '6',
        'intPlayed': '15',
        'intWin': '7',
        'intDraw': '3',
        'intLoss': '5',
        'intGoalDifference': '+1',
        'intPoints': '24',
        'strForm': 'WDWDW',
        'intGoalsFor': '18',
        'intGoalsAgainst': '17',
      },
      {
        'strTeam': 'Crystal Palace',
        'strBadge': 'https://media.api-sports.io/football/teams/52.png',
        'intRank': '7',
        'intPlayed': '14',
        'intWin': '6',
        'intDraw': '3',
        'intLoss': '5',
        'intGoalDifference': '+7',
        'intPoints': '21',
        'strForm': 'WWDWL',
        'intGoalsFor': '18',
        'intGoalsAgainst': '11',
      },
      {
        'strTeam': 'Sunderland',
        'strBadge': 'https://media.api-sports.io/football/teams/41.png',
        'intRank': '8',
        'intPlayed': '15',
        'intWin': '6',
        'intDraw': '3',
        'intLoss': '6',
        'intGoalDifference': '+1',
        'intPoints': '21',
        'strForm': 'LWDWL',
        'intGoalsFor': '18',
        'intGoalsAgainst': '17',
      },
      {
        'strTeam': 'Tottenham Hotspur',
        'strBadge': 'https://media.api-sports.io/football/teams/47.png',
        'intRank': '9',
        'intPlayed': '15',
        'intWin': '6',
        'intDraw': '3',
        'intLoss': '6',
        'intGoalDifference': '+7',
        'intPoints': '21',
        'strForm': 'LWWDL',
        'intGoalsFor': '25',
        'intGoalsAgainst': '18',
      },
      {
        'strTeam': 'Brighton & Hove Albion',
        'strBadge': 'https://media.api-sports.io/football/teams/51.png',
        'intRank': '10',
        'intPlayed': '14',
        'intWin': '6',
        'intDraw': '2',
        'intLoss': '6',
        'intGoalDifference': '+4',
        'intPoints': '20',
        'strForm': 'WWLWL',
        'intGoalsFor': '24',
        'intGoalsAgainst': '20',
      },
      {
        'strTeam': 'Newcastle United',
        'strBadge': 'https://media.api-sports.io/football/teams/34.png',
        'intRank': '11',
        'intPlayed': '15',
        'intWin': '6',
        'intDraw': '2',
        'intLoss': '7',
        'intGoalDifference': '+2',
        'intPoints': '20',
        'strForm': 'LWLWL',
        'intGoalsFor': '22',
        'intGoalsAgainst': '20',
      },
      {
        'strTeam': 'Manchester United',
        'strBadge': 'https://media.api-sports.io/football/teams/33.png',
        'intRank': '12',
        'intPlayed': '14',
        'intWin': '6',
        'intDraw': '4',
        'intLoss': '4',
        'intGoalDifference': '+1',
        'intPoints': '22',
        'strForm': 'DDLWD',
        'intGoalsFor': '22',
        'intGoalsAgainst': '21',
      },
      {
        'strTeam': 'AFC Bournemouth',
        'strBadge': 'https://media.api-sports.io/football/teams/35.png',
        'intRank': '13',
        'intPlayed': '15',
        'intWin': '5',
        'intDraw': '5',
        'intLoss': '5',
        'intGoalDifference': '-3',
        'intPoints': '20',
        'strForm': 'DDLWL',
        'intGoalsFor': '21',
        'intGoalsAgainst': '24',
      },
      {
        'strTeam': 'Brentford',
        'strBadge': 'https://media.api-sports.io/football/teams/55.png',
        'intRank': '14',
        'intPlayed': '15',
        'intWin': '5',
        'intDraw': '3',
        'intLoss': '7',
        'intGoalDifference': '-3',
        'intPoints': '18',
        'strForm': 'LWDWL',
        'intGoalsFor': '21',
        'intGoalsAgainst': '24',
      },
      {
        'strTeam': 'Fulham',
        'strBadge': 'https://media.api-sports.io/football/teams/36.png',
        'intRank': '15',
        'intPlayed': '14',
        'intWin': '5',
        'intDraw': '2',
        'intLoss': '7',
        'intGoalDifference': '-3',
        'intPoints': '17',
        'strForm': 'WLDWW',
        'intGoalsFor': '19',
        'intGoalsAgainst': '22',
      },
      {
        'strTeam': 'Nottingham Forest',
        'strBadge': 'https://media.api-sports.io/football/teams/65.png',
        'intRank': '16',
        'intPlayed': '15',
        'intWin': '4',
        'intDraw': '3',
        'intLoss': '8',
        'intGoalDifference': '-11',
        'intPoints': '15',
        'strForm': 'LWLLL',
        'intGoalsFor': '14',
        'intGoalsAgainst': '25',
      },
      {
        'strTeam': 'West Ham United',
        'strBadge': 'https://media.api-sports.io/football/teams/48.png',
        'intRank': '17',
        'intPlayed': '15',
        'intWin': '4',
        'intDraw': '2',
        'intLoss': '9',
        'intGoalDifference': '-10',
        'intPoints': '14',
        'strForm': 'LLLWL',
        'intGoalsFor': '17',
        'intGoalsAgainst': '27',
      },
      {
        'strTeam': 'Leicester City',
        'strBadge': 'https://media.api-sports.io/football/teams/46.png',
        'intRank': '18',
        'intPlayed': '15',
        'intWin': '3',
        'intDraw': '3',
        'intLoss': '9',
        'intGoalDifference': '-13',
        'intPoints': '12',
        'strForm': 'LLDLL',
        'intGoalsFor': '16',
        'intGoalsAgainst': '29',
      },
      {
        'strTeam': 'Wolverhampton Wanderers',
        'strBadge': 'https://media.api-sports.io/football/teams/39.png',
        'intRank': '19',
        'intPlayed': '15',
        'intWin': '2',
        'intDraw': '4',
        'intLoss': '9',
        'intGoalDifference': '-18',
        'intPoints': '10',
        'strForm': 'DLLLD',
        'intGoalsFor': '20',
        'intGoalsAgainst': '38',
      },
      {
        'strTeam': 'Southampton',
        'strBadge': 'https://media.api-sports.io/football/teams/41.png',
        'intRank': '20',
        'intPlayed': '14',
        'intWin': '1',
        'intDraw': '2',
        'intLoss': '11',
        'intGoalDifference': '-17',
        'intPoints': '5',
        'strForm': 'LLLLL',
        'intGoalsFor': '10',
        'intGoalsAgainst': '27',
      },
    ];
  }

  // --- News API ---
  Future<List<Map<String, dynamic>>> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://newsapi.org/v2/everything?q=manchester+united&language=en&sortBy=publishedAt&pageSize=50',
        ),
        headers: {'X-Api-Key': _newsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;

        print('📰 Total articles from API: ${articles.length}');

        // Filter: only articles with images and MU-related
        final filteredArticles =
            articles.where((article) {
              final hasImage =
                  article['urlToImage'] != null &&
                  article['urlToImage'].toString().isNotEmpty;
              final title = article['title']?.toString().toLowerCase() ?? '';
              final description =
                  article['description']?.toString().toLowerCase() ?? '';

              // Check if article mentions Manchester United
              final isMURelated =
                  title.contains('manchester united') ||
                  title.contains('man united') ||
                  title.contains('man utd') ||
                  description.contains('manchester united');

              if (!hasImage) {
                print('❌ No image: ${article['title']}');
              }
              if (!isMURelated) {
                print('❌ Not MU: ${article['title']}');
              }

              return hasImage && isMURelated;
            }).toList();

        print('✅ Filtered articles with image & MU: ${filteredArticles.length}');

        return filteredArticles.map((article) {
          return {
            'title': article['title'] ?? 'No Title',
            'description': article['description'] ?? '',
            'image': article['urlToImage'] ?? '',
            'date': _formatNewsDate(article['publishedAt']),
            'source': article['source']['name'] ?? 'Unknown',
            'url': article['url'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      print('NewsAPI Failed: $e');
    }

    // Fallback to DummyData
    return DummyData.news;
  }

  String _formatNewsDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inHours < 1) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
