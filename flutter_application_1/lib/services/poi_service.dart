import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class POIService {
  Future<List<Map<String, dynamic>>> buscarPOIs(
      LatLng localizacao, double raio, String amenityFilter) async {
    if (amenityFilter.isEmpty) {
      throw ArgumentError('O filtro de amenity não pode estar vazio.');
    }

    final url = Uri.parse('https://overpass-api.de/api/interpreter');

    final query = '''
      [out:json];
      (
        node["amenity"~"$amenityFilter"]["name"](around:$raio, ${localizacao.latitude}, ${localizacao.longitude});
        node["shop"~"bookstore"]["name"](around:$raio, ${localizacao.latitude}, ${localizacao.longitude});
        node["leisure"~"reading_room"]["name"](around:$raio, ${localizacao.latitude}, ${localizacao.longitude});
      );
      out body;
      >;
      out skel qt;
    ''';

    print('Query enviada para a API: $query'); // Log da query

    try {
      final response = await http.post(url, body: query);

      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        final elementos = dados['elements'] as List<dynamic>;

        print(
            'Número de elementos retornados: ${elementos.length}'); // Log do número de elementos

        return elementos.map((elemento) {
          final tags = elemento['tags'] as Map<String, dynamic>? ?? {};
          final nome = tags['name'] ?? 'Sem nome';
          final tipo =
              tags['amenity'] ?? tags['shop'] ?? tags['leisure'] ?? 'outro';

          print(
              'POI encontrado: Nome=$nome, Tipo=$tipo'); // Log de cada POI encontrado

          return {
            'id': elemento['id'],
            'nome': nome,
            'lat': elemento['lat'],
            'lon': elemento['lon'],
            'tipo': tipo,
          };
        }).toList();
      } else {
        print('Erro na resposta da API: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar POIs: $e');
      return [];
    }
  }
}
