import 'package:flutter/material.dart';

class MoedaDropdown extends StatelessWidget {
  final Map<String, String> moedaParaBandeira = {
    'USD': 'usd', // Estados Unidos
    'BRL': 'brl', // Brasil
    'EUR': 'eur', // União Europeia
    'GBP': 'gbp', // Reino Unido
    'JPY': 'jpy', // Japão
    // Adicione outras moedas conforme necessário
  };
  final Map<String, String> simboloMoeda = {
    'USD': '\$', // Estados Unidos
    'BRL': 'R\$', // Brasil
    'EUR': '€', // União Europeia
    'GBP': '£', // Reino Unido
    'JPY': '¥', // Japão
    // Adicione outras moedas conforme necessário
  };

  final TextEditingController? controller;
  final String valorSelecionado;
  final List<String> opcoes;
  final ValueChanged<String?>? onChanged;
  final bool readOnly;

  MoedaDropdown({
    super.key,
    this.controller,
    required this.valorSelecionado,
    required this.opcoes,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Campo de valor
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Text(
                    simboloMoeda[valorSelecionado] ?? valorSelecionado,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18),
              readOnly: readOnly,
            ),
          ),

          // Divisor
          Container(height: 30, width: 1, color: Colors.grey),

          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
              value: valorSelecionado,
              items:
                  opcoes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            _buildBandeira(value),
                            SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
              icon: Transform.rotate(
                angle: 90 * 3.1416 / 180,
                child: Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBandeira(String codigoMoeda) {
    final codigoPais = moedaParaBandeira[codigoMoeda];

    return codigoPais != null
        ? Image.asset(
          'assets/${codigoPais.toLowerCase()}.png',
          width: 28,
          height: 28,
        )
        : Icon(Icons.attach_money);
  }
}
