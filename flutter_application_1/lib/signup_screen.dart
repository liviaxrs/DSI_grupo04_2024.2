import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // Botão de Voltar
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(19, 62, 135, 1)),
              onPressed: () {
                Navigator.pop(context); // Voltar para a tela anterior
              },
            ),
          ),

          // Conteúdo principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Estamos quase lá...',
                    style: TextStyle(
                      fontSize: 32,
                      color: Color.fromRGBO(19, 62, 135, 1),
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    'Informe seus dados',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campo de Nome
                  Center(
                    child: SizedBox(
                      width: 300, // Largura desejada para a caixa
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'Nome',
                          labelStyle: const TextStyle(color: Color.fromRGBO(19, 62, 135, 1)),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo de Usuário
                  Center(
                    child: SizedBox(
                      width: 300, // Largura desejada para a caixa
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.account_circle),
                          labelText: 'Usuário',
                          labelStyle: const TextStyle(color: Color.fromRGBO(19, 62, 135, 1)),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo de Email
                  Center(
                    child: SizedBox(
                      width: 300, // Largura desejada para a caixa
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Color.fromRGBO(19, 62, 135, 1)),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo de Senha
                  Center(
                    child: SizedBox(
                      width: 300, // Largura desejada para o campo de senha
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Senha',
                          labelStyle: const TextStyle(color: Color.fromRGBO(19, 62, 135, 1)),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão Cadastrar-se
                  ElevatedButton(
                    onPressed: () {
                      // Implementar ação de cadastro
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(19, 62, 135, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(300, 50),
                    ),
                    child: const Text(
                      'Cadastrar-se',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
