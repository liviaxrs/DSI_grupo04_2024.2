import 'package:flutter/material.dart';

class adicionarTask extends StatelessWidget {
  const adicionarTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(
    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
    onPressed: () {
      Navigator.of(context).pop();
    },
  ),
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF133E87),
        centerTitle: true,
        title: const Text(
          "Adicionar task", 
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          
        ),
      )
      );
      }}