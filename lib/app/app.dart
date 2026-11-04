import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../features/cart/presentation/cubit/cart_cubit.dart';
import 'dependencies.dart';
import 'router.dart';
import 'theme.dart';
import 'catalog_connection_observer.dart';

class StoreApp extends StatefulWidget {
  const StoreApp({super.key, required this.dependencies});
  final AppDependencies dependencies;

  @override
  State<StoreApp> createState() => _StoreAppState();
}

class _StoreAppState extends State<StoreApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    widget.dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            CatalogCubit(widget.dependencies.catalogRepository)..load(),
        lazy: false,
      ),
      BlocProvider(
        create: (_) =>
            CartCubit(widget.dependencies.cartRepository)..initialize(),
        lazy: false,
      ),
    ],
    child: CatalogConnectionObserver(
      child: MaterialApp.router(
        title: 'Cars Store',
        debugShowCheckedModeBanner: false,
        theme: createTheme(),
        routerConfig: _router,
      ),
    ),
  );
}
