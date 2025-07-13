import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/pages/home_page/home_page_widget.dart';
import '/velocidades/velocidades_widget.dart';
import '/desenvolvedor/desenvolvedor_widget.dart';
import '/desenvolvedor_copy/desenvolvedor_copy_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavWidget extends StatefulWidget {
  final int currentIndex;

  const BottomNavWidget({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _BottomNavWidgetState createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  final List<Widget> _pages = [
    HomePageWidget(), // Página Home
    VelocidadesWidget(), // Página Velocidades
    DesenvolvedorWidget(), // Página Controle dos Motores
    DesenvolvedorCopyWidget(), // Página Ajuste de IP
  ];

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFF010B14), // Fundo igual ao BottomNavigationBar
    body: _pages[_currentIndex],
    bottomNavigationBar: ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF010B14),
          border: Border(
            top: BorderSide(
              color: Colors.white,
              width: 0.1, // Aqui a bordinha de 0.1
            ),
          ),
        ),
                child: BottomNavigationBar(
          backgroundColor: Color(0xFF010B14),
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Inter Tight',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Inter Tight',
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            switch (index) {
              case 0:
                context.go('/homePage');
                break;
              case 1:
                context.go('/velocidades');
                break;
              case 2:
                context.go('/Desenvolvedor');
                break;
              case 3:
                context.go('/DesenvolvedorCopy');
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label:'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.speed),
              label: AppLocalizations.of(context)!.velocidades,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.control_camera_outlined),
              label: AppLocalizations.of(context)!.motores,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: AppLocalizations.of(context)!.configuracoes,
            ),
          ],
        ),
      )
    ),
  );
 }
}