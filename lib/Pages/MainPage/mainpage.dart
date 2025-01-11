import 'package:flutter/material.dart';
import './HomePage/home_page.dart';
import 'package:nutrivision/Pages/MainPage/userprofile/user_profile.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key,});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> pageList = const [
    HomePage(),
    Placeholder(),
    UserProfilePage(),
  ];

  List<String> labels = [
    "Today's Progress",
    "",
    "User Profile",
  ];
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: pageList[_selectedIndex],
        appBar: _selectedIndex != 1
            ? AppBar(
                backgroundColor: Colors.green,
                toolbarHeight: 80,
                titleTextStyle: GoogleFonts.baloo2(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                title: Container(
                  margin: const EdgeInsets.only(top: 30, left: 20),
                  child: Text(
                    labels[_selectedIndex],
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : null,
        bottomNavigationBar: _selectedIndex != 1
            ? Padding(
                padding: const EdgeInsets.all(0),
                child: BottomNavigationBar(
                    onTap: (value) {
                      if (value == 1) {
                        Navigator.of(context).pushNamed('/camerapage');
                      } else {
                        setState(() {
                          _selectedIndex = value;
                        });
                      }
                    },
                    currentIndex: _selectedIndex,
                    unselectedItemColor: Colors.grey,
                    selectedItemColor: Colors.green,
                    iconSize: 35,
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: ''),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.photo_camera), label: ''),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: '')
                    ]),
              )
            : null);
  }
}
