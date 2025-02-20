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

      if (mounted && userData.exists) {
        setState(() {
          _user = UserModel.fromJson(user.uid, userData.data() as Map<String, dynamic>);
        });
      }
    }
  }

  Future<void> _fetchCompletedTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final today = DateTime.now();
      final formattedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
      await _updateMetaWithCompletedTasks();
    }
  }

  Future<void> _fetchMeta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final today = DateTime.now();
      final formattedDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
    final metaData = metaDoc.data();
    List<String> currentTaskIds = List<String>.from(metaData['taskIds'] ?? []);

    // Buscar tarefas completadas do dia
    final tasksQuery = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .where('isComplete', isEqualTo: true)
        .where('date', isEqualTo: formattedDate)
        .get();

    List<String> completedTaskIds = tasksQuery.docs.map((doc) => doc.id).toList();

    // Atualizar apenas se houver novas tasks completadas
    final newTaskIds = completedTaskIds.toSet().difference(currentTaskIds.toSet());
    if (newTaskIds.isNotEmpty) {
      await FirebaseFirestore.instance.collection('metas').doc(metaDoc.id).update({
        'taskIds': FieldValue.arrayUnion(completedTaskIds),
      });
    }
  }

  Future<void> _fetchTasksForLastWeek() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
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

  Future<void> _sairDaConta() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/tela_login'); // Redireciona para a tela de login
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
        leading: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
                await Navigator.pushNamed(context, '/tela_edicao_perfil');
                _fetchUserData();
                _fetchMeta();
                _fetchTasksForLastWeek();
            },
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _sairDaConta,
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Container(
        color: const Color.fromARGB(255, 232, 230, 230),
        child: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _user!.fotoUrl != null
                                ? NetworkImage(_user!.fotoUrl!)
                                : const AssetImage("assets/images/perfil_padrao.png") 
                                    as ImageProvider,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _user!.nome,
                            style: const TextStyle(color: Color(0xFF133E87),fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '@${_user!.nomeUsuario}',
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          if (_meta != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Meta de tarefas do dia: ${_meta!.taskGoal}',
                                    style: TextStyle(
                                    color: Color(0xFF133E87),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Você concluiu $_taskCount de ${_meta!.taskGoal} tarefas.',
                                    style: TextStyle(
                                      color: Color(0xFF133E87),
                                      fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 15),
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      _tasksPerDay.values.any((count) => count > 0)
                        ? Column(
                            children: [
                              const Text(
                                'Tarefas concluídas nos últimos 7 dias:',
                                style: TextStyle(
                                  color: Color(0xFF133E87),
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16, 
                                ),
                              ),
                              const SizedBox(height: 20),
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
                                    barGroups: _tasksPerDay.entries.map((entry) {
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
                          )
                        : const Text(
                          'Nenhuma tarefa completada nos últimos 7 dias',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tarefas Concluídas Hoje:',
                    style: TextStyle(
                              color: Color(0xFF133E87),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
                              title: Text(
                                task.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF133E87),
                                ),
                              ),
                              subtitle: Text(task.description),
                              trailing: Text(task.hour),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }
}