import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import '../theme/app_colors.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.showAvatar = true,
    this.onSearch,
  });

  final bool showAvatar;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
      child: Row(
        children: [
          if (showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceHigh,
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            'VocaLume',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onSearch ?? () => context.goNamed(AppRoutes.podcastSearch),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
