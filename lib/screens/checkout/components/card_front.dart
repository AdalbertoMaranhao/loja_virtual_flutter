import 'package:brasil_fields/brasil_fields.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lojavirtual/screens/checkout/components/card_text_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CardFront extends StatelessWidget {

  CardFront({this.numberFocus, this.dateFocus, this.nameFocus, this.finished});


  final MaskTextInputFormatter dateFormatter = MaskTextInputFormatter(
    mask: '!#/####', filter: {'#': RegExp('[0-9]'), '!': RegExp('[0-1]')}
  );

  final VoidCallback finished;

  final FocusNode numberFocus;
  final FocusNode dateFocus;
  final FocusNode nameFocus;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 16,
      child: Container(
        height: 200,
        color: const Color(0xFF1B4B52),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CardTextField(
                    title: 'Número',
                    hint: '1111 2222 3333 4444',
                    bold: true,
                    textInputType: TextInputType.number,
                    inputFormaters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      CartaoBancarioInputFormatter(),
                    ],
                    validator: (number){
                      if(number.length != 19){
                        return 'Inválido';
                      } else if(detectCCType(number) == CreditCardType.unknown){
                        return 'Inválido';
                      }
                      return null;
                    },
                    onSubmitted: (_){
                      dateFocus.requestFocus();
                    },
                    focusNode: numberFocus,
                  ),
                  CardTextField(
                    title: 'Validade',
                    hint: '11/2023',
                    textInputType: TextInputType.number,
                    inputFormaters: [
                      dateFormatter,
                    ],
                    validator: (date){
                      if(date.length != 7) return 'Inválido';
                      return null;
                    },
                    onSubmitted: (_){
                      nameFocus.requestFocus();
                    },
                    focusNode: dateFocus,
                  ),
                  CardTextField(
                    title: 'Nome do Titular',
                    hint: 'Maria Joaquina',
                    bold: true,
                    textInputType: TextInputType.text,
                    validator: (name){
                      if(name.isEmpty) return 'Inválido';
                      return null;
                    },
                    onSubmitted: (_){
                      finished();
                    },
                    focusNode: nameFocus,
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