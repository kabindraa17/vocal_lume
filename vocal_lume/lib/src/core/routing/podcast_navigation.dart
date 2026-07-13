import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/podcast/domain/podcast_feed_preview.dart';
import 'app_routes.dart';

extension PodcastNavigation on BuildContext {
  void openPodcastDetail({
    required int feedId,
    PodcastFeedPreview? preview,
  }) {
    pushNamed(
      AppRoutes.podcastDetail,
      pathParameters: {'id': '$feedId'},
      extra: preview,
    );
  }
}
