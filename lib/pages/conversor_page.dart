import 'package:conversor_moeda/widgets/cambio_grafico.dart';
import 'package:flutter/material.dart';
import 'package:conversor_moeda/services/conversor_service.dart';
import 'package:conversor_moeda/widgets/moeda_dropdown.dart';

class ConversorPage extends StatefulWidget {
  const ConversorPage({super.key});

  @override
  State<ConversorPage> createState() => _ConversorPageState();
}

enum Periodo { umDia, cincoDias, umMes, umAno, cincoAnos, max }

class _ConversorPageState extends State<ConversorPage> {
  Periodo _periodoSelecionado = Periodo.umMes;
  Map<DateTime, double>? _historico;

  final TextEditingController _controllerDe = TextEditingController(
    text: '100',
  );
  final TextEditingController _controllerPara = TextEditingController();
  final ConversorService _service = ConversorService();

  String _de = 'BRL';
  String _para = 'USD';
  double? _resultado;

  final List<String> moedas = ['EUR', 'USD', 'JPY', 'GBP', 'BRL'];

void _converter() async {
  final raw = _controllerDe.text.trim();
  // Se o texto estiver vazio, limpa resultado e não segue
  if (raw.isEmpty) {
    setState(() {
      _resultado = null;
      _controllerPara.text = '';
    });
    return;
  }

  final valor = double.tryParse(raw.replaceAll('.', '').replaceAll(',', '.'));
  if (valor == null) {
    // string não numérica — opcional: mostrar erro ou limpar
    setState(() {
      _resultado = null;
      _controllerPara.text = '';
    });
    return;
  }

  final convertido = await _service.converterMoeda(
    valor: valor,
    de: _de,
    para: _para,
  );

  setState(() {
    _resultado = convertido;
    _controllerPara.text = _formatarValor(convertido!);
  });
}


  String _formatarValor(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _trocarMoedas() {
    setState(() {
      final temp = _de;
      _de = _para;
      _para = temp;
      _converter();
      _carregarHistorico();
    });
  }



  void _carregarHistorico() async {
    final fim = DateTime.now();
    DateTime inicio;

    switch (_periodoSelecionado) {
      case Periodo.umDia:
        inicio = fim.subtract(Duration(days: 1));
        break;
      case Periodo.cincoDias:
        inicio = fim.subtract(Duration(days: 5));
        break;
      case Periodo.umMes:
        inicio = DateTime(fim.year, fim.month - 1, fim.day);
        break;
      case Periodo.umAno:
        inicio = DateTime(fim.year - 1, fim.month, fim.day);
        break;
      case Periodo.cincoAnos:
        inicio = DateTime(fim.year - 5, fim.month, fim.day);
        break;
      case Periodo.max:
        // Ou o máximo que sua API suporta, ou data muito antiga
        inicio = DateTime(2000);
        break;
    }

    final historico = await _service.obterHistorico(
      de: _de,
      para: _para,
      inicio: inicio,
      fim: fim,
    );

    setState(() {
      _historico = historico;
    });
  }

@override
void initState() {
  super.initState();
  // converte na inicialização
  _converter();
  _carregarHistorico();

  // sempre que o texto mudar, converte de novo
  _controllerDe.addListener(() {
    // só converte se o campo não estiver vazio
    if (_controllerDe.text.isNotEmpty) {
      _converter();
      _carregarHistorico();
    }
  });

   _controllerDe.addListener(_onDeChanged);
}

 void _onDeChanged() {
    // evita chamadas desnecessárias com string vazia
    if (_controllerDe.text.trim().isEmpty) {
      setState(() {
        _resultado = null;
        _controllerPara.text = '';
      });
    } else {
      _converter();
      // se quiser atualizar gráfico a cada keystroke, descomente:
      // _carregarHistorico();
    }
  }

  @override
  void dispose() {
    // 3) Não esqueça de remover listener!
    _controllerDe.removeListener(_onDeChanged);
    _controllerDe.dispose();
    _controllerPara.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    final raw = _controllerDe.text.replaceAll('.', '').replaceAll(',', '.');
    final inputValue = double.tryParse(raw);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Conversor de moedas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                MoedaDropdown(
                  controller: _controllerDe,
                  
                  valorSelecionado: _de,
                  opcoes: moedas,
                  onChanged: (val) {
                    setState(() => _de = val!);
                    _converter();
                    _carregarHistorico();
                    if (_para == _de) {
                      _para = moedas.firstWhere((m) => m != _de);
                    }
                  },
                ),
                SizedBox(height: 4),

                // Botão de reversão
                IconButton(
                  icon: Icon(Icons.swap_horiz_rounded, size: 30),
                  onPressed: _trocarMoedas,
                ),
                SizedBox(height: 4),

                // Campo de destino
                MoedaDropdown(
                  controller: _controllerPara,
                  valorSelecionado: _para,
                  opcoes: moedas.where((moeda) => moeda != _de).toList(),
                  onChanged: (val) {
                    setState(() => _para = val!);
                    _converter();
                    _carregarHistorico();
                  },
                  readOnly: true,
                ),
                SizedBox(height: 25),
                if (_resultado != null && inputValue != null)
                  Text(
                    '1 $_de = ${(1 / _resultado! * inputValue).toStringAsFixed(2)} $_para',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Taxa de câmbio",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                if (_historico == null)
                  CircularProgressIndicator()
                else
                  CambioGrafico(historico: _historico!),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _botaoPeriodo('1D', Periodo.umDia),
                    _botaoPeriodo('5D', Periodo.cincoDias),
                    _botaoPeriodo('1M', Periodo.umMes),
                    _botaoPeriodo('1A', Periodo.umAno),
                    _botaoPeriodo('5A', Periodo.cincoAnos),
                    _botaoPeriodo('Max', Periodo.max),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoPeriodo(String texto, Periodo periodo) {
    final bool selecionado = _periodoSelecionado == periodo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: selecionado ? Colors.purple : null,
          foregroundColor: selecionado ? Colors.white : Colors.black,
          minimumSize: Size(40, 30),
          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        ),
        onPressed: () {
          setState(() {
            _periodoSelecionado = periodo;
            _carregarHistorico();
          });
        },
        child: Text(texto),
      ),
    );
  }
}
