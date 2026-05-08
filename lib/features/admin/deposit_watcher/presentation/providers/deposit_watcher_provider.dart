import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/features/admin/deposit_watcher/data/datasources/deposit_watcher_remote_datasource.dart';

class DepositWatcherProvider extends ChangeNotifier {
  final DepositWatcherRemoteDatasource _ds;

  DepositWatcherProvider({DepositWatcherRemoteDatasource? ds})
      : _ds = ds ?? DepositWatcherRemoteDatasource();

  List<DepositWatcherCursorInfo> _cursors = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  List<DepositWatcherCursorInfo> get cursors => _cursors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> loadCursors() async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      _cursors = await _ds.listCursors();
    } catch (e) {
      _error = e.toString();
      debugPrint('loadCursors error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetCursor(String chain) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _ds.resetCursor(chain);
      await loadCursors();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('resetCursor error: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetAllCursors() async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _ds.resetAllCursors();
      await loadCursors();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('resetAllCursors error: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
