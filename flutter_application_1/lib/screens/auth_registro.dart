import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para cadastrar usuário e salvar no Firestore
  Future<UserModel?> cadastrarUsuario(
      String nome, String nomeUsuario, String email, String senha) async {
    try {
      // Cria o usuário no Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Obtém o ID do usuário gerado pelo Firebase Auth
      String userId = userCredential.user!.uid;

      // Cria o modelo do usuário
      UserModel usuario = UserModel(
        id: userId,
        email: email,
        nome: nome,
        nomeUsuario: nomeUsuario,
      );

      // Salva no Firestore na coleção "usuarios"
      await _firestore.collection('usuarios').doc(userId).set(usuario.toJson());

      return usuario; // Retorna o usuário criado
    } catch (e) {
      rethrow; // Repassa o erro para o chamador
    }
  }
}