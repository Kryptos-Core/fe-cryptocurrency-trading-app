import 'package:equatable/equatable.dart';

enum BinancePermission { spot, futures }

class BinanceCredentials extends Equatable {
  final String id;
  final String? label;
  final List<BinancePermission> permissions;
  final bool testnet;
  final bool isActive;
  final DateTime? lastUsedAt;
  final DateTime createdAt;

  const BinanceCredentials({
    required this.id,
    this.label,
    required this.permissions,
    required this.testnet,
    required this.isActive,
    this.lastUsedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, label, permissions, testnet, isActive, lastUsedAt, createdAt];
}
