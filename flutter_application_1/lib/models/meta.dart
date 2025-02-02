class Meta {
  final String id;
  final String userId;
  final String date; // Data da meta (formato YYYY-MM-DD)
  int taskGoal; // Número de tarefas que o usuário quer completar
  final List<String> taskIds; // IDs das tarefas associadas à meta

  Meta({
    required this.id,
    required this.userId,
    required this.date,
    required this.taskGoal,
    required this.taskIds,
  });

  // Converte o objeto Meta para um Map para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date,
      'taskGoal': taskGoal,
      'taskIds': taskIds,
    };
  }

  // Cria um Meta a partir dos dados do Firestore
  factory Meta.fromJson(String id, Map<String, dynamic> json) {
    return Meta(
      id: id,
      userId: json['userId'] as String,
      date: json['date'] as String,
      taskGoal: json['taskGoal'] as int,
      taskIds: List<String>.from(json['taskIds'] ?? []),
    );
  }
}