import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:lojavirtual/models/product.dart';

class ProductManager extends ChangeNotifier{
  ProductManager() {
    _loadAllProucts();
  }

  final Firestore firestore = Firestore.instance;

  List<Product> allProducts = [];

  Future<void> _loadAllProucts() async {
    final QuerySnapshot snapProduct =
        await firestore.collection('products').getDocuments();

    allProducts =
        snapProduct.documents.map((d) => Product.fromDocument(d)).toList();

    notifyListeners();
  }
}
