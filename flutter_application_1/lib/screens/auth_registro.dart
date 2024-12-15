import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Função para cadastrar usuário
  Future<UserCredential> cadastrarUsuario(String email, String senha) async {
    try {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } catch (e) {
      rethrow; // Repassa o erro para o chamador
    }
  }
}
