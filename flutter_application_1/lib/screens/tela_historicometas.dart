import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/meta.dart';

class HistoricoMetasScreen extends StatefulWidget {
  const HistoricoMetasScreen({super.key});

  @override
  _HistoricoMetasScreenState createState() => _HistoricoMetasScreenState();
}

class _HistoricoMetasScreenState extends State<HistoricoMetasScreen> {
  final TextEditingController _dataController = TextEditingController();
  List<Meta> _metas = [];
  String? _selectedMonth;
  String? _selectedYear;
  bool _bateuMetaFilter = false;

  final List<String> _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  final List<String> _years = ['2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030'];

  @override
  void initState() {
    super.initState();
    _buscarMetas();
    
    FirebaseFirestore.instance.collection('tasks').snapshots().listen((snapshot) {
      _updateMetaWithCompletedTasks();
      _buscarMetas();
    });
  }

  Future<void> _buscarMetas({String? data}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Query query = FirebaseFirestore.instance
        .collection('metas')
        .where('userId', isEqualTo: user.uid);

    if (data != null && data.isNotEmpty) {
      final dateFormat = DateFormat('dd-MM-yyyy');
      final parsedDate = dateFormat.parse(data);
      final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      query = query.where('date', isEqualTo: formattedDate);
    }

    if (_selectedMonth != null && _selectedYear != null) {
      final monthIndex = _months.indexOf(_selectedMonth!) + 1;
      final startDate = '$_selectedYear-${monthIndex.toString().padLeft(2, '0')}-01';
      final endDate = '$_selectedYear-${monthIndex.toString().padLeft(2, '0')}-31';
      query = query.where('date', isGreaterThanOrEqualTo: startDate).where('date', isLessThanOrEqualTo: endDate);
    }

    final snapshot = await query.get();

    if (!mounted) return;

    setState(() {
      _metas = snapshot.docs
          .map((doc) => Meta.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      if (_bateuMetaFilter) {
        _metas = _metas.where((meta) => meta.taskIds.length >= meta.taskGoal).toList();
      }
    });
  }

  Future<void> _updateMetaWithCompletedTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final formattedDate =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Buscar a meta do dia
    final metaQuery = await FirebaseFirestore.instance
        .collection('metas')
        .where('userId', isEqualTo: user.uid)
        .where('date', isEqualTo: formattedDate)
        .get();

    if (metaQuery.docs.isEmpty) return;

    final metaDoc = metaQuery.docs.first;

    // Buscar tarefas completadas do dia
    final tasksQuery = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .where('isComplete', isEqualTo: true)
        .where('date', isEqualTo: formattedDate)
        .get();

    List<String> completedTaskIds = tasksQuery.docs.map((doc) => doc.id).toList();

    // Atualizar a meta com as tarefas completadas
    await FirebaseFirestore.instance.collection('metas').doc(metaDoc.id).update({
      'taskIds': completedTaskIds,
    });
  }

  Future<void> _excluirMeta(String metaId) async {
    await FirebaseFirestore.instance.collection('metas').doc(metaId).delete();
    _buscarMetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Metas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF133E87),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 232, 230, 230),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dataController,
              decoration: InputDecoration(
                labelText: 'Pesquisar por Data (DD-MM-YYYY)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _buscarMetas(data: _dataController.text),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    hint: const Text('Mês'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMonth = newValue;
                      });
                      _buscarMetas();
                    },
                    items: _months.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    hint: const Text('Ano'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                      _buscarMetas();
                    },
                    items: _years.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _bateuMetaFilter,
                  onChanged: (bool? value) {
                    setState(() {
                      _bateuMetaFilter = value ?? false;
                    });
                    _buscarMetas();
                  },
                ),
                const Text('Bateu Meta'),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _metas.length,
                itemBuilder: (context, index) {
                  final meta = _metas[index];
                  final bateuMeta = meta.taskIds.length >= meta.taskGoal;
                  final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(meta.date));
                  return Dismissible(
                    key: Key(meta.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _excluirMeta(meta.id);
                    },
                    child: Card(
                      child: ListTile(
                        title: Text('Meta de tarefas: ${meta.taskGoal}'),
                        subtitle: Text('Data: $formattedDate\nConcluídas: ${meta.taskIds.length}'),
                        trailing: Icon(
                          bateuMeta ? Icons.check_circle : Icons.cancel,
                          color: bateuMeta ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}