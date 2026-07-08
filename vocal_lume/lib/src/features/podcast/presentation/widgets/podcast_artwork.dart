import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/podcast_feed.dart';

class PodcastArtwork extends StatelessWidget {
  const PodcastArtwork({
    super.key,
    required this.feed,
    this.size = 56,
    this.borderRadius = 12,
  });

  final PodcastFeed feed;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = feed.artworkUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url.isEmpty
          ? _placeholder()
          : CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, _) => _placeholder(),
              errorWidget: (_, _, _) => _placeholder(),
            ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF2A1F3D),
      child: Icon(Icons.podcasts, color: Colors.white54, size: size * 0.45),
    );
  }
}
