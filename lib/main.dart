import 'package:flutter/material.dart';
import 'dart:math';
import 'package:share_plus/share_plus.dart';

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

  // Gera uma nova frase aleatória da lista _frases
  void _gerarFrase() {
    var numeroSorteado = Random().nextInt(_frases.length);
    setState(() {
      _fraseGerada = _frases[numeroSorteado]; // Atualiza a frase gerada
    });
  }

  // Compartilha a frase gerada atualmente
  void _shareQuote() {
    SharePlus.instance.share(ShareParams(text: _fraseGerada));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar Configuração
      appBar: AppBar(
        title: const Text("Frases do Dia"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareQuote,
          ),
        ],
      ),
      // Corpo do Scaffold com imagem de fundo
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/robot.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        // Conteúdo Centralizado
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            // Coluna principal para os elementos da UI
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Logo da aplicação
                Image.asset("assets/logo.png"),
                // Container para exibir a frase gerada
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _fraseGerada,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Botão para gerar nova frase
                ElevatedButton(
                  onPressed: _gerarFrase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text(
                    "Nova Frase",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

