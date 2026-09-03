import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _online = true;
  final _controller = StreamController<bool>.broadcast();

  bool get isOnline => _online;
  Stream<bool> get changes => _controller.stream;

  Future<void> init() async {
    try {
      final res = await _connectivity.checkConnectivity();
      _online = !res.contains(ConnectivityResult.none);
    } catch (_) {
      _online = true;
    }
    _sub = _connectivity.onConnectivityChanged.listen((res) {
      _online = !res.contains(ConnectivityResult.none);
      _controller.add(_online);
    });
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
