import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:auto_haus/Dispositivos/dispositivos_provider.dart'; // Importe o provider
import 'objetos_model.dart';
export 'objetos_model.dart';

class ObjetosWidget extends StatefulWidget {
  const ObjetosWidget({super.key});

  static String routeName = 'Objetos';
  static String routePath = '/objetos';

  @override
  State<ObjetosWidget> createState() => _ObjetosWidgetState();
}

class _ObjetosWidgetState extends State<ObjetosWidget> {
  late ObjetosModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista filtrada que será exibida
  List<Map<String, dynamic>> filteredDevices = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ObjetosModel());

    _model.searchBarTextController ??= TextEditingController();
    _model.searchBarFocusNode ??= FocusNode();

    // Inicializa a lista de dispositivos quando o widget é criado
    _initializeDevicesList();

    // Adiciona listener para o campo de pesquisa
    _model.searchBarTextController?.addListener(_filterDevices);
  }

  // Função para inicializar a lista de dispositivos com os textos localizados
  void _initializeDevicesList() {
    final localizations = AppLocalizations.of(context)!;
    
    // Cria a lista de dispositivos usando as strings localizadas
    final allDevices = [
      {
        'name': 'lampada',
        'nome': localizations.lampada,
        'icon': Icons.lightbulb_outline_rounded,
        'image': null,
      },
      {
        'name': 'hortas',
        'nome': localizations.hortas,
        'icon': Icons.water_drop_outlined,
        'image': null,
      },
      {
        'name': 'portoes',
        'nome': localizations.portoes,
        'icon': null,
        'image': 'assets/images/portahome.png',
        'thumb': 'porta.png',
      },
      {
        'name': 'toldo',
        'nome': localizations.toldo,
        'icon': null,
        'image': 'assets/images/toldohome.png',
        'thumb': 'toldo.png',
      },
      {
        'name': 'janela',
        'nome': localizations.janela,
        'icon': null,
        'image': 'assets/images/janelahome.png',
        'thumb': 'janela.png',
      },
      {
        'name': 'computador',
        'nome': localizations.computador,
        'icon': null,
        'image': 'assets/images/computadorhome.png',
        'thumb': 'computador.png',
      },
      {
        'name': 'arCondicionado',
        'nome': localizations.arCondicionado,
        'icon': null,
        'image': 'assets/images/arhome.png',
        'thumb': 'ar.png',
      },
    ];
    
    setState(() {
      filteredDevices = List.from(allDevices);
    });
  }

  void _filterDevices() {
    // Protege contra valores nulos usando o operador '!' para garantir não-nulidade
    final query = _model.searchBarTextController!.text.toLowerCase();
    final localizations = AppLocalizations.of(context)!;

    setState(() {
      if (query.contains('qual o melhor projeto')) {
        // Easter egg ativado!
        filteredDevices = [
          {
            'name': 'Obviamente o Toldo',
            'icon': Icons.emoji_events,
            'image': null,
          },
          {
            'name': 'Com certeza o Toldo kkk',
            'icon': Icons.emoji_events,
            'image': null,
          },
          {
            'name': 'Vote Toldo 2025!',
            'icon': Icons.how_to_vote,
            'image': null,
          },
          {
            'name': 'Projeto melhor que do sereia',
            'icon': Icons.cancel_outlined,
            'image': null,
          },
          {
            'name': 'André lindo',
            'icon': Icons.star_rate,
            'image': null,
          },
          {
            'name': 'Agradecimetos especiais:',
            'icon': Icons.star_rate,
            'image': null,
          },
          {
            'name': 'Paulo Ricardo (Paulimpim)',
            'icon': Icons.star_rate,
            'image': null,
          },
          {
            'name': 'Fabio Moura (Fabin xrc)',
            'icon': Icons.star_rate,
            'image': null,
          },
          {
            'name': 'Leonardo Augusto (Bola de Ouro)',
            'icon': Icons.star_rate,
            'image': null,
          },
        ];
      } else {
        // Recarrega a lista completa de dispositivos com strings localizadas
        // para garantir que mesmo após mudança de idioma, a filtragem funcione corretamente
        final allDevices = [
          {
            'name': 'lampada',
            'nome': localizations.lampada,
            'icon': Icons.lightbulb_outline_rounded,
            'image': null,
          },
          {
            'name': 'hortas',
            'nome': localizations.hortas,
            'icon': Icons.water_drop_outlined,
            'image': null,
          },
          {
            'name': 'portoes',
            'nome': localizations.portoes,
            'icon': null,
            'image': 'assets/images/portahome.png',
            'thumb': 'porta.png',
          },
          {
            'name': 'toldo',
            'nome': localizations.toldo,
            'icon': null,
            'image': 'assets/images/toldohome.png',
            'thumb': 'toldo.png',
          },
          {
            'name': 'janela',
            'nome': localizations.janela,
            'icon': null,
            'image': 'assets/images/janelahome.png',
            'thumb': 'janela.png',
          },
          {
            'name': 'computador',
            'nome': localizations.computador,
            'icon': null,
            'image': 'assets/images/computadorhome.png',
            'thumb': 'computador.png',
          },
          {
            'name': 'arCondionado',
            'nome': localizations.arCondicionado,
            'icon': null,
            'image': 'assets/images/arhome.png',
            'thumb': 'ar.png',
          },
        ];
        
        filteredDevices = allDevices.where((device) {
          final query = _model.searchBarTextController?.text.toLowerCase() ?? '';
          return (device['name'] as String?)?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reinicializa a lista de dispositivos quando há mudança nas dependências
    // (o que inclui mudanças no Locale/idioma)
    _initializeDevicesList();
  }

  @override
  void dispose() {
    _model.searchBarTextController?.removeListener(_filterDevices);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF010B14),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              // Botão visível para ir para a homepage
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10.0, 8.0, 0, 0),
                child: SizedBox(
                  width: 60.0,
                  height: 60.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () {
                      context.go('/homepage'); // ou Navigator.pushNamed(context, '/homepage')
                    },
                    child: const SizedBox.shrink(), // invisível
                  ),
                ),
              ),

              Stack(
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0.0, -1.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          129.0, 18.0, 129.0, 20.0),
                      child: Text(
                        AppLocalizations.of(context)!.dispositivos,
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              fontFamily: 'Inter Tight',
                              color: Colors.white,
                              fontSize: 25.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                      child: Stack(
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  15.0, 30.0, 8.0, 0.0),
                              child: Container(
                                width: 330.0,
                                child: TextFormField(
                                  controller: _model.searchBarTextController,
                                  focusNode: _model.searchBarFocusNode,
                                  textCapitalization: TextCapitalization.words,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)!.procure,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFF262D34),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    contentPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24.0, 24.0, 24.0, 24.0),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 16.0,
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  validator: _model
                                      .searchBarTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          const Opacity(
                            opacity: 0.0,
                            child: Align(
                              alignment: AlignmentDirectional(-1.0, -1.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    339.0, 29.0, 0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: null,
                                  text: 'Button',
                                  options: FFButtonOptions(
                                    width: 60.0,
                                    height: 60.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Colors.transparent,
                                    textStyle: TextStyle(
                                      fontFamily: 'Inter Tight',
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                    elevation: 0.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                355.0, 43.0, 0.0, 0.0),
                            child: Icon(
                              Icons.search_sharp,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 34.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 22.0, 300.0, 900.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 26.0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 170.0, 0.0, 0.0),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final device = filteredDevices[index];
                    return GestureDetector(
                      onTap: () {
                          if (_model.searchBarTextController!.text
                              .toLowerCase()
                              .contains('qual o melhor projeto')) {
                            // Nada acontece, é só a piada kkk
                            return;
                          }

                          final dispositivo = Dispositivo(
                            name: device['name'],
                            icon: device['icon'],
                            image: device['image'],
                          );

                          Provider.of<DispositivosProvider>(context, listen: false)
                              .adicionarDispositivo(dispositivo);

                          Navigator.pop(context);
                        },

                      child: Align(
                        alignment: AlignmentDirectional(0.0, -1.0),
                        child: Container(
                          width: 500.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: const Color(0x011D2428),
                            borderRadius: BorderRadius.circular(0.0),
                            border: Border.all(
                              color: Colors.white,
                              width: 0.1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(-1.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(19.0, 0.0, 0.0, 0.0),
                                  child: device['icon'] != null
                                      ? Icon(
                                          device['icon'],
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          size: 28.0,
                                        )
                                      : (device['thumb'] != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/${device['thumb']}',
                                                width: 30.0,
                                                height: 30.0,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const SizedBox(
                                              width: 30.0,
                                              height: 30.0,
                                            )),
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-1.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(70.0, 0.0, 0.0, 0.0),
                                  child: Text(
                                    device['nome'] ?? device['name'] ?? 'Sem nome',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Inter',
                                          fontSize: 20.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}