import 'package:equatable/equatable.dart';

import '../../domain/cart_item.dart';

enum CartStatus { initial, loading, ready, readError }

enum CartIssue { corruptData, readFailed, writeFailed }

class CartState extends Equatable {
  CartState({
    this.status = CartStatus.initial,
    List<CartItem> items = const [],
    this.isSaving = false,
    this.isCheckingOut = false,
    this.issue,
  }) : items = List.unmodifiable(items),
       totalQuantity = items.fold<int>(0, (sum, item) => sum + item.quantity),
       totalCents = items.fold<int>(0, (sum, item) => sum + item.totalCents);
  final CartStatus status;
  final List<CartItem> items;
  final bool isSaving;
  final bool isCheckingOut;
  final CartIssue? issue;
  final int totalQuantity;
  final int totalCents;
  int quantityOf(int id) {
    for (final item in items) {
      if (item.productId == id) return item.quantity;
    }
    return 0;
  }

  @override
  List<Object?> get props => [status, items, isSaving, isCheckingOut, issue];
}
