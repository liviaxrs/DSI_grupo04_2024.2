import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as developer;
import 'autentificacao/ponto_mapa.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  MapaScreenState createState() => MapaScreenState();
}

class MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final List<PontoMapa> _pontosMapa = [];
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _pesquisaController = TextEditingController();

  static LatLng _currentLocation = const LatLng(-23.550520, -46.633308);
  LatLng? _primeiroToqueLocation;
  Marker? _marcadorTemporario;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) _carregarPontosMapa(user.uid);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation,
        infoWindow: const InfoWindow(title: 'Você está aqui'),
      ));
    });

    mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation));
  }

  Future<void> _carregarPontosMapa(String userId) async {
    final pontos = await recuperarPontosMapa(userId);
    setState(() {
      _pontosMapa.clear(); // Limpa a lista de pontos existentes
      _markers.clear(); // Limpa os marcadores existentes
      _pontosMapa.addAll(pontos); // Adiciona os novos pontos
      _markers.addAll(pontos
          .map((ponto) => Marker(
                markerId: MarkerId(ponto.id),
                position: ponto.localizacao,
                infoWindow:
                    InfoWindow(title: ponto.titulo, snippet: ponto.descricao),
              ))
          .toList());
    });
  }

  Future<List<PontoMapa>> recuperarPontosMapa(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('mapa')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs
        .map((doc) => PontoMapa.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> salvarPontoMapa(PontoMapa ponto) async {
    await FirebaseFirestore.instance.collection('mapa').add(ponto.toMap());
  }

  void _adicionarPontoMapa(LatLng localizacao) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final novoPonto = PontoMapa(
      id: UniqueKey().toString(), // Add a unique id
      userId: user.uid,
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      localizacao: localizacao,
    );

    await salvarPontoMapa(novoPonto);
    _carregarPontosMapa(user.uid); // Recarrega os pontos após salvar
  }

  Future<void> _deletarPontoMapa(String pontoId) async {
    try {
      await FirebaseFirestore.instance.collection('mapa').doc(pontoId).delete();

      setState(() {
        _pontosMapa.removeWhere((ponto) => ponto.id == pontoId);
        _markers.removeWhere((marker) => marker.markerId.value == pontoId);
      });
    } catch (e) {
      developer.log('Erro ao deletar ponto: $e');
    }
  }

  Future<void> _pesquisarLocal(String nomeLocal) async {
    try {
      List<Location> locations = await locationFromAddress(nomeLocal);
      if (locations.isNotEmpty) {
        LatLng novaLocalizacao =
            LatLng(locations[0].latitude, locations[0].longitude);
        mapController.animateCamera(CameraUpdate.newLatLng(novaLocalizacao));
        setState(() {
          _markers.clear();
          _markers.add(Marker(
            markerId: MarkerId('pesquisa'),
            position: novaLocalizacao,
            infoWindow: InfoWindow(title: nomeLocal),
          ));
        });
      }
    } catch (e) {
      developer.log('Erro ao buscar local: $e');
    }
  }

  void _onMapTap(LatLng localizacao) {
    if (_primeiroToqueLocation == null) {
      setState(() {
        _primeiroToqueLocation = localizacao;
        _marcadorTemporario = Marker(
          markerId: const MarkerId('marcador_temporario'),
          position: localizacao,
          infoWindow: const InfoWindow(title: 'Toque novamente para confirmar'),
        );
        _markers.add(_marcadorTemporario!);
      });
    } else {
      final distancia =
          _calcularDistancia(_primeiroToqueLocation!, localizacao);
      if (distancia < 50) {
        _mostrarDialogoConfirmacao(localizacao);
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

  void _mostrarDialogoConfirmacao(LatLng localizacao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar ponto de interesse'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _primeiroToqueLocation = null;
                _markers.remove(_marcadorTemporario);
              });
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _adicionarPontoMapa(localizacao);
              Navigator.pop(context);
              setState(() {
                _primeiroToqueLocation = null;
                _markers.remove(_marcadorTemporario);
              });
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
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
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 11.0,
            ),
            markers: _markers,
            onTap: _onMapTap,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildSearchBar(),
          ),
          if (_pontosMapa.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildPontosMapaList(),
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
            ),
          ),
          GestureDetector(
            onTap: () => _pesquisarLocal(_pesquisaController.text),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.search, color: Color(0xFF133E87)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPontosMapaList() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _pontosMapa
            .map((ponto) => ListTile(
                  title: Text(
                    ponto.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF133E87),
                    ),
                  ),
                  subtitle: Text(
                    ponto.descricao,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFF133E87)),
                    onPressed: () => _deletarPontoMapa(ponto.id),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
