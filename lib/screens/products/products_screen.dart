import 'package:flutter/material.dart';
import 'package:lojavirtual/models/product_manager.dart';
import 'package:lojavirtual/screens/products/components/products_list_tile.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produtos"),
        centerTitle: true,
      ),
      body: Consumer<ProductManager>(
        builder: (_, productManager, __){
          return ListView.builder(
            padding: const EdgeInsets.all(4),
            itemCount: productManager.allProducts.length,
            itemBuilder: (_, index){
              return ProductListTile(productManager.allProducts[index]);
            },
          );
        },
      ),
    );
  }
}