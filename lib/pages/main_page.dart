import 'package:conversor_moeda/pages/conversor_page.dart';
import 'package:flutter/material.dart';

class TelaComFundoBranco extends StatelessWidget {
  const TelaComFundoBranco({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA), // fundo cinza claro
        body: Center(
          child: Container(
            width: 350,
            height: 620,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const ConversorPage(), 
          ),
        ),
      ),
    );
  }
}
