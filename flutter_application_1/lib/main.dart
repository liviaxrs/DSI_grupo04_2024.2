import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/tela_cadastro.dart';
import 'screens/tela_login.dart';
import 'screens/tela_todolist.dart';
import 'screens/tela_adicionartask.dart';
import 'screens/tela_perfil.dart';
import 'screens/tela_flashcards.dart';
import 'screens/tela_mapa.dart';
import 'screens/tela_esqueci_senha.dart';
import 'screens/notificacoes.dart';
import 'screens/tela_edicao_perfil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializando o Firebase com as opções
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      title: "ProAluno",
      routes: {
        "/tela_login": (context) => const LoginScreen(),
        "/tela_cadastro": (context) => const SignupScreen(),
        "/tela_todolist": (context) => const TodolistScreen(),
        "/tela_adicionartask": (context) => const AdicionarTask(),
        "/tela_perfil": (context) => const PerfilScreen(),
        "/tela_flashcards": (context) => const flashcardScreen(),
        "/tela_mapa": (context) => MapaScreen(),
        "/tela_esqueci_senha": (context) => const TelaEsqueciSenha(),
        "/notificacoes": (context) => const NotificacoesScreen(),
        "/tela_edicao_perfil": (context) => const EdicaoPerfil(),
      },
    );
  }
}
