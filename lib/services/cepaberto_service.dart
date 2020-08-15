import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lojavirtual/models/cepaberto_address.dart';

const token = 'a9aaaa9018e0b260997db6d148699647';

class CepAbertoService {

  Future<CepAbertoAddress> getAddresFromCep(String cep) async{
    final cleanCep = cep.replaceAll('.', '').replaceAll('-', '');
    final endPoint = "https://www.cepaberto.com/api/v3/cep?cep=$cleanCep";

    final Dio dio = Dio();

    dio.options.headers[HttpHeaders.authorizationHeader] = 'Token token=$token';

    try{
      final response = await dio.get<Map<String, dynamic>>(endPoint);

      if(response.data.isEmpty){
        return Future.error('CEP Inválido');
      }

      final CepAbertoAddress address = CepAbertoAddress.fromMap(response.data);

      return address;

    } on DioError catch(e){
      debugPrint('Erro ao buscar CEP: $e');
      return Future.error('Erro ao buscar CEP');
    }

  }

}