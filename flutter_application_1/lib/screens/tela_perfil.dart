import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/task.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  UserModel? _usuario;
  List<Task> _tasksCompletadas = []; // Lista para armazenar as tasks completadas

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
    _carregarTasksCompletadas();
  }

  // Função para carregar o usuário
  Future<void> _carregarUsuario() async {
    User? usuarioAtual = FirebaseAuth.instance.currentUser;

    if (usuarioAtual != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuarioAtual.uid)
              .get();

      if (snapshot.exists) {
        setState(() {
          _usuario = UserModel.fromJson(snapshot.id, snapshot.data()!);
        });
      }
    }
  }

  void _editarNome() {
    TextEditingController controladorNome = TextEditingController(text: _usuario!.nome);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Nome"),
          content: TextField(
            controller: controladorNome,
            decoration: const InputDecoration(
              labelText: "Novo nome",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                String novoNome = controladorNome.text.trim();
                if (novoNome.isNotEmpty) {
                  await _atualizarNomeNoBanco(novoNome);
                  setState(() {
                    _usuario = UserModel(
                      id: _usuario!.id,
                      email: _usuario!.email,
                      nome: novoNome,
                      nomeUsuario: _usuario!.nomeUsuario,
                      fotoUrl: _usuario!.fotoUrl,
                    );
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _atualizarNomeNoBanco(String novoNome) async {
    User? usuarioAtual = FirebaseAuth.instance.currentUser;
    if (usuarioAtual != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioAtual.uid)
          .update({'nome': novoNome});
    }
  }

  // Função para carregar as tasks completadas
  Future<void> _carregarTasksCompletadas() async {
    User? usuarioAtual = FirebaseAuth.instance.currentUser;

    if (usuarioAtual != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: usuarioAtual.uid)
          .where('isComplete', isEqualTo: true) // Filtra as tasks completadas
          .get();

      setState(() {
        _tasksCompletadas = snapshot.docs
            .map((doc) => Task.fromJson(doc.id, doc.data()))
            .toList();
      });
    }
  }

  // Função para sair da conta
  Future<void> _sairDaConta() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/tela_login');
  }

  // Função para excluir a conta
  Future<void> _excluirConta() async {
    User? usuarioAtual = FirebaseAuth.instance.currentUser;
    if (usuarioAtual != null) {
      try {
        // Obtém uma referência ao Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Deleta todas as tarefas associadas ao usuário
        QuerySnapshot<Map<String, dynamic>> tarefas = await firestore
            .collection('tasks')
            .where('userId', isEqualTo: usuarioAtual.uid)
            .get();

        for (var doc in tarefas.docs) {
          await firestore.collection('tasks').doc(doc.id).delete();
        }

        // Deleta o usuário da coleção 'usuarios'
        await firestore.collection('usuarios').doc(usuarioAtual.uid).delete();

        // Exclui a conta do Authentication
        await usuarioAtual.delete();

        // Redireciona para a tela de login
        Navigator.pushReplacementNamed(context, '/tela_login');
      } catch (e) {
        print("Erro ao excluir a conta: $e");
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
                Navigator.of(context).pop(); // Fecha o pop-up
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o pop-up
                _excluirConta(); // Chama a função para excluir a conta
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Perfil",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF133E87),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), // Ícone de sininho
            onPressed: () {
              Navigator.pushNamed(context, '/notificacoes'); // Navega para a tela de notificações
            },
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _sairDaConta,
            color: Colors.white,
          ),
        ],
      ),

      body: Center(
        child: _usuario == null
            ? const CircularProgressIndicator()
            : SingleChildScrollView( // Para permitir rolagem quando as tasks são muitas
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _usuario!.fotoUrl != null
                          ? NetworkImage(_usuario!.fotoUrl!)
                          : const AssetImage("assets/images/perfil_padrao.png") 
                              as ImageProvider,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _usuario!.nome,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _editarNome,
                          color: const Color(0xFF133E87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "@${_usuario!.nomeUsuario}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Exibe as tasks completadas
                    if (_tasksCompletadas.isNotEmpty) ...[
                      const Text(
                        "Tasks Completadas:",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _tasksCompletadas.length,
                        itemBuilder: (context, index) {
                          final task = _tasksCompletadas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(task.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Concluída em: ${task.date} às ${task.hour}"),
                                  const SizedBox(height: 5),
                                  Text(task.description),
                                ],
                              ),
                              trailing: const Icon(Icons.check_circle, color: Colors.green),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      const Text(
                        "Nenhuma task concluída.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _confirmarExclusaoConta, // Chama a função de confirmação
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF133E87),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        "Excluir Conta",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}