import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/models/cart_manager.dart';
import 'package:lojavirtual/models/credit_card.dart';
import 'package:lojavirtual/models/order.dart';
import 'package:lojavirtual/models/product.dart';
import 'package:lojavirtual/services/cielo_payment.dart';

class CheckoutManager extends ChangeNotifier {
  final Firestore firestore = Firestore.instance;
  final CieloPayment cieloPayment = CieloPayment();

  CartManager cartManager;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  // ignore: use_setters_to_change_properties
  void updateCart(CartManager cartManager) {
    this.cartManager = cartManager;
  }

  Future<void> checkout({CreditCard creditCard,Function onStockFail, Function onSuccess, Function onPayFail}) async {
    loading = true;

    final orderId = await _getOrderId();

    String payId;
    try {
      payId = await cieloPayment.authorize(
        creditCard: creditCard,
        price: cartManager.totalPrice,
        orderId: orderId.toString(),
        user: cartManager.user,
      );
    } catch (e){
      onPayFail(e);
      loading = false;
      return;
    }

    try {
      await _decrementStock();
    } catch(e){
      cieloPayment.cancel(payId);
      onStockFail(e);
      loading = false;
      return;
    }

    try {
      await cieloPayment.capture(payId);
    } catch (e){
      onPayFail(e);
      loading = false;
      return;
    }

    final order = Order.fromCartManager(cartManager);
    order.orderId = orderId.toString();
    order.payId = payId;

    order.save();
    cartManager.clear();

    onSuccess(order);
    loading = false;
  }

  Future<int> _getOrderId() async {
    final ref = firestore.document('aux/ordercounter');
    try {
      final result = await firestore.runTransaction((tx) async {
        final doc = await tx.get(ref);
        final orderId = doc.data['current'] as int;
        await tx.update(ref, {'current': orderId + 1});
        return {'orderId': orderId};
      });
      return result['orderId'] as int;
    } catch (e){
      debugPrint(e.toString());
      return Future.error('Falha ao gerar número do pedido');
    }
  }

  Future<void> _decrementStock() {
    return firestore.runTransaction((tx) async {
      final List<Product> productsToUpdate = [];
      final List<Product> productsWithoutStock = [];

      for (final cartProduct in cartManager.items) {
        Product product;

        if(productsToUpdate.any((p) => p.id == cartProduct.productID)){
          product = productsToUpdate.firstWhere(
                  (p) => p.id == cartProduct.productID
          );
        } else {
          final doc = await tx.get(
              firestore.document('products/${cartProduct.productID}')
          );
          product = Product.fromDocument(doc);
        }

        cartProduct.product = product;

        final size = product.findSize(cartProduct.size);
        if(size.stock - cartProduct.quantity < 0){
          productsWithoutStock.add(product);
        } else {
          size.stock -= cartProduct.quantity;
          productsToUpdate.add(product);
        }
      }

      if(productsWithoutStock.isNotEmpty){
        return Future.error(
            'produtos sem estoque: ${productsWithoutStock.length}'
        );
      }

      for(final product in productsToUpdate){
        tx.update(
            firestore.document('products/${product.id}'),
            {'sizes': product.exportSizeList()}
            );
      }

    });
  }
}
