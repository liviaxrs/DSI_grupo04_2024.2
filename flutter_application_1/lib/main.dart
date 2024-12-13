import 'package:flutter/material.dart';
import 'signup_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    width: 120, 
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Seja bem vindo ao',
                style: TextStyle(fontSize: 32, color: Color.fromRGBO(19, 62, 135, 1)),
              ),
              //
              const Text(
                'ProAluno',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(19, 62, 135, 1),
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                      color: Colors.black54
                    )
                  ]
                ),
              ),
              //
              const SizedBox(height: 10),
              const Text(
                'Efetue seu Login',
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 0, 0, 0.2)),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 300, 
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
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
              Center(
                child: SizedBox(
                  width: 300, 
                  child: TextField(
                    obscureText: true,
                    textInputAction: TextInputAction.done,
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

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  //  ação de login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(19, 62, 135, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(300, 35),
                  ),
                child: const Text('Acessar',
                style: TextStyle(color: Colors.white)
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                'Não tem uma conta?',
                style: TextStyle(fontSize: 13, color: Color.fromRGBO(0, 0, 0, 0.2)),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(fontSize: 13, color: Color.fromRGBO(19, 62, 135, 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


