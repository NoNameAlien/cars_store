import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/catalog/presentation/cubit/catalog_cubit.dart';

class CatalogConnectionObserver extends StatefulWidget {
  const CatalogConnectionObserver({super.key, required this.child});
  final Widget child;

  @override
  State<CatalogConnectionObserver> createState() =>
      _CatalogConnectionObserverState();
}

class _CatalogConnectionObserverState extends State<CatalogConnectionObserver>
    with WidgetsBindingObserver {
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  int _eventRevision = 0;
  bool _foreground = true;
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        ++_eventRevision;
        if (mounted && results.isNotEmpty) {
          context.read<CatalogCubit>().connectionChanged(
            results.any((value) => value != ConnectivityResult.none),
            refresh: _foreground,
          );
        }
      },
      onError: (Object error) {
        // A monitoring failure is not evidence that the internet is unavailable.
      },
    );
    unawaited(_check());
  }

  Future<void> _check({bool resumed = false}) async {
    final revision = _eventRevision;
    try {
      final results = await _connectivity.checkConnectivity();
      if (!mounted) {
        return;
      }
      if (revision == _eventRevision && results.isNotEmpty) {
        context.read<CatalogCubit>().connectionChanged(
          results.any((value) => value != ConnectivityResult.none),
          refresh: _foreground,
        );
      }
    } catch (_) {}
    if (mounted && resumed) {
      context.read<CatalogCubit>().refreshOnResume();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _foreground = false;
      _wasBackgrounded = true;
    } else if (state == AppLifecycleState.resumed) {
      _foreground = true;
      if (_wasBackgrounded) {
        _wasBackgrounded = false;
        unawaited(_check(resumed: true));
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
