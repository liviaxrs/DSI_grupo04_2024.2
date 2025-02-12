import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../models/meta.dart';
import 'package:fl_chart/fl_chart.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  UserModel? _user;
  List<Task> _completedTasks = [];
  Meta? _meta;
  int _taskCount = 0;
  Map<String, int> _tasksPerDay = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchCompletedTasks();
    _fetchMeta();
    _fetchTasksForLastWeek();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      setState(() {
        _user = UserModel.fromJson(user.uid, userData.data()!);
      });
    }
  }

  Future<void> _fetchCompletedTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final today = DateTime.now();
      final formattedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}'; // Formato: yyyy-MM-dd

      final querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .where('isComplete', isEqualTo: true)
          .where('date', isEqualTo: formattedDate)
          .get();

      setState(() {
        _completedTasks = querySnapshot.docs.map((doc) {
          return Task.fromJson(doc.id, doc.data());
        }).toList();
        _taskCount = _completedTasks.length;
      });
    }
  }

  Future<void> _fetchMeta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final today = DateTime.now();
      final formattedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}'; // Formato: yyyy-MM-dd

      final querySnapshot = await FirebaseFirestore.instance
          .collection('metas')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: formattedDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _meta = Meta.fromJson(querySnapshot.docs.first.id, querySnapshot.docs.first.data());
        });
      }
    }
  }

    Future<void> _fetchTasksForLastWeek() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 6));
    final tasksMap = <String, int>{};

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      tasksMap[formattedDate] = 0;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .where('isComplete', isEqualTo: true)
        .get();

    for (var doc in querySnapshot.docs) {
      final task = Task.fromJson(doc.id, doc.data());
      if (tasksMap.containsKey(task.date)) {
        tasksMap[task.date] = (tasksMap[task.date] ?? 0) + 1;
      }
    }

    setState(() {
      _tasksPerDay = tasksMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF133E87),
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white), 
            onPressed: () async {
              final atualizado = await Navigator.pushNamed(context, '/tela_edicao_perfil');
              if (atualizado == true) {
                _fetchUserData();
                _fetchMeta();
                _fetchTasksForLastWeek();
              }
            },
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 232, 230, 230),
        child: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Centraliza tudo na coluna principal
                  children: [
                    if (_user!.fotoUrl != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Image.network(
                              _user!.fotoUrl!,
                              width: 100, // Define o tamanho da imagem
                              height: 100,
                              fit: BoxFit.cover, // Garante que a imagem preencha o círculo corretamente
                            ),
                          ),
                          const SizedBox(height: 10), // Espaço entre a imagem e o nome
                          Text(
                            _user!.nome,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '@${_user!.nomeUsuario}', // Nome de usuário no formato rede social
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (_meta != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Meta do dia: ${_meta!.taskGoal} tarefas'),
                          const SizedBox(height: 10),
                          Text('Você concluiu $_taskCount de ${_meta!.taskGoal} tarefas.'),
                          const SizedBox(height: 10),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: (_meta!.taskGoal > 0)
                                      ? (_taskCount / _meta!.taskGoal).clamp(0.0, 1.0)
                                      : 0.0,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.blue,
                                  strokeWidth: 8,
                                ),
                              ),
                              Text(
                                '${((_taskCount / _meta!.taskGoal) * 100).clamp(0, 100).toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (_meta != null) const Text('Tarefas Concluídas Hoje:'),
                    if (_completedTasks.isEmpty)
                      const Text('Nenhuma tarefa concluída hoje.')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _completedTasks.length,
                        itemBuilder: (context, index) {
                          final task = _completedTasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(task.title),
                              subtitle: Text(task.description),
                              trailing: Text(task.hour),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    const Text('Tarefas concluídas nos últimos 7 dias:'),
                    const SizedBox(height: 20),
                    if (_tasksPerDay.isEmpty)
                      const Text('Nenhuma tarefa concluída nos últimos 7 dias.')
                    else
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final dateKey = _tasksPerDay.keys.toList()[value.toInt()];
                                    return Text(
                                      '${dateKey.split('-')[2]}/${dateKey.split('-')[1]}',
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: _tasksPerDay.entries.isEmpty
                                ? []
                                : _tasksPerDay.entries.map((entry) {
                                    return BarChartGroupData(
                                      x: _tasksPerDay.keys.toList().indexOf(entry.key),
                                      barRods: [
                                        BarChartRodData(
                                          toY: entry.value.toDouble(),
                                          color: Colors.blue,
                                          width: 16,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ),
      );
    }
  }