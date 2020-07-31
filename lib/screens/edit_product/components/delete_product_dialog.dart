import 'package:flutter/material.dart';
import 'package:lojavirtual/models/product.dart';
import 'package:lojavirtual/models/product_manager.dart';
import 'package:provider/provider.dart';

class DeleteProductDialog extends StatelessWidget {

  const DeleteProductDialog(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Deletar ${product.name}?',),
      content: const Text('Esta ação não poderá ser desfeita!'),
      actions: <Widget>[
        FlatButton(
          onPressed: (){
            context.read<ProductManager>().delete(product);
            Navigator.of(context).popUntil(
                    (route) => route.settings.name == '/'
            );
          },
          textColor: Colors.red,
          child: const Text('Deletar Produto'),
        ),
      ],
    );
  }
}