import 'package:flutter/material.dart';

class EdicaoPerfil extends StatelessWidget {
  const EdicaoPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Perfil",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF133E87),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Em produção...",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

