import 'package:flutter/material.dart';

/// Market Maker Hub entry screen.
///
/// This is a lightweight navigation hub for MM workflows while feature
/// screens are being implemented incrementally.
class MarketMakerHubScreen extends StatelessWidget {
  const MarketMakerHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khu vuc Market Maker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FeatureCard(
            icon: Icons.tune,
            title: 'Cau hinh Market Maker',
            description: 'Quan ly spread, stop-loss, va gioi han vi the theo cap giao dich.',
          ),
          SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.auto_graph,
            title: 'Dat lenh Maker',
            description: 'Dat cap lenh BUY/SELL quanh gia thi truong bang batch orders.',
          ),
          SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.dashboard_customize,
            title: 'Dashboard vi the',
            description: 'Theo doi lenh mo, vi the va P/L unrealized theo thoi gian thuc.',
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
      ),
    );
  }
}
