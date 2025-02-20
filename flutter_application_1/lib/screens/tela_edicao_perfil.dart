import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proAluno/screens/tela_historicometas.dart';
import '../models/user.dart';

class EdicaoPerfil extends StatefulWidget {
  const EdicaoPerfil({super.key});

  @override
  _EdicaoPerfilState createState() => _EdicaoPerfilState();
}

class _EdicaoPerfilState extends State<EdicaoPerfil> {
  late TextEditingController _nomeController;
  late TextEditingController _nomeUsuarioController;
  late TextEditingController _fotoUrlController;
  late TextEditingController _metaController;

  final _formKey = GlobalKey<FormState>();

  UserModel? _user;
  int _metaTarefas = 0;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _nomeUsuarioController = TextEditingController();
    _fotoUrlController = TextEditingController();
    _metaController = TextEditingController();
    _fetchUserData();
    _fetchMeta();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nomeUsuarioController.dispose();
    _fotoUrlController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      if (userData.exists && mounted) {
        setState(() {
          _user = UserModel.fromJson(user.uid, userData.data()!);
          _nomeController.text = _user!.nome;
          _nomeUsuarioController.text = _user!.nomeUsuario;
          _fotoUrlController = TextEditingController(
            text: _user!.fotoUrl ?? 'https://cdn-icons-png.flaticon.com/512/6063/6063734.png',
          );
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update({
          'nome': _nomeController.text,
          'nomeUsuario': _nomeUsuarioController.text,
          'fotoUrl': _fotoUrlController.text,
        });

        setState(() {
          _user = UserModel(
            id: user.uid,
            nome: _nomeController.text,
            nomeUsuario: _nomeUsuarioController.text,
            fotoUrl: _fotoUrlController.text,
            email: user.email!,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados atualizados'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _fetchMeta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final today = DateTime.now();
      final formattedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final querySnapshot = await FirebaseFirestore.instance
          .collection('metas')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: formattedDate)
          .get();

      if (querySnapshot.docs.isNotEmpty && mounted) {
        final metaDoc = querySnapshot.docs.first;
        setState(() {
          _metaTarefas = metaDoc['taskGoal'];
          _metaController.text = _metaTarefas.toString();
        });
      }
    }
  }

  Future<void> _updateMeta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final today = DateTime.now();
      final formattedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final metaRef = FirebaseFirestore.instance.collection('metas');
      final querySnapshot = await metaRef
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: formattedDate)
          .get();

      setState(() {
        _metaTarefas = int.tryParse(_metaController.text) ?? 0;
      });

      if (querySnapshot.docs.isEmpty) {
        await metaRef.add({
          'userId': user.uid,
          'date': formattedDate,
          'taskGoal': _metaTarefas,
          'taskIds': [],
        });
      } else {
        await querySnapshot.docs.first.reference.update({
          'taskGoal': _metaTarefas,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meta atualizada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _excluirConta() async {
    User? usuarioAtual = FirebaseAuth.instance.currentUser;
    if (usuarioAtual != null) {
      try {
        
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Deleta todas as tarefas associadas ao usuário
        QuerySnapshot<Map<String, dynamic>> tarefas = await firestore
            .collection('tasks')
            .where('userId', isEqualTo: usuarioAtual.uid)
            .get();

        for (var doc in tarefas.docs) {
          await firestore.collection('tasks').doc(doc.id).delete();
        }

        await firestore.collection('usuarios').doc(usuarioAtual.uid).delete();

        // Exclui a conta do Authentication
        await usuarioAtual.delete();

        // Redireciona para a tela de login
        Navigator.pushReplacementNamed(context, '/tela_login');
      } catch (e) {
        // Exibe mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erro ao excluir a conta: $e"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // Função para exibir um pop-up de confirmação antes de excluir a conta
  void _confirmarExclusaoConta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar exclusão"),
          content: const Text("Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _excluirConta();
              },
              child: const Text(
                "Excluir",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF133E87)),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF133E87)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF133E87),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoricoMetasScreen(),
              ),
            );
          },
        ),
      ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(  
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Text(
                  'Informações do Perfil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF133E87),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nomeController, 'Nome', Icons.person),
                      const SizedBox(height: 15),
                      _buildTextField(_nomeUsuarioController, 'Nome de Usuário', Icons.alternate_email),
                      const SizedBox(height: 15),
                      _buildTextField(_fotoUrlController, 'URL da Foto', Icons.image),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF133E87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Meta do Dia',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF133E87),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    _buildTextField(_metaController, 'Meta de Tarefas', Icons.flag),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _updateMeta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF133E87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: const Text('Salvar Meta', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _confirmarExclusaoConta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'Excluir Conta',
                    style: TextStyle(color: Colors.white),
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