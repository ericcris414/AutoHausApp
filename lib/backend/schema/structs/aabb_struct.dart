// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AabbStruct extends BaseStruct {
  AabbStruct({
    String? estado,
    int? aberto,
    int? aberta,
  })  : _estado = estado,
        _aberto = aberto,
        _aberta = aberta;

  // "estado" field.
  String? _estado;
  String get estado => _estado ?? 'SECO';
  set estado(String? val) => _estado = val;

  // "aberto" field (toldo).
  int? _aberto;
  int get aberto => _aberto ?? 0;
  set aberto(int? val) => _aberto = val;

  // "aberta" field (janela).
  int? _aberta;
  int get aberta => _aberta ?? 0;
  set aberta(int? val) => _aberta = val;

  bool hasEstado() => _estado != null;
  bool hasAberto() => _aberto != null;
  bool hasAberta() => _aberta != null;

  static AabbStruct fromMap(Map<String, dynamic> data) => AabbStruct(
        estado: data['estado'] as String?,
        aberto: castToType<int>(data['aberto']),
        aberta: castToType<int>(data['aberta']),
      );

  static AabbStruct? maybeFromMap(dynamic data) =>
      data is Map ? AabbStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'estado': _estado,
        'aberto': _aberto,
        'aberta': _aberta,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'estado': serializeParam(
          _estado,
          ParamType.String,
        ),
        'aberto': serializeParam(
          _aberto,
          ParamType.int,
        ),
        'aberta': serializeParam(
          _aberta,
          ParamType.int,
        ),
      }.withoutNulls;

  static AabbStruct fromSerializableMap(Map<String, dynamic> data) => AabbStruct(
        estado: deserializeParam(
          data['estado'],
          ParamType.String,
          false,
        ),
        aberto: deserializeParam(
          data['aberto'],
          ParamType.int,
          false,
        ),
        aberta: deserializeParam(
          data['aberta'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'AabbStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AabbStruct &&
        estado == other.estado &&
        aberto == other.aberto &&
        aberta == other.aberta;
  }

  @override
  int get hashCode => const ListEquality().hash([estado, aberto, aberta]);
}

AabbStruct createAabbStruct({
  String? estado,
  int? aberto,
  int? aberta,
}) =>
    AabbStruct(
      estado: estado,
      aberto: aberto,
      aberta: aberta,
    );