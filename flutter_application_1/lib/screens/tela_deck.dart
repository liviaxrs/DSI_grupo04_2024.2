import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proAluno/screens/tela_estudarflashcards.dart';
import 'tela_addcard.dart';

class DeckScreen extends StatefulWidget {
  final String deckId;
  final String deckName;

  const DeckScreen({super.key, required this.deckId, required this.deckName});

  @override
  _DeckScreenState createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, String>> cards = [];
  late String deckName;

  @override
  void initState() {
    super.initState();
    deckName = widget.deckName;
    _loadCards();
  }

  void _loadCards() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    QuerySnapshot cardsSnapshot = await _firestore
        .collection('decks')
        .doc(widget.deckId)
        .collection('cards')
        .get();

    setState(() {
      cards = cardsSnapshot.docs
          .map((doc) => {
                'text': doc['text'] as String,
                'answer': doc['answer'] as String,
              })
          .toList();
    });
  }

  void _navigateToAddCard() async {
    bool? cardAdded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCardScreen(deckId: widget.deckId),
      ),
    );

    if (cardAdded == true) {
      _loadCards();
    }
  }

  void _editDeckName() async {
    TextEditingController _nameController = TextEditingController(text: deckName);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Nome do Deck"),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Novo nome"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  await _firestore.collection('decks').doc(widget.deckId).update({'name': newName});
                  setState(() => deckName = newName);
                }
                Navigator.pop(context);
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Retorna true para indicar atualização
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 232, 230, 230),
        appBar: AppBar(
          title: Text(deckName,
            style: const TextStyle(
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
              Navigator.pop(context, true); // Garante atualização ao voltar
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editDeckName,
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[200],
          child: Center(
            child: cards.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Esse deck não possui nenhum card",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _navigateToAddCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Adicionar card",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            cards.length.toString(),
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => StudyFlashcardsScreen(deckId: widget.deckId)));
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor: Color.fromARGB(255, 19, 62, 135),
                          ),
                          child: const Text("Começar a estudar!",
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Flashcards no deck (${cards.length})",
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: cards.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: ListTile(
                                          title: Text(cards[index]['text'] ?? ""),
                                          subtitle: Text(cards[index]['answer'] ?? ""),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {},
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddCard,
          backgroundColor: const Color.fromARGB(255, 19, 62, 135),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
