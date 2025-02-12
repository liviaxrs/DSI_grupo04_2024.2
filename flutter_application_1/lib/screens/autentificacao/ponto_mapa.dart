// lib/models/ponto_mapa.dart
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

  factory PontoMapa.fromMap(Map<String, dynamic> map, String id) {
    return PontoMapa(
      id: id, // Garante que o ID do Firestore seja usado
      userId: map['userId'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      localizacao: LatLng(map['latitude'], map['longitude']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Garante que o ID seja salvo no Firestore
      'userId': userId,
      'titulo': titulo,
      'descricao': descricao,
      'latitude': localizacao.latitude,
      'longitude': localizacao.longitude,
    };
  }
}
