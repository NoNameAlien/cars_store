import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../cubit/catalog_state.dart';

String failureMessage(AppFailure failure) => switch (failure.kind) {
  FailureKind.noConnection =>
    'Не удалось подключиться к серверу. Проверьте подключение к интернету.',
  FailureKind.timeout => 'Сервер не ответил вовремя. Попробуйте ещё раз.',
  FailureKind.clientError => 'Сервер отклонил запрос. Попробуйте позже.',
  FailureKind.serverError => 'На сервере временная ошибка. Попробуйте позже.',
  FailureKind.unexpected => 'Не удалось загрузить каталог. Попробуйте ещё раз.',
};

class CatalogNotice extends StatelessWidget {
  const CatalogNotice({super.key, required this.state});
  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final warning = state.failure != null || state.cacheWriteFailed;
    final time = state.updatedAt?.toLocal();
    final date = time == null
        ? ''
        : ' · ${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final message = state.failure != null
        ? '${failureMessage(state.failure!)} ${state.isFromCache ? 'Показан сохранённый каталог.' : 'Показан последний загруженный каталог.'}'
        : state.cacheWriteFailed
        ? 'Каталог обновлён, но сохранить его на устройстве не удалось.'
        : 'Сохранённый каталог$date${state.isRefreshing ? ' · Проверяем обновления' : ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFF4DE) : const Color(0xFFE6F3EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.info_outline_rounded : Icons.offline_pin_outlined,
            size: 20,
            color: warning ? const Color(0xFF8A6119) : StoreColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: warning ? const Color(0xFF795719) : StoreColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogFeedback extends StatelessWidget {
  const CatalogFeedback({
    super.key,
    this.failure,
    required this.onRetry,
    this.title,
    this.message,
    this.buttonLabel,
  });
  final AppFailure? failure;
  final VoidCallback onRetry;
  final String? title;
  final String? message;
  final String? buttonLabel;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFE6F3EF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                failure == null
                    ? Icons.inventory_2_outlined
                    : Icons.cloud_off_rounded,
                size: 40,
                color: StoreColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ??
                  (failure == null ? 'Пока здесь пусто' : 'Каталог недоступен'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              message ??
                  (failure == null
                      ? 'Сейчас в каталоге нет товаров. Загляните чуть позже.'
                      : failureMessage(failure!)),
              textAlign: TextAlign.center,
              style: const TextStyle(color: StoreColors.muted, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                buttonLabel ??
                    (failure == null ? 'Обновить каталог' : 'Повторить'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CatalogSkeleton extends StatelessWidget {
  const CatalogSkeleton({
    super.key,
    required this.columns,
    required this.extent,
  });
  final int columns;
  final double extent;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Загрузка каталога',
    child: GridView.builder(
      itemCount: columns * 2,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: extent,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: StoreColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: StoreColors.canvas,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(width: 90, height: 12, color: StoreColors.canvas),
            const SizedBox(height: 12),
            Container(height: 16, color: StoreColors.canvas),
            const SizedBox(height: 12),
            Container(width: 65, height: 24, color: StoreColors.canvas),
          ],
        ),
      ),
    ),
  );
}
