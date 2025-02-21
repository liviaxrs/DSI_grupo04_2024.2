import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mapa.dart';
import 'editar_local_screen.dart';

class LocaisSalvosScreen extends StatefulWidget {
  final List<PontoMapa> pontosMapa;
  final VoidCallback onPontoDeletado;

  const LocaisSalvosScreen({
    super.key,
    required this.pontosMapa,
    required this.onPontoDeletado,
  });

  @override
  LocaisSalvosScreenState createState() => LocaisSalvosScreenState();
}

class LocaisSalvosScreenState extends State<LocaisSalvosScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PontoMapa> _filteredPontosMapa = [];

  @override
  void initState() {
    super.initState();
    _filteredPontosMapa = widget.pontosMapa;
    _searchController.addListener(_filterPontosMapa);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

      if (!mounted) return;

      setState(() {
        widget.pontosMapa.removeWhere((ponto) => ponto.id == pontoId);
        _filteredPontosMapa.removeWhere((ponto) => ponto.id == pontoId);
      });

      widget.onPontoDeletado();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Local excluído com sucesso"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
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

  Future<void> _navegarParaEditarPonto(PontoMapa ponto) async {
    final novoPonto = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarLocalScreen(
          ponto: ponto,
          onPontoEditado: widget.onPontoDeletado,
        ),
      ),
    );

    if (novoPonto != null) {
      setState(() {
        final index = widget.pontosMapa.indexWhere((p) => p.id == ponto.id);
        if (index != -1) {
          widget.pontosMapa[index] = novoPonto;
          _filterPontosMapa(); // Atualiza a lista filtrada após a edição
        }
      });

      widget.onPontoDeletado();
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
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
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
                        key: Key(ponto.id),
                        direction: DismissDirection.endToStart,
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
                          _deletarPontoMapa(ponto.id);
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
