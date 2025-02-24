import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/mapa.dart';
import 'locais_salvos_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'adicionar_ponto_screen.dart';
import '../services/poi_service.dart';

class MapaScreen extends StatefulWidget {
  final LatLng? localSelecionado;

  const MapaScreen({super.key, this.localSelecionado});

  @override
  MapaScreenState createState() => MapaScreenState();
}

class MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  final Set<Marker> _markers =
      {}; // Marcadores gerais (localização atual, pontos salvos, etc.)
  final Set<Marker> _poiMarkers =
      {}; // Marcadores de POIs (cafés, livrarias, etc.)
  final TextEditingController _pesquisaController = TextEditingController();
  final List<PontoMapa> _pontosMapa = [];
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final POIService _poiService = POIService();

  LatLng _currentLocation = const LatLng(-23.550520, -46.633308);
  LatLng? _primeiroToqueLocation;
  Marker? _marcadorTemporario;
  String? _userId;
  bool _carregandoPOIs = false;
  String? _filtroSelecionado;

  List<Map<String, dynamic>> _sugestoes = [];

  @override
  void initState() {
    super.initState();
    _tituloController.clear();
    _descricaoController.clear();
    _getCurrentLocation();
    _getUserIdAndLoadPoints();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _getUserIdAndLoadPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      await _carregarPontosMapa();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);

      // Remove o marcador da localização atual, se existir
      _markers
          .removeWhere((marker) => marker.key == const Key('current_location'));

      // Adiciona o novo marcador da localização atual
      _markers.add(Marker(
        width: 40,
        height: 40,
        point: _currentLocation,
        child: const Icon(Icons.location_on, color: Colors.red),
        key: const Key('current_location'),
      ));
    });

    _mapController.move(_currentLocation, 13.0);

    // Carregar os pontos salvos após obter a localização
    await _carregarPontosMapa();
  }

  Future<void> buscarEExibirPOIs(LatLng localizacao, {String? tipo}) async {
    setState(() {
      _carregandoPOIs = true;
    });

    if (tipo == null) {
      // Se o filtro foi desmarcado, limpa os POIs
      setState(() {
        _carregandoPOIs = false;
        _poiMarkers.clear();
      });
      return;
    }

    String amenityFilter = '';
    if (tipo == 'cafe') {
      amenityFilter = 'cafe';
    } else if (tipo == 'library') {
      amenityFilter = 'library';
    } else if (tipo == 'todos') {
      amenityFilter = 'cafe|library';
    }

    final pois =
        await _poiService.buscarPOIs(localizacao, 20000, amenityFilter);

    developer.log('POIs encontrados: ${pois.length}');

    setState(() {
      _carregandoPOIs = false;
      // Limpa todos os marcadores de POIs antigos
      _poiMarkers.clear();

      if (pois.isEmpty) {
        // Exibe uma mensagem se nenhum POI for encontrado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Nenhum ponto de interesse encontrado.')),
        );
      } else {
        // Adiciona marcadores para os POIs encontrados (filtrados)
        for (var poi in pois) {
          _poiMarkers.add(Marker(
            width: 40,
            height: 40,
            point: LatLng(poi['lat'], poi['lon']),
            child: const Icon(Icons.location_pin, color: Colors.orange),
            key: Key('poi_${poi['id']}'),
          ));
        }
      }
    });
  }

  Future<void> _carregarPontosMapa() async {
    if (_userId == null) {
      developer.log('UserId não está disponível.');
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('mapa')
        .where('userId', isEqualTo: _userId)
        .get();

    setState(() {
      _pontosMapa.clear();

      // Remove todos os marcadores, exceto o da localização atual
      _markers
          .removeWhere((marker) => marker.key != const Key('current_location'));

      // Adiciona os pontos salvos ao conjunto de marcadores
      _pontosMapa.addAll(querySnapshot.docs
          .map((doc) => PontoMapa.fromJson(doc.id, doc.data()))
          .toList());

      for (var ponto in _pontosMapa) {
        _markers.add(Marker(
          width: 40,
          height: 40,
          point: ponto.localizacao,
          child: const Icon(Icons.location_pin, color: Colors.blue),
          key: Key(ponto.id), // Chave simples
        ));
      }
    });
  }

  Future<void> salvarPontoMapa(PontoMapa ponto) async {
    await FirebaseFirestore.instance.collection('mapa').add(ponto.toJson());
  }

  void _adicionarPontoMapa(LatLng localizacao) async {
    if (_userId == null) return;

    final novoPonto = PontoMapa(
      id: UniqueKey().toString(),
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      localizacao: localizacao,
      userId: _userId!,
    );

    await salvarPontoMapa(novoPonto);
    _carregarPontosMapa();

    // Limpa os controladores após salvar
    _tituloController.clear();
    _descricaoController.clear();
  }

  void _onMapTap(TapPosition tapPosition, LatLng localizacao) {
    // Remove o marcador do local pesquisado, se existir
    setState(() {
      _markers
          .removeWhere((marker) => marker.key == const Key('local_pesquisado'));
    });

    // Adiciona um marcador temporário se não houver um já
    if (_primeiroToqueLocation == null) {
      setState(() {
        _primeiroToqueLocation = localizacao;
        _marcadorTemporario = Marker(
          width: 40,
          height: 40,
          point: localizacao,
          child: const Icon(Icons.location_pin, color: Colors.green),
          key: const Key('marcador_temporario'),
        );
        _markers.add(_marcadorTemporario!);
      });
    } else {
      final distancia =
          _calcularDistancia(_primeiroToqueLocation!, localizacao);
      if (distancia < 50) {
        _navegarParaAdicionarPonto(localizacao);
      } else {
        setState(() {
          _primeiroToqueLocation = null;
          _markers.remove(_marcadorTemporario);
        });
      }
    }
  }

  double _calcularDistancia(LatLng ponto1, LatLng ponto2) {
    return Geolocator.distanceBetween(
      ponto1.latitude,
      ponto1.longitude,
      ponto2.latitude,
      ponto2.longitude,
    );
  }

  void _navegarParaAdicionarPonto(LatLng localizacao) async {
    _tituloController.clear();
    _descricaoController.clear();

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdicionarPontoScreen(localizacao: localizacao),
      ),
    );

    if (resultado != null) {
      _tituloController.text = resultado['titulo'];
      _descricaoController.text = resultado['descricao'];
      _adicionarPontoMapa(localizacao);
    }

    setState(() {
      _primeiroToqueLocation = null;
      _markers.remove(_marcadorTemporario);
    });
  }

  void _recarregarPontos() async {
    developer.log('Recarregando pontos...');
    await _carregarPontosMapa();
    _mapController.move(
        _currentLocation, _mapController.camera.zoom); // Forçar atualização
  }

  // Função para pesquisar endereço usando Nominatim
  Future<List<Map<String, dynamic>>> pesquisarEndereco(String endereco) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$endereco&format=json&limit=5&countrycodes=BR',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> dados = json.decode(response.body);
        return dados
            .map((localizacao) => {
                  'nome': localizacao['display_name'],
                  'lat': double.parse(localizacao['lat']),
                  'lon': double.parse(localizacao['lon']),
                })
            .toList();
      }
    } catch (e) {
      developer.log('Erro na pesquisa: $e');
    }

    return [];
  }

  // Função para pesquisar local e atualizar sugestões
  void _atualizarSugestoes(String endereco) async {
    if (endereco.isEmpty) {
      setState(() {
        _sugestoes.clear();
      });
      return;
    }

    final sugestoes = await pesquisarEndereco(endereco);
    setState(() {
      _sugestoes = sugestoes;
    });
  }

  // Função para mover o mapa para o local selecionado
  void _selecionarSugestao(Map<String, dynamic> sugestao) {
    final latLng = LatLng(sugestao['lat'], sugestao['lon']);
    setState(() {
      _currentLocation = latLng;

      // Remove apenas o marcador do local pesquisado anterior, se existir
      _markers
          .removeWhere((marker) => marker.key == const Key('local_pesquisado'));

      // Adiciona o novo marcador do local pesquisado
      _markers.add(Marker(
        width: 40,
        height: 40,
        point: latLng,
        child: const Icon(Icons.location_on, color: Colors.red),
        key: const Key('local_pesquisado'),
      ));
    });

    _mapController.move(latLng, 13.0);
    _pesquisaController.text = sugestao['nome'];
    setState(() {
      _sugestoes.clear();
    });
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
            'Mapa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: Row(
          children: [
            PopupMenuButton<String>(
              onSelected: (String tipo) async {
                if (_filtroSelecionado == tipo) {
                  // Desmarca o filtro se ele já estiver selecionado
                  setState(() {
                    _filtroSelecionado = null;
                  });
                  await buscarEExibirPOIs(_currentLocation,
                      tipo: null); // Limpa os POIs
                } else {
                  // Aplica o novo filtro
                  setState(() {
                    _filtroSelecionado = tipo;
                  });
                  await buscarEExibirPOIs(_currentLocation, tipo: tipo);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'cafe',
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_cafe,
                        color: _filtroSelecionado == 'cafe'
                            ? const Color(0xFF133E87)
                            : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cafés',
                        style: TextStyle(
                          color: _filtroSelecionado == 'cafe'
                              ? const Color(0xFF133E87)
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'library',
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_library,
                        color: _filtroSelecionado == 'library'
                            ? const Color(0xFF133E87)
                            : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Livrarias',
                        style: TextStyle(
                          color: _filtroSelecionado == 'library'
                              ? const Color(0xFF133E87)
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'todos',
                  child: Row(
                    children: [
                      Icon(
                        Icons.all_inclusive,
                        color: _filtroSelecionado == 'todos'
                            ? const Color(0xFF133E87)
                            : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Todos',
                        style: TextStyle(
                          color: _filtroSelecionado == 'todos'
                              ? const Color(0xFF133E87)
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.filter_list, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () async {
              final coordenadas = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocaisSalvosScreen(
                    pontosMapa: _pontosMapa,
                    onPontoDeletado: _recarregarPontos,
                  ),
                ),
              );

              if (coordenadas != null) {
                _mapController.move(coordenadas, 13.0);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [..._markers, ..._poiMarkers].toList(),
              ),
            ],
          ),
          if (_carregandoPOIs) const Center(child: CircularProgressIndicator()),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                _buildSearchBar(),
                if (_sugestoes.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _sugestoes.length,
                      itemBuilder: (context, index) {
                        final sugestao = _sugestoes[index];
                        return ListTile(
                          title: Text(sugestao['nome']),
                          onTap: () => _selecionarSugestao(sugestao),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _pesquisaController,
              decoration: const InputDecoration(
                hintText: 'Digite o nome do local',
                hintStyle: TextStyle(color: Colors.black54),
                border: InputBorder.none,
              ),
              onChanged: _atualizarSugestoes,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: () {
              if (_sugestoes.isNotEmpty) {
                _selecionarSugestao(_sugestoes.first);
              }
            },
          ),
        ],
      ),
    );
  }
}
