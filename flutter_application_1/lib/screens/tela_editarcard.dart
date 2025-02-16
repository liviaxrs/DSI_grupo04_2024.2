import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditCardScreen extends StatefulWidget {
  final String deckId;
  final String cardId;
  final String initialText;
  final String initialAnswer;

  const EditCardScreen({
    super.key,
    required this.deckId,
    required this.cardId,
    required this.initialText,
    required this.initialAnswer,
  });

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText;
    _answerController.text = widget.initialAnswer;
  }

  void _saveEditedCard() async {
    String updatedText = _textController.text.trim();
    String updatedAnswer = _answerController.text.trim();

    if (updatedText.isEmpty || updatedAnswer.isEmpty) return;

    await _firestore
        .collection('decks')
        .doc(widget.deckId)
        .collection('cards')
        .doc(widget.cardId)
        .update({
      'text': updatedText,
      'answer': updatedAnswer,
    });

    Navigator.pop(context, true); // Retorna para indicar que a edição foi salva
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      appBar: AppBar(
        title: const Text(
          'Editar Flashcard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 19, 62, 135),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
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
              onPressed: _saveEditedCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 19, 62, 135),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Salvar Alterações',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}