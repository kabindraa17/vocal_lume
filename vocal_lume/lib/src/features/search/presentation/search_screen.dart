import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/podcast_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../podcast/data/models/podcast_feed.dart';
import '../../podcast/presentation/widgets/podcast_artwork.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    _debounce?.cancel();
    setState(() => _query = value.trim());
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _query = '');
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(podcastSearchProvider(_query));
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SearchBar(
                controller: _controller,
                hintText: 'Search podcasts...',
                leading: const Icon(Icons.search),
                trailing: _query.isEmpty
                    ? null
                    : [
                        IconButton(
                          onPressed: () {
                            _controller.clear();
                            _submit('');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                onSubmitted: _submit,
                onChanged: _onChanged,
              ),
            ),
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.travel_explore_rounded,
                            size: 48,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Search by title, topic, or host',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : results.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                'Search failed. Check your connection.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => ref.invalidate(
                                  podcastSearchProvider(_query),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (feeds) => feeds.isEmpty
                          ? Center(
                              child: Text('No results for "$_query"'),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: feeds.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) =>
                                  _SearchResultTile(feed: feeds[index]),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.feed});

  final PodcastFeed feed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: PodcastArtwork(feed: feed),
      title: Text(
        feed.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(feed.hostName),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () => context.pushNamed(
        AppRoutes.podcastDetail,
        pathParameters: {'id': '${feed.id}'},
      ),
    );
  }
}
