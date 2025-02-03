import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_addcard.dart';

class DeckScreen extends StatefulWidget {
  final String deckName;

  const DeckScreen({super.key, required this.deckName});

  @override
  _DeckScreenState createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() async {
    QuerySnapshot snapshot = await _firestore
        .collection('decks')
        .where('name', isEqualTo: widget.deckName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String deckId = snapshot.docs.first.id;
      QuerySnapshot cardsSnapshot = await _firestore
          .collection('decks')
          .doc(deckId)
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
  }

  void _navigateToAddCard() async {
    bool? cardAdded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => addCardScreen(deckName: widget.deckName),
      ),
    );

    if (cardAdded == true) {
      _loadCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName, 
        style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 19, 62, 135),
        iconTheme: IconThemeData(color: Colors.white), 
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          backgroundColor: Colors.blue[900],
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
                                        title:
                                            Text(cards[index]['text'] ?? ""),
                                        subtitle:
                                            Text(cards[index]['answer'] ?? ""),
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
    );
  }
}
