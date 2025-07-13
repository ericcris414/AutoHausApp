import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'mqtt/mqtt_service.dart';
import 'backend/api_requests/mqtt_calls.dart';
import 'dart:convert';



class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal() {
    mqttService = MQTTService(
      clientId: 'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static void reset() {
    _instance = FFAppState._internal();
  }

  late MQTTService mqttService;

  Future initializePersistedState() async {
    mqttService.connect();
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _Ispressed = '';
  String get Ispressed => _Ispressed;
  set Ispressed(String value) {
    _Ispressed = value;
  }

  String _Ledcontrol = '';
  String get Ledcontrol => _Ledcontrol;
  set Ledcontrol(String value) {
    _Ledcontrol = value;
  }

  String _LedControlUrl = '';
  String get LedControlUrl => _LedControlUrl;
  set LedControlUrl(String value) {
    _LedControlUrl = value;
  }

  String _esp32ip = '192.168.100.98';
  String get esp32ip => _esp32ip;
  set esp32ip(String value) {
    _esp32ip = value;
  }

  String _selectedLanguage = 'Portuguese'; // padrão
  String get selectedLanguage => _selectedLanguage;
  set selectedLanguage(String val) {
  _selectedLanguage = val;
 }

  int _SliderToldo = 0;
  int get SliderToldo => _SliderToldo;
  set SliderToldo(int value) {
    _SliderToldo = value;
  }

  String _EstadoSensor = '\$.sensor_estado';
  String get EstadoSensor => _EstadoSensor;
  set EstadoSensor(String value) {
    _EstadoSensor = value;
  }

  dynamic _EstadoSensor1 = jsonDecode('null');
  dynamic get EstadoSensor1 => _EstadoSensor1;
  set EstadoSensor1(dynamic value) {
    _EstadoSensor1 = value;
  }

  int _velAfrente = 92;
  int get velAfrente => _velAfrente;
  set velAfrente(int value) {
    _velAfrente = value;
  }

  int _velBfrente = 200;
  int get velBfrente => _velBfrente;
  set velBfrente(int value) {
    _velBfrente = value;
  }

  int _velAtras = 210;
  int get velAtras => _velAtras;
  set velAtras(int value) {
    _velAtras = value;
  }

  int _velBtras = 85;
  int get velBtras => _velBtras;
  set velBtras(int value) {
    _velBtras = value;
  }

  bool _sliderfudido = false;
  bool get sliderfudido => _sliderfudido;
  set sliderfudido(bool value) {
    _sliderfudido = value;
  }

  bool _sliderswitchtoldo = false;
  bool get sliderswitchtoldo => _sliderswitchtoldo;
  set sliderswitchtoldo(bool value) {
    _sliderswitchtoldo = value;
  }

  int _SliderJanela = 0;
  int get SliderJanela => _SliderJanela;
  set SliderJanela(int value) {
    _SliderJanela = value;
  }

  int _velJanelaAbrir = 100;
  int get velJanelaAbrir => _velJanelaAbrir;
  set velJanelaAbrir(int value) {
    _velJanelaAbrir = value;
  }

  int _velJanelaFechar = 100;
  int get velJanelaFechar => _velJanelaFechar;
  set velJanelaFechar(int value) {
    _velJanelaFechar = value;
  }

  bool _sliderChuvaJanela = false;
  bool get sliderChuvaJanela => _sliderChuvaJanela;
  set sliderChuvaJanela(bool value) {
    _sliderChuvaJanela = value;
  }

  bool _sliderjanela = false;
  bool get sliderjanela => _sliderjanela;
  set sliderjanela(bool value) {
    _sliderjanela = value;
  }
}
