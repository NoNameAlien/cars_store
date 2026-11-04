import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../catalog/domain/product.dart';
import '../../domain/cart_item.dart';
import '../../domain/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repository) : super(CartState());
  final CartRepository _repository;
  Future<void>? _initializing;
  Future<void> _saveTail = Future<void>.value();
  int _revision = 0;
  bool _isClosing = false;

  Future<void> initialize() {
    if (_isClosing || isClosed || state.status == CartStatus.ready) {
      return Future.value();
    }
    return _initializing ??= _restore().whenComplete(
      () => _initializing = null,
    );
  }

  Future<void> _restore() async {
    emit(CartState(status: CartStatus.loading));
    try {
      final items = await _repository.read();
      if (!_isClosing && !isClosed) {
        emit(CartState(status: CartStatus.ready, items: items));
      }
    } on CorruptCartException {
      if (!_isClosing && !isClosed) {
        emit(CartState(status: CartStatus.ready, issue: CartIssue.corruptData));
      }
    } catch (_) {
      if (!_isClosing && !isClosed) {
        emit(
          CartState(status: CartStatus.readError, issue: CartIssue.readFailed),
        );
      }
    }
  }

  Future<void> add(Product product) => _change((items) {
    final index = items.indexWhere((item) => item.productId == product.id);
    if (index < 0) {
      if (items.length >= 1000) return items;
      return [...items, CartItem.fromProduct(product)];
    }
    return _changeQuantity(items, product.id, 1);
  });
  Future<void> increment(int id) =>
      _change((items) => _changeQuantity(items, id, 1));
  Future<void> decrement(int id) =>
      _change((items) => _changeQuantity(items, id, -1));
  Future<void> remove(int id) => _change(
    (items) => items.any((item) => item.productId == id)
        ? items.where((item) => item.productId != id).toList()
        : items,
  );

  List<CartItem> _changeQuantity(List<CartItem> items, int id, int delta) {
    final index = items.indexWhere((item) => item.productId == id);
    if (index < 0 || items[index].quantity + delta > CartItem.maxQuantity) {
      return items;
    }
    final next = [...items];
    final quantity = items[index].quantity + delta;
    if (quantity <= 0) {
      next.removeAt(index);
    } else {
      next[index] = items[index].withQuantity(quantity);
    }
    return next;
  }

  Future<void> _change(
    List<CartItem> Function(List<CartItem>) transform,
  ) async {
    await initialize();
    if (_isClosing ||
        isClosed ||
        state.status != CartStatus.ready ||
        state.isCheckingOut) {
      return;
    }
    final items = transform(state.items);
    if (identical(items, state.items)) return;
    await _persist(items);
  }

  Future<void> retrySave() async {
    if (!_isClosing &&
        !isClosed &&
        state.status == CartStatus.ready &&
        !state.isCheckingOut) {
      await _persist(state.items);
    }
  }

  Future<void> _persist(List<CartItem> items) {
    final snapshot = List<CartItem>.unmodifiable(items);
    final revision = ++_revision;
    emit(CartState(status: CartStatus.ready, items: snapshot, isSaving: true));
    _saveTail = _saveTail.then((_) async {
      CartIssue? issue;
      try {
        await _repository.save(snapshot);
      } catch (_) {
        issue = CartIssue.writeFailed;
      }
      if (!_isClosing && !isClosed && revision == _revision) {
        emit(
          CartState(status: CartStatus.ready, items: state.items, issue: issue),
        );
      }
    });
    return _saveTail;
  }

  // Commit the empty cart before removing the visible items. A failed write
  // leaves the original cart available for a deliberate checkout retry.
  Future<bool> clearForCheckout() async {
    await initialize();
    if (_isClosing ||
        isClosed ||
        state.status != CartStatus.ready ||
        state.isCheckingOut ||
        state.items.isEmpty) {
      return false;
    }
    final items = state.items;
    ++_revision;
    emit(
      CartState(
        status: CartStatus.ready,
        items: items,
        isSaving: true,
        isCheckingOut: true,
      ),
    );
    final operation = _saveTail.then((_) async {
      try {
        await _repository.save(const []);
      } catch (_) {
        if (!_isClosing && !isClosed) {
          emit(
            CartState(
              status: CartStatus.ready,
              items: items,
              issue: CartIssue.writeFailed,
            ),
          );
        }
        return false;
      }
      if (!_isClosing && !isClosed) {
        emit(CartState(status: CartStatus.ready));
      }
      return true;
    });
    _saveTail = operation.then<void>((_) {});
    return operation;
  }

  @override
  Future<void> close() async {
    _isClosing = true;
    await _initializing;
    await _saveTail;
    return super.close();
  }
}
