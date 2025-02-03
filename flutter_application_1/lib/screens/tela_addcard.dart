import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class addCardScreen extends StatefulWidget {
  final String deckName;

  const addCardScreen({super.key, required this.deckName});

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<addCardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  void _saveCard() async {
    String text = _textController.text.trim();
    String answer = _answerController.text.trim();

    if (text.isEmpty || answer.isEmpty) return;

    QuerySnapshot snapshot = await _firestore
        .collection('decks')
        .where('name', isEqualTo: widget.deckName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String deckId = snapshot.docs.first.id;
      await _firestore.collection('decks').doc(deckId).collection('cards').add({
        'text': text, 
        'answer': answer, 
      });

      Navigator.pop(context, true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar flashcard",
        style: TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold, 
          ),
        ),
        centerTitle: true, 
        backgroundColor: const Color.fromARGB(255, 19, 62, 135),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.deckName,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: "Parte da frente"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: "Parte de trás"),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveCard,
              child: const Text("Adicionar card"),
            ),
          ],
        ),
      ),
    );
  }
}
