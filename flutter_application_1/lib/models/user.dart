class UserModel {
  final String id;
  final String email;
  String nome;
  String nomeUsuario;
  String? fotoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.nome,
    required this.nomeUsuario,
    this.fotoUrl, // Pode ser nulo se o usuário não tiver foto
  });

  // Converte o objeto UserModel para um Map para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nome': nome,
      'nomeUsuario': nomeUsuario,
      'fotoUrl': fotoUrl,
    };
  }

  // Cria um UserModel a partir dos dados do Firestore
  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      email: json['email'] as String,
      nome: json['nome'] as String,
      nomeUsuario: json['nomeUsuario'] as String,
      fotoUrl: json['fotoUrl'] as String?,
    );
  }
}