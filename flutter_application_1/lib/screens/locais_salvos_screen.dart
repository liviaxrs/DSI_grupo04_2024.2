import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mapa.dart';
import 'editar_local_screen.dart';

class LocaisSalvosScreen extends StatefulWidget {
  final List<PontoMapa> pontosMapa;

  const LocaisSalvosScreen({super.key, required this.pontosMapa});

  @override
  LocaisSalvosScreenState createState() => LocaisSalvosScreenState();
}

class LocaisSalvosScreenState extends State<LocaisSalvosScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PontoMapa> _filteredPontosMapa = [];

// Adiciona listener para o campo de pesquisa
  @override
  void initState() {
    super.initState();
    _filteredPontosMapa = widget.pontosMapa;
    _searchController.addListener(_filterPontosMapa);
  }

// Libera o controlador ao sair da tela
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Método para filtrar os pontos com base no texto da pesquisa
  void _filterPontosMapa() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPontosMapa = widget.pontosMapa
          .where((ponto) =>
              ponto.titulo.toLowerCase().contains(query) ||
              ponto.descricao.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _deletarPontoMapa(String pontoId) async {
    try {
      await FirebaseFirestore.instance.collection('mapa').doc(pontoId).delete();

      // Verifica se o widget ainda está montado antes de usar o BuildContext
      if (!mounted) return;

      setState(() {
        widget.pontosMapa.removeWhere((ponto) => ponto.id == pontoId);
        _filteredPontosMapa.removeWhere((ponto) => ponto.id == pontoId);
      });

      // Verifica se o widget ainda está montado antes de usar o BuildContext
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Local excluído com sucesso"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Verifica se o widget ainda está montado antes de usar o BuildContext
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao excluir local: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Método para navegar para a tela de edição
  Future<void> _navegarParaEditarPonto(PontoMapa ponto) async {
    final novoPonto = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarLocalScreen(ponto: ponto),
      ),
    );

    if (novoPonto != null) {
      // Atualiza o ponto na lista e no Firestore
      await FirebaseFirestore.instance
          .collection('mapa')
          .doc(ponto.id)
          .update(novoPonto.toJson()); // Usar toJson em vez de toMap

      setState(() {
        final index = widget.pontosMapa.indexWhere((p) => p.id == ponto.id);
        if (index != -1) {
          widget.pontosMapa[index] = novoPonto;
          _filterPontosMapa(); // Atualiza a lista filtrada após a edição
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF133E87),
        title: const Center(
          child: Text(
            'Locais Salvos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Volta para a tela anterior
          },
        ),
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar locais...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Lista de locais salvos
          Expanded(
            child: _filteredPontosMapa.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum local encontrado',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredPontosMapa.length,
                    itemBuilder: (context, index) {
                      final ponto = _filteredPontosMapa[index];
                      return Dismissible(
                        key: Key(ponto.id), // Chave única para o item
                        direction: DismissDirection
                            .endToStart, // Deslizar da direita para a esquerda
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          _deletarPontoMapa(
                              ponto.id); // Excluir o ponto ao deslizar
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 7.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ponto.titulo,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF133E87),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ponto.descricao,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.black87),
                              onPressed: () => _navegarParaEditarPonto(ponto),
                            ),
                            onTap: () {
                              // Retornar as coordenadas do local selecionado
                              Navigator.pop(context, ponto.localizacao);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
