import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/theme.dart';
import '../../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../../features/catalog/presentation/cubit/catalog_state.dart';

class CatalogConnectionNotice extends StatelessWidget {
  const CatalogConnectionNotice({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<CatalogCubit, CatalogState, CatalogConnection>(
        selector: (state) => state.connection,
        builder: (context, connection) {
          if (connection != CatalogConnection.offline &&
              connection != CatalogConnection.checking) {
            return const SizedBox.shrink();
          }
          final offline = connection == CatalogConnection.offline;
          return Container(
            width: double.infinity,
            color: const Color(0xFFE6F3EF),
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                offline
                    ? 'Нет соединения. Корзина работает локально.'
                    : 'Подключение появилось. Проверяем доступ к каталогу…',
                style: const TextStyle(color: StoreColors.accent),
              ),
            ),
          );
        },
      );
}
