import 'package:flutter/material.dart';
import 'package:lojavirtual/models/product.dart';

import 'components/images_form.dart';
import 'components/sizes_form.dart';

class EditProductScreen extends StatelessWidget {

  EditProductScreen(Product p) :
        editing = p != null,
        product = p != null ? p.clone() : Product();

  final Product product;
  final bool editing;

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(editing ? 'Editar Produto' : 'Criar Produto'),
        centerTitle: true,
      ),
      body: Form(
        key: formkey,
        child: ListView(
          children: <Widget>[
            ImagesForm(product),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    initialValue: product.name,
                    decoration: const InputDecoration(
                      hintText: 'Título',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                    validator: (name){
                      if(name.length < 6){
                        return 'Titulo muito curto';
                      }
                      return null;
                    },
                    onSaved: (name) {
                      product.name = name;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'A partir de',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'R\$ ...',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16,),
                    child: Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextFormField(
                    initialValue: product.description,
                    style: const TextStyle(
                        fontSize: 16
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Descrição',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    validator: (desc){
                      if(desc.length < 10){
                        return 'Descrição muito curta';
                      }
                      return null;
                    },
                    onSaved: (desc) {
                      product.description = desc;
                    },
                  ),
                  SizesForm(product),
                  const SizedBox(height: 20,),
                  SizedBox(
                    height: 44,
                    child: RaisedButton(
                      color: primaryColor,
                      disabledColor: primaryColor.withAlpha(100),
                      textColor: Colors.white,
                      onPressed: (){
                        if(formkey.currentState.validate()){
                          formkey.currentState.save();
                          product.save();
                        }
                      },
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}