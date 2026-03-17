import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/data/datasources/user_remote_datasource.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// Màn hình cho Admin/Risk Officer duyệt yêu cầu thay đổi bảo mật (email/password).
class SecurityRequestsReviewScreen extends StatefulWidget {
  const SecurityRequestsReviewScreen({super.key});

  @override
  State<SecurityRequestsReviewScreen> createState() =>
      _SecurityRequestsReviewScreenState();
}

class _SecurityRequestsReviewScreenState
    extends State<SecurityRequestsReviewScreen> {
  List<SecurityChangeRequestItem> _pending = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = sl<TokenService>().getAccessToken();
    if (token == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result =
        await sl<AuthRepository>().getPendingSecurityChangeRequests(token);
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
      (list) => setState(() {
        _pending = list;
        _loading = false;
      }),
    );
  }

  Future<void> _approve(SecurityChangeRequestItem item) async {
    final token = sl<TokenService>().getAccessToken();
    if (token == null) return;
    final result = await sl<AuthRepository>().approveSecurityChangeRequest(
      item.requestId,
      token,
    );
    result.fold(
      (f) {
        if (mounted) {
          showAppSnackBar(context, message: f.message, type: SnackBarType.error);
        }
      },
      (_) {
        if (mounted) {
          showAppSnackBar(
            context,
            message: AppLocalizations.of(context).securityRequestApproved,
            type: SnackBarType.success,
          );
          _load();
        }
      },
    );
  }

  Future<void> _reject(SecurityChangeRequestItem item) async {
    final token = sl<TokenService>().getAccessToken();
    if (token == null) return;
    String? note;
    if (mounted) {
        note = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final l10n = AppLocalizations.of(ctx);
          final c = TextEditingController();
          return AlertDialog(
            title: Text(l10n.securityRejectDialogTitle),
            content: TextField(
              controller: c,
              decoration: InputDecoration(hintText: l10n.securityRejectReasonHint),
              maxLines: 2,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, c.text.trim()),
                child: Text(l10n.securityRequestReject),
              ),
            ],
          );
        },
      );
    }
    if (!mounted) return;
    final result = await sl<AuthRepository>().rejectSecurityChangeRequest(
      item.requestId,
      token,
      reviewNote: note?.isEmpty == true ? null : note,
    );
    result.fold(
      (f) {
        if (mounted) {
          showAppSnackBar(context, message: f.message, type: SnackBarType.error);
        }
      },
      (_) {
        if (mounted) {
          showAppSnackBar(
            context,
            message: AppLocalizations.of(context).securityRequestRejected,
            type: SnackBarType.success,
          );
          _load();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).securityRequestsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
            tooltip: AppLocalizations.of(context).refresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _load,
                        child: Text(AppLocalizations.of(context).retry),
                      ),
                    ],
                  ),
                )
              : _pending.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context).securityRequestNoPending))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pending.length,
                      itemBuilder: (context, index) {
                        final item = _pending[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              '${item.changeType} — ${item.userEmail}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.firstName != null ||
                                    item.lastName != null)
                                  Text(
                                    '${item.firstName ?? ''} ${item.lastName ?? ''}'
                                        .trim(),
                                  ),
                                Text(
                                  AppLocalizations.of(context).securityRequestRequested(_formatDate(item.requestedAt)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () => _approve(item),
                                  child: Text(AppLocalizations.of(context).securityRequestApprove),
                                ),
                                TextButton(
                                  onPressed: () => _reject(item),
                                  child: Text(
                                    AppLocalizations.of(context).securityRequestReject,
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}
