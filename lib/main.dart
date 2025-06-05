import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> _frases = [
    "O valor do amor está vinculado a soma dos sacrifícios que estas disposto a fazer por ele.",
    "É quando nos esquecemos de nós mesmos que fazemos coisas que jamais serão esquecidas.",
    "A alma cresce à altura daquela que admira.",
    "Considere a idéia de orar!",
    "As mais seletas produções da pericia humana nao possue beleza que se possa comparar como a beleza do caráter.",
  ];

  String _fraseGerada = "Clique abaixo para gerar uma frase!";

  void _gerarFrase() {
    var numeroSorteado = Random().nextInt(_frases.length);
    setState(() {
      _fraseGerada = _frases[numeroSorteado]; // Atualiza a frase gerada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Frases do Dia"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/logo.png"),
              Text(
                _fraseGerada,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
              ElevatedButton(
                onPressed: _gerarFrase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Nova Frase",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

