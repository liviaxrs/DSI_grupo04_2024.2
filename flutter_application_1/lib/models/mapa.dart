import 'package:google_maps_flutter/google_maps_flutter.dart';

class PontoMapa {
  final String id;
  final String userId;
  final String titulo;
  final String descricao;
  final LatLng localizacao;

  PontoMapa({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.descricao,
    required this.localizacao,
  });

  // Convert PontoMapa object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'titulo': titulo,
      'descricao': descricao,
      'latitude': localizacao.latitude,
      'longitude': localizacao.longitude,
    };
  }

  // Create PontoMapa object from Firestore JSON data
  factory PontoMapa.fromJson(String id, Map<String, dynamic> json) {
    return PontoMapa(
      id: id,
      userId: json['userId'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      localizacao: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
    );
  }
}
