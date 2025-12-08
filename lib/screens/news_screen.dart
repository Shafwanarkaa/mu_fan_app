import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<Map<String, dynamic>>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = ApiService().fetchNews();
  }

  Future<void> _refreshNews() async {
    setState(() {
      _newsFuture = ApiService().fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LATEST NEWS'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshNews),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNews,
        color: AppTheme.muRed,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.muRed),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No news found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final newsList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                return FadeInUp(
                  delay: Duration(milliseconds: index * 50),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (news['image'] != null && news['image'].isNotEmpty)
                          Container(
                            height: 200,
                            child: Image.network(
                              news['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 60,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    news['source'] ?? '',
                                    style: const TextStyle(
                                      color: AppTheme.muGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    news['date'] ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                news['title'] ?? 'No Title',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              if (news['description'] != null &&
                                  news['description'].isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  news['description'],
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[400]),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
