import 'package:flutter/material.dart';
import 'home_page.dart';
import 'circle_page.dart';
import 'message_page.dart';
import 'me_page.dart';
import 'welcome_page.dart';
import 'edit_profile_page.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';
import 'vip_subscribe_page.dart';
import 'wallet_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourism',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/mainTab': (context) => const MainTabPage(),
        '/editProfile': (context) => const EditProfilePage(),
        '/terms': (context) => const TermsOfServicePage(),
        '/privacy': (context) => const PrivacyPolicyPage(),
        '/vip': (context) => const VipSubscribePage(),
        '/wallet': (context) => const WalletPage(),
      },
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
    );
  }
}

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CirclePage(),
    MessagePage(),
    MePage(),
  ];

  final List<String> _titles = ['Home', 'Circle', 'Message', 'Me'];

  final List<String> _iconNormal = [
    'assets/resource/tab_1_2025_6_4_n.png',
    'assets/resource/tab_2_2025_6_4_n.png',
    'assets/resource/tab_3_2025_6_4_n.png',
    'assets/resource/tab_4_2025_6_4_n.png',
  ];

  final List<String> _iconSelected = [
    'assets/resource/tab_1_2025_6_4_s.png',
    'assets/resource/tab_2_2025_6_4_s.png',
    'assets/resource/tab_3_2025_6_4_s.png',
    'assets/resource/tab_4_2025_6_4_s.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2F2F2F),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          color: Color(0xFF5BBAFA),
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Color(0xFF666666),
          fontWeight: FontWeight.w500,
        ),
        selectedItemColor: const Color(0xFF5BBAFA),
        unselectedItemColor: const Color(0xFF666666),
        items: List.generate(4, (index) {
          return BottomNavigationBarItem(
            icon: Image.asset(_iconNormal[index], width: 28, height: 28),
            activeIcon: Image.asset(
              _iconSelected[index],
              width: 28,
              height: 28,
            ),
            label: _titles[index],
          );
        }),
      ),
    );
  }
}
