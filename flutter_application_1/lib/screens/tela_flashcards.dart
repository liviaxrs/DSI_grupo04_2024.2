import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_deck.dart';

class flashcardScreen extends StatefulWidget {
  const flashcardScreen({super.key});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<flashcardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> decks = [];
  List<int> selectedDecks = [];
  bool isSelecting = false;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  // carregar decks do firestore
  void _loadDecks() async {
    QuerySnapshot snapshot = await _firestore.collection('decks').get();
    setState(() {
      decks = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  // incluir novo deck no fstore
  void _addDeck() async {
    int newDeckNumber = decks.length + 1;
    String newDeckName = "Deck $newDeckNumber";

    await _firestore.collection('decks').add({
      'name': newDeckName,
    });

    _loadDecks(); 
  }

  // selectbox pra deletar
  void _deleteSelectedDecks() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Excluir Decks"),
          content: const Text("Tem certeza que deseja excluir os decks selecionados?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Excluir"),
              onPressed: () async {
                for (int index in selectedDecks) {
                  String deckName = decks[index];
                  QuerySnapshot snapshot = await _firestore
                      .collection('decks')
                      .where('name', isEqualTo: deckName)
                      .get();
                  for (var doc in snapshot.docs) {
                    await doc.reference.delete();
                  }
                }
                setState(() {
                  selectedDecks.clear();
                  isSelecting = false;
                });
                _loadDecks(); 
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedDecks.contains(index)) {
        selectedDecks.remove(index);
        if (selectedDecks.isEmpty) {
          isSelecting = false;
        }
      } else {
        selectedDecks.add(index);
      }
    });
  }

  void _startSelectionMode() {
    setState(() {
      isSelecting = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Flashcards",
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
          ),
        ),
        centerTitle: true, 
        backgroundColor: const Color.fromARGB(255, 19, 62, 135), 
        actions: [
          if (isSelecting)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedDecks,
              color: Colors.white, 
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: decks.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              if (!isSelecting) {
                _startSelectionMode();
              }
              _toggleSelection(index);
            },
            onTap: () {
              if (isSelecting) {
                _toggleSelection(index);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckScreen(deckName: decks[index]),
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200), 
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: selectedDecks.contains(index)
                    ? Colors.grey[300] 
                    : Colors.white, 
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(decks[index]),
                subtitle: const Text("Não possui cards ainda"),
                trailing: isSelecting
                    ? Checkbox(
                        value: selectedDecks.contains(index),
                        onChanged: (bool? value) {
                          _toggleSelection(index);
                        },
                      )
                    : const Icon(Icons.arrow_forward_ios),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDeck,
        backgroundColor: const Color.fromARGB(255, 19, 62, 135), 
        foregroundColor: Colors.white, 
        child: const Icon(Icons.add),
      ),
    );
  }
}