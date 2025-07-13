import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/Dispositivos/dispositivos_provider.dart'; // Importe o provider
import 'home_page_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
export 'home_page_model.dart';
import 'package:flutter/services.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

extension LocalizedDeviceName on AppLocalizations {
  String traduzirDispositivo(String key) {
    switch (key) {
      case 'lampada': return lampada;
      case 'hortas': return hortas;
      case 'portoes': return portoes;
      case 'toldo': return toldo;
      case 'janela': return janela;
      case 'computador': return computador;
      case 'arCondicionado': return arCondicionado;
      default: return key;
    }
  }
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF010B14),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dispositivosProvider = Provider.of<DispositivosProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: Color(0xFF010B14),
          body: SafeArea(
            top: true,
            child: Column(
              children: [
                // Cabeçalho
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Home',
                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                              fontFamily: 'Inter Tight',
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: 27),
                        color: FlutterFlowTheme.of(context).primaryText,
                        onPressed: () {
                          // Navegar para a página de adicionar dispositivos
                          context.pushNamed(ObjetosWidget.routeName);
                        },
                      ),
                    ],
                  ),
                ),

                // Grid de dispositivos dinâmico
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: dispositivosProvider.dispositivosSelecionados.length,
                      itemBuilder: (context, index) {
                        final dispositivo = dispositivosProvider.dispositivosSelecionados[index];
                        return _buildDispositivoCard(dispositivo);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

      Widget _buildDispositivoCard(Dispositivo dispositivo) {
    // Cor baseada no nome do dispositivo
    final bool isToldoOuJanela = dispositivo.name == "janela" || dispositivo.name == "toldo" ;
    final Color corPrincipal = isToldoOuJanela ? Color(0xFF059FD1) : Color(0xFF4F5C69);

    return Container(
      decoration: BoxDecoration(
        color: Color(0x06000000),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: corPrincipal),
      ),
      child: Stack(
        children: [
          // Ícone ou Imagem central
          Align(
            alignment: Alignment.center,
            child: dispositivo.icon != null
                ? Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 40),
                    child: Icon(
                      dispositivo.icon,
                      size: 95,
                      color: corPrincipal, // Ícone com cor personalizada
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 30),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(corPrincipal, BlendMode.srcIn),
                      child: Image.asset(
                        dispositivo.image!,
                        width: 95,
                        height: 95,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
          ),

          // Texto do nome
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text(
                AppLocalizations.of(context)!.traduzirDispositivo(dispositivo.name),
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Inter Tight',
                      color: corPrincipal,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          // Botão cobrindo todo o card
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (dispositivo.name == "janela") {
                    context.pushNamed(JanelaWidget.routeName);
                  } else if (dispositivo.name == "toldo") {
                    context.pushNamed(ToldoWidget.routeName);
                  }
                },
                onLongPress: () async {
                  if (dispositivo.name != "toldo" && dispositivo.name != "janela") {
                    if (mounted) {
                      final provider = Provider.of<DispositivosProvider>(context, listen: false);
                      provider.removerDispositivo(dispositivo);
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}