import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCardScreen extends StatefulWidget {
  final String deckId;

  const AddCardScreen({super.key, required this.deckId});

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _saveCard() async {
    String text = _textController.text.trim();
    String answer = _answerController.text.trim();
    String? userId = _auth.currentUser?.uid;

    if (text.isEmpty || answer.isEmpty || userId == null) return;

    await _firestore.collection('decks')
        .doc(widget.deckId) // 
        .collection('cards')
        .add({
          'text': text,
          'answer': answer,
          'userId': userId,
        });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      appBar: AppBar(
        title: const Text('Adicionar Flashcard',
          style: TextStyle(color: Colors.white,
          fontWeight: FontWeight.bold,
          ), 
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 19, 62, 135),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Pergunta'),
            ),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: 'Resposta'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 19, 62, 135),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Salvar Card',
              style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
