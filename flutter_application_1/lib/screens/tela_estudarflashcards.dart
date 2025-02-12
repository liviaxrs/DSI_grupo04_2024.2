import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudyFlashcardsScreen extends StatefulWidget {
  final String deckId;

  const StudyFlashcardsScreen({Key? key, required this.deckId}) : super(key: key);

  @override
  _StudyFlashcardsScreenState createState() => _StudyFlashcardsScreenState();
}

class _StudyFlashcardsScreenState extends State<StudyFlashcardsScreen> {
  List<Map<String, dynamic>> flashcards = [];
  int currentIndex = 0;
  bool showAnswer = false; // Controla se a resposta está visível

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('decks')
        .doc(widget.deckId)
        .collection('cards')
        .get();

    setState(() {
      flashcards = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  void _showAnswer() {
    setState(() {
      showAnswer = true; // Exibe a resposta do card atual
    });
  }

  void _answerCorrect() {
    setState(() {
      flashcards.removeAt(currentIndex); // Remove o card da sessão
      _nextCard();
    });
  }

  void _answerIncorrect() {
    setState(() {
      flashcards.add(flashcards[currentIndex]); // Move para o final da lista
      flashcards.removeAt(currentIndex);
      _nextCard();
    });
  }

  void _nextCard() {
    if (flashcards.isNotEmpty) {
      setState(() {
        currentIndex = currentIndex % flashcards.length; // Mantém o índice dentro dos limites
        showAnswer = false; // Oculta a resposta para o próximo card
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 232, 230, 230),
        appBar: AppBar(
          title: const Text("Estudar Flashcards",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
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
        body: const Center(child: Text("Todos os flashcards foram respondidos!")),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      appBar: AppBar(
        title: const Text("Estudar Flashcards",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 19, 62, 135),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, true); // Garante atualização ao voltar
          },
        ),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${currentIndex + 1}/${flashcards.length} Flashcards restantes"),
          const SizedBox(height: 20),

          // Cartão da pergunta
          Container(
            width: 300,
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 78, 134, 187),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              flashcards[currentIndex]['text'], // Pergunta
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),

          const SizedBox(height: 10),

          // Cartão da resposta
          Visibility(
            visible: showAnswer,
            child: Container(
              width: 300,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                flashcards[currentIndex]['answer'], // Resposta
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Botão para exibir resposta
          ElevatedButton(
            onPressed: _showAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 19, 62, 135),
            ),
            child: const Text("Virar Card", style: TextStyle(color: Colors.white),),
          ),

          const SizedBox(height: 20),

          // Botões de resposta correta/incorreta
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green, size: 40),
                onPressed: _answerCorrect,
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 40),
                onPressed: _answerIncorrect,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

