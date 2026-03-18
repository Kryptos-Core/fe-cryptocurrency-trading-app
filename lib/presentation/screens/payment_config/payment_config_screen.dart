import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/data/models/payment_method_config_model.dart';
import 'package:crypto_trading_app/presentation/providers/payment_config_provider.dart';

/// Payment Method Config Screen — accessible only to ADMIN and FINANCE_MANAGER.
/// Allows dynamic management of PayOS credentials, blockchain hot wallet keys,
/// and network settings without restarting the server.
class PaymentConfigScreen extends StatefulWidget {
  const PaymentConfigScreen({super.key});

  @override
  State<PaymentConfigScreen> createState() => _PaymentConfigScreenState();
}

class _PaymentConfigScreenState extends State<PaymentConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentConfigProvider>().loadConfigs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cấu hình Thanh toán'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PaymentConfigProvider>().loadConfigs(),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateConfigSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm phương thức'),
      ),
      body: Consumer<PaymentConfigProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.configs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.configs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(provider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.loadConfigs,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.configs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Chưa có cấu hình nào.\nNhấn "Thêm phương thức" để tạo mới.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadConfigs,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: provider.configs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final config = provider.configs[index];
                return _PaymentConfigCard(
                  config: config,
                  onEdit: () => _showEditConfigSheet(context, config),
                  onActivate: () => _confirmActivate(context, config),
                  onDeactivate: () => _confirmDeactivate(context, config),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateConfigSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PaymentConfigProvider>(),
        child: const _ConfigFormSheet(configId: null),
      ),
    );
  }

  void _showEditConfigSheet(BuildContext context, PaymentMethodConfigModel config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PaymentConfigProvider>(),
        child: _ConfigFormSheet(configId: config.configId, existing: config),
      ),
    );
  }

  Future<void> _confirmActivate(BuildContext context, PaymentMethodConfigModel config) async {
    final provider = context.read<PaymentConfigProvider>();
    final graceMinsController = TextEditingController(
      text: config.gracePeriodMinutes.toString(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kích hoạt cấu hình'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kích hoạt: ${config.displayName}'),
            const SizedBox(height: 4),
            const Text(
              'Hệ thống sẽ vào trạng thái TRANSITIONING. Trader sẽ nhận banner cảnh báo trong grace period.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: graceMinsController,
              decoration: const InputDecoration(
                labelText: 'Grace period (phút)',
                border: OutlineInputBorder(),
                helperText: 'Thời gian chờ trước khi config mới có hiệu lực',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kích hoạt'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final graceMins = int.tryParse(graceMinsController.text) ?? config.gracePeriodMinutes;
    final result = await provider.activateConfig(config.configId, gracePeriodMinutes: graceMins);

    if (!context.mounted) return;
    if (result != null) {
      final activatesAt = result['activatesAt'] as String?;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã bắt đầu grace period ${graceMins} phút'
            '${activatesAt != null ? ". Kích hoạt lúc: ${activatesAt.substring(0, 16).replaceAll('T', ' ')}" : ""}',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Lỗi kích hoạt cấu hình'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDeactivate(BuildContext context, PaymentMethodConfigModel config) async {
    final provider = context.read<PaymentConfigProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vô hiệu hóa cấu hình'),
        content: Text(
          'Bạn có chắc muốn vô hiệu hóa "${config.displayName}"?\nThao tác này có hiệu lực ngay lập tức.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vô hiệu hóa'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await provider.deactivateConfig(config.configId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã vô hiệu hóa' : (provider.error ?? 'Lỗi')),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}

// ── Payment Config Card ──────────────────────────────────────────────────────

class _PaymentConfigCard extends StatelessWidget {
  final PaymentMethodConfigModel config;
  final VoidCallback onEdit;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  const _PaymentConfigCard({
    required this.config,
    required this.onEdit,
    required this.onActivate,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = config.isActive
        ? Colors.green
        : config.isTransitioning
            ? Colors.orange
            : Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.displayName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${config.typeLabel} · ${config.network}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: config.status, color: statusColor),
              ],
            ),
            if (config.isTransitioning && config.graceMinsRemaining != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.hourglass_top, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Còn ~${config.graceMinsRemaining} phút trước khi kích hoạt',
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Phiên bản: v${config.configVersion} · Sắp xếp: ${config.sortOrder}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            if (config.activatedAt != null)
              Text(
                'Kích hoạt: ${_formatDate(config.activatedAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Chỉnh sửa'),
                ),
                const SizedBox(width: 8),
                if (!config.isActive && !config.isTransitioning)
                  FilledButton.icon(
                    onPressed: onActivate,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Kích hoạt'),
                  )
                else if (config.isActive)
                  OutlinedButton.icon(
                    onPressed: onDeactivate,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text('Vô hiệu hóa'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'ACTIVE' => 'ĐANG HOẠT ĐỘNG',
      'TRANSITIONING' => 'ĐANG CHUYỂN ĐỔI',
      _ => 'KHÔNG HOẠT ĐỘNG',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

// ── Config Form Sheet ────────────────────────────────────────────────────────

/// Bottom sheet for creating or editing a payment method config.
/// Credentials (API keys, private keys) are masked by default.
class _ConfigFormSheet extends StatefulWidget {
  final String? configId;
  final PaymentMethodConfigModel? existing;

  const _ConfigFormSheet({this.configId, this.existing});

  @override
  State<_ConfigFormSheet> createState() => _ConfigFormSheetState();
}

class _ConfigFormSheetState extends State<_ConfigFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _type;
  late String _network;
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _graceMinsCtrl;

  // PayOS fields
  final _payosClientIdCtrl = TextEditingController();
  final _payosApiKeyCtrl = TextEditingController();
  final _payosChecksumKeyCtrl = TextEditingController();
  final _payosReturnUrlCtrl = TextEditingController();
  final _payosCancelUrlCtrl = TextEditingController();
  final _payosFiatSymbolCtrl = TextEditingController(text: 'VND');
  final _payosQuoteSymbolCtrl = TextEditingController(text: 'USDT');
  final _payosRateCtrl = TextEditingController(text: '0.00004');
  final _payosSpreadCtrl = TextEditingController(text: '0');

  // Blockchain fields
  final _rpcUrlCtrl = TextEditingController();
  final _hotWalletKeyCtrl = TextEditingController();
  final _withdrawMaxCtrl = TextEditingController(text: '0.5');
  final _nativeCurrencyCtrl = TextEditingController();
  final _fxFallbackRateCtrl = TextEditingController(text: '1');
  bool _isMainnet = false;

  bool _showSensitiveFields = false;
  bool _isSubmitting = false;

  final List<String> _types = ['PAYOS', 'ETH', 'TRON', 'SOL'];
  final Map<String, List<String>> _networks = {
    'PAYOS': ['MAINNET'],
    'ETH': ['SEPOLIA', 'MAINNET'],
    'TRON': ['NILE', 'SHASTA', 'MAINNET'],
    'SOL': ['DEVNET', 'MAINNET'],
  };

  @override
  void initState() {
    super.initState();
    _type = widget.existing?.type ?? 'PAYOS';
    _network = widget.existing?.network ?? 'MAINNET';
    _displayNameCtrl = TextEditingController(text: widget.existing?.displayName ?? '');
    _graceMinsCtrl = TextEditingController(
      text: (widget.existing?.gracePeriodMinutes ?? 15).toString(),
    );
    _isMainnet = _network == 'MAINNET';
    _nativeCurrencyCtrl.text = switch (_type) {
      'ETH' => 'ETH',
      'TRON' => 'TRX',
      'SOL' => 'SOL',
      _ => '',
    };
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _graceMinsCtrl.dispose();
    _payosClientIdCtrl.dispose();
    _payosApiKeyCtrl.dispose();
    _payosChecksumKeyCtrl.dispose();
    _payosReturnUrlCtrl.dispose();
    _payosCancelUrlCtrl.dispose();
    _payosFiatSymbolCtrl.dispose();
    _payosQuoteSymbolCtrl.dispose();
    _payosRateCtrl.dispose();
    _payosSpreadCtrl.dispose();
    _rpcUrlCtrl.dispose();
    _hotWalletKeyCtrl.dispose();
    _withdrawMaxCtrl.dispose();
    _nativeCurrencyCtrl.dispose();
    _fxFallbackRateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Form(
          key: _formKey,
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Text(
                    widget.configId == null ? 'Thêm phương thức' : 'Chỉnh sửa cấu hình',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Type selector
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Loại phương thức',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() {
                    _type = v;
                    _network = _networks[v]!.first;
                    _nativeCurrencyCtrl.text = switch (v) {
                      'ETH' => 'ETH',
                      'TRON' => 'TRX',
                      'SOL' => 'SOL',
                      _ => '',
                    };
                  });
                },
              ),
              const SizedBox(height: 12),
              // Network selector
              DropdownButtonFormField<String>(
                value: _network,
                decoration: const InputDecoration(
                  labelText: 'Mạng',
                  border: OutlineInputBorder(),
                ),
                items: (_networks[_type] ?? [])
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() {
                    _network = v;
                    _isMainnet = v == 'MAINNET';
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên hiển thị',
                  border: OutlineInputBorder(),
                  hintText: 'VD: PayOS Ngân hàng MB',
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _graceMinsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Grace period (phút)',
                  border: OutlineInputBorder(),
                  helperText: 'Thời gian chờ khi kích hoạt trước khi có hiệu lực',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Thông tin xác thực',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _showSensitiveFields = !_showSensitiveFields),
                    icon: Icon(
                      _showSensitiveFields ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(_showSensitiveFields ? 'Ẩn' : 'Hiện'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_type == 'PAYOS') ..._buildPayOSFields(),
              if (_type != 'PAYOS') ..._buildBlockchainFields(),
              const SizedBox(height: 24),
              if (_isMainnet)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'MAINNET — cấu hình này ảnh hưởng đến tiền thực. Kiểm tra kỹ trước khi kích hoạt.',
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(widget.configId == null ? 'Tạo cấu hình' : 'Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPayOSFields() => [
        _MaskedTextField(
          controller: _payosClientIdCtrl,
          label: 'Client ID',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        _MaskedTextField(
          controller: _payosApiKeyCtrl,
          label: 'API Key',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        _MaskedTextField(
          controller: _payosChecksumKeyCtrl,
          label: 'Checksum Key',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _payosReturnUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'Return URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _payosCancelUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'Cancel URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _payosFiatSymbolCtrl,
              decoration: const InputDecoration(labelText: 'Fiat Symbol', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _payosQuoteSymbolCtrl,
              decoration: const InputDecoration(labelText: 'Quote Symbol', border: OutlineInputBorder()),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _payosRateCtrl,
              decoration: const InputDecoration(labelText: 'Tỉ giá (1 VND → X USDT)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _payosSpreadCtrl,
              decoration: const InputDecoration(labelText: 'FX Spread (bps)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ),
        ]),
      ];

  List<Widget> _buildBlockchainFields() => [
        TextFormField(
          controller: _rpcUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'RPC URL',
            border: OutlineInputBorder(),
            hintText: 'https://...',
          ),
        ),
        const SizedBox(height: 10),
        _MaskedTextField(
          controller: _hotWalletKeyCtrl,
          label: 'Hot Wallet Private Key',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _nativeCurrencyCtrl,
              decoration: const InputDecoration(labelText: 'Native Symbol', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _withdrawMaxCtrl,
              decoration: const InputDecoration(labelText: 'Withdraw Auto Max', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        TextFormField(
          controller: _fxFallbackRateCtrl,
          decoration: const InputDecoration(
            labelText: 'FX Fallback Rate (1 Native → X USDT)',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text('Mainnet'),
          subtitle: const Text('Bật nếu là mạng mainnet (tiền thực)'),
          value: _isMainnet,
          onChanged: (v) => setState(() => _isMainnet = v),
          contentPadding: EdgeInsets.zero,
        ),
      ];

  Map<String, dynamic> _buildConfigPayload() {
    if (_type == 'PAYOS') {
      return {
        'clientId': _payosClientIdCtrl.text.trim(),
        'apiKey': _payosApiKeyCtrl.text.trim(),
        'checksumKey': _payosChecksumKeyCtrl.text.trim(),
        'returnUrl': _payosReturnUrlCtrl.text.trim(),
        'cancelUrl': _payosCancelUrlCtrl.text.trim(),
        'fiatSymbol': _payosFiatSymbolCtrl.text.trim().toUpperCase(),
        'quoteCurrencySymbol': _payosQuoteSymbolCtrl.text.trim().toUpperCase(),
        'fiatToQuoteRate': _payosRateCtrl.text.trim(),
        'fxSpreadBps': _payosSpreadCtrl.text.trim(),
      };
    }
    return {
      'rpcUrl': _rpcUrlCtrl.text.trim(),
      'hotWalletPrivateKey': _hotWalletKeyCtrl.text.trim(),
      'nativeCurrencySymbol': _nativeCurrencyCtrl.text.trim().toUpperCase(),
      'withdrawAutoMax': _withdrawMaxCtrl.text.trim(),
      'fxFallbackRate': _fxFallbackRateCtrl.text.trim(),
      'isMainnet': _isMainnet,
    };
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<PaymentConfigProvider>();
    final configPayload = _buildConfigPayload();

    bool success;
    if (widget.configId == null) {
      success = await provider.createConfig(
        type: _type,
        network: _network,
        displayName: _displayNameCtrl.text.trim(),
        config: configPayload,
        gracePeriodMinutes: int.tryParse(_graceMinsCtrl.text) ?? 15,
      );
    } else {
      success = await provider.updateConfig(
        widget.configId!,
        displayName: _displayNameCtrl.text.trim(),
        config: configPayload.values.any((v) => v.toString().isNotEmpty) ? configPayload : null,
        gracePeriodMinutes: int.tryParse(_graceMinsCtrl.text),
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.configId == null ? 'Đã tạo cấu hình' : 'Đã cập nhật cấu hình'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _MaskedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool show;

  const _MaskedTextField({
    required this.controller,
    required this.label,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        helperText: show ? null : 'Ẩn — nhấn "Hiện" để xem',
      ),
    );
  }
}
