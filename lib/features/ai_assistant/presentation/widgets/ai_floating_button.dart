import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';

/// Floating action button shown on top of the main scaffold. Hidden for guests.
/// Pushes the AI Assistant list screen.
class AiFloatingButton extends StatelessWidget {
  final bool visible;

  const AiFloatingButton({super.key, this.visible = true});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned(
      right: 16,
      bottom: 80,
      child: Material(
        elevation: 4,
        shape: const CircleBorder(),
        color: Theme.of(context).colorScheme.primary,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.push(AppRoutes.aiAssistant),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(
              Icons.smart_toy_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
