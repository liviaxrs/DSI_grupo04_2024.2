 import 'package:flutter/material.dart';

class NotificacoesScreen extends StatelessWidget {
  const NotificacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notificações",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF133E87),
        iconTheme: const IconThemeData(
          color: Colors.white, // Define a cor do ícone de voltar como branca
        ),
      ),
      body: const Center(
        child: Text(
          "Nenhuma notificação no momento.",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}