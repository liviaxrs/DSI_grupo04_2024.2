import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart'; // Importe sua classe UserModel

class EdicaoPerfil extends StatefulWidget {
  const EdicaoPerfil({super.key});

  @override
  _EdicaoPerfilState createState() => _EdicaoPerfilState();
}

class _EdicaoPerfilState extends State<EdicaoPerfil> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _nomeUsuarioController;
  late TextEditingController _fotoUrlController;

  UserModel? _user;
  int _metaTarefas = 0;
  TextEditingController _metaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchMeta();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      setState(() {
        _user = UserModel.fromJson(user.uid, userData.data()!);
        _nomeController = TextEditingController(text: _user!.nome);
        _nomeUsuarioController = TextEditingController(text: _user!.nomeUsuario);
        _fotoUrlController = TextEditingController(text: _user!.fotoUrl);
      });
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
        Navigator.pop(context, true); // Passa "true" indicando que a atualização foi feita
      }
    }
  }

    // Função para buscar a meta do usuário no Firestore
  Future<void> _fetchMeta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final today = DateTime.now();
      final formattedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}'; // Formato: yyyy-MM-dd

      final querySnapshot = await FirebaseFirestore.instance
          .collection('metas')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: formattedDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final metaDoc = querySnapshot.docs.first;
        setState(() {
          _metaTarefas = metaDoc['taskGoal'];
          _metaController.text = _metaTarefas.toString();
        });
      }
    }
  }

  // Função para atualizar a meta no Firestore
  Future<void> _updateMeta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final today = DateTime.now();
      final formattedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}'; // Formato: yyyy-MM-dd

      final metaRef = FirebaseFirestore.instance.collection('metas');
      final querySnapshot = await metaRef
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: formattedDate)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Se não existir uma meta para o dia de hoje, cria uma nova
        metaRef.add({
          'userId': user.uid,
          'date': formattedDate,
          'taskGoal': _metaTarefas,
          'taskIds': [],
        });
      } else {
        // Atualiza a meta existente
        querySnapshot.docs.first.reference.update({
          'taskGoal': _metaTarefas,
        });
        Navigator.pop(context, true); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu nome';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _nomeUsuarioController,
                          decoration:
                              const InputDecoration(labelText: 'Nome de Usuário'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu nome de usuário';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _fotoUrlController,
                          decoration: const InputDecoration(labelText: 'URL da Foto'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateUserData,
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Espaçamento entre as seções
                  TextField(
                    controller: _metaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Meta de Tarefas'),
                    onChanged: (value) {
                      setState(() {
                        _metaTarefas = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateMeta,
                    child: const Text('Salvar Meta'),
                  ),
                ],
              ),
            ),
    );
  }
}