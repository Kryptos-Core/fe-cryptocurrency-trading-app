enum BlockchainNetwork {
  tronNile,
  tronShasta,
  solanaDevnet,
  ethSepolia,
}

extension BlockchainNetworkX on BlockchainNetwork {
  String get apiValue {
    switch (this) {
      case BlockchainNetwork.tronNile:
        return 'TRON_NILE';
      case BlockchainNetwork.tronShasta:
        return 'TRON_SHASTA';
      case BlockchainNetwork.solanaDevnet:
        return 'SOLANA_DEVNET';
      case BlockchainNetwork.ethSepolia:
        return 'ETH_SEPOLIA';
    }
  }

  String get label {
    switch (this) {
      case BlockchainNetwork.tronNile:
        return 'Tron Nile';
      case BlockchainNetwork.tronShasta:
        return 'Tron Shasta';
      case BlockchainNetwork.solanaDevnet:
        return 'Solana Devnet';
      case BlockchainNetwork.ethSepolia:
        return 'Sepolia ETH';
    }
  }

  static BlockchainNetwork fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'TRON_NILE':
        return BlockchainNetwork.tronNile;
      case 'TRON_SHASTA':
        return BlockchainNetwork.tronShasta;
      case 'SOLANA_DEVNET':
        return BlockchainNetwork.solanaDevnet;
      case 'ETH_SEPOLIA':
        return BlockchainNetwork.ethSepolia;
      default:
        throw ArgumentError('Unsupported blockchain network: $value');
    }
  }
}
