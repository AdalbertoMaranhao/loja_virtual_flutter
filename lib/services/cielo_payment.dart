import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:lojavirtual/models/credit_card.dart';
import 'package:lojavirtual/models/user.dart';

class CieloPayment {

  final CloudFunctions functions = CloudFunctions.instance;


  // ignore: missing_return
  Future<String> authorize({CreditCard creditCard, num price,
    String orderId, User user}) async {
    try {
      final Map<String, dynamic> dataSale = {
        'merchantOrderId': orderId,
        'amount': (price * 100).toInt(),
        'softDescriptor': 'Loja Virtual',
        'installments': 1,
        'creditCard': creditCard.toJson(),
        'cpf': user.cpf,
        'paymentType': 'CreditCard',
      };

      final HttpsCallable callable = functions.getHttpsCallable(
          functionName: 'authorizeCreditCard'
      );
      callable.timeout = const Duration(seconds: 60);

      final response = await callable.call(dataSale);
      final data = Map<String, dynamic>.from(response.data as LinkedHashMap);
      if (data['success'] as bool) {
        return data['paymentId'] as String;
      } else {
        debugPrint('${data['error']['message']}');
        return Future.error(data['error']['message']);
      }
    } catch (e){
      debugPrint('$e');
      Future.error("Falha ao processar transação, tente novamente.");
    }

  }

  Future<void> capture(String payId) async {

    final Map<String, dynamic> captureData = {
      'payId': payId
    };

    final HttpsCallable callable = functions.getHttpsCallable(
        functionName: 'captureCreditCard'
    );
    callable.timeout = const Duration(seconds: 60);

    final response = await callable.call(captureData);
    final data = Map<String, dynamic>.from(response.data as LinkedHashMap);

    if (data['success'] as bool) {
      debugPrint('Captura realizada com sucesso!');
    } else {
      debugPrint('${data['error']['message']}');
      return Future.error(data['error']['message']);
    }

  }

  Future<void> cancel(String payId) async {

    final Map<String, dynamic> cancelData = {
      'payId': payId
    };
    final HttpsCallable callable = functions.getHttpsCallable(
        functionName: 'cancelCreditCard'
    );
    final response = await callable.call(cancelData);
    final data = Map<String, dynamic>.from(response.data as LinkedHashMap);

    if (data['success'] as bool) {
      debugPrint('Cancelamento realizado com sucesso');
    } else {
      debugPrint('${data['error']['message']}');
      return Future.error(data['error']['message']);
    }

  }

}