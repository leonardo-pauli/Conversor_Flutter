import 'dart:convert';

import 'package:http/http.dart' as http;

class ConversorService {
  Future<double?> converterMoeda({
    required double valor,
    required String de,
    required String para,
  }) async{
    final url = Uri.parse(
      'https://api.frankfurter.app/latest?amount=$valor&from=$de&to=$para'
    );

    final resposta = await http.get(url);

    if(resposta.statusCode == 200){
      final dados = jsonDecode(resposta.body);
      return dados['rates'][para] * 1.0;
    } else{
      return null;
    }
  }
Future<Map<DateTime, double>> obterHistorico({
  required String de,
  required String para,
  required DateTime inicio,
  required DateTime fim,
}) async {
  final url = 'https://api.frankfurter.app/${inicio.toIso8601String().substring(0, 10)}..${fim.toIso8601String().substring(0, 10)}?from=$de&to=$para';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final rates = Map<String, dynamic>.from(data['rates']);
    return rates.map((key, value) {
      return MapEntry(DateTime.parse(key), (value[para] as num).toDouble());
    });
  } else {
    throw Exception('Erro ao obter histórico de câmbio');
  }
}

}

