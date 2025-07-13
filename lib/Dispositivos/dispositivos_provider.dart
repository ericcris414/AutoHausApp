import 'package:flutter/material.dart';

class Dispositivo {
  final String name;
  final IconData? icon;
  final String? image;

  Dispositivo({required this.name, this.icon, this.image});
}

class DispositivosProvider extends ChangeNotifier {
  final List<Dispositivo> _dispositivosSelecionados = [
    // Dispositivos pré-definidos
    Dispositivo(name: "toldo", image: "assets/images/toldohome.png"),
    Dispositivo(name: "janela", image: "assets/images/janelahome.png"),
  ];

  List<Dispositivo> get dispositivosSelecionados => _dispositivosSelecionados;

  void adicionarDispositivo(Dispositivo dispositivo) {
    if (!_dispositivosSelecionados.any((d) => d.name == dispositivo.name)) {
      _dispositivosSelecionados.add(dispositivo);
      notifyListeners();
    }
  }

  void removerDispositivo(Dispositivo dispositivo) {
    _dispositivosSelecionados.removeWhere((d) => d.name == dispositivo.name);
    notifyListeners();
  }
}