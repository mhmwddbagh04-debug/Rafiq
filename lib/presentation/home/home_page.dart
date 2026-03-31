import 'package:Rafiq/presentation/home/tabs/home_tab.dart';
import 'package:Rafiq/presentation/home/tabs/interaction_tab.dart';
import 'package:Rafiq/presentation/home/tabs/pharmacy_tab.dart';
import 'package:Rafiq/presentation/home/tabs/search_tab.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = [
    HomeTab(),
    SearchTab(),
    InteractionsTab(),
    PharmacyTab(),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDCF8FC),
        title: Image.asset('assets/image/rafiq2.png', width: 80, height: 50),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
          // const SizedBox(width: 10),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
          const SizedBox(width: 20),
        ],
      ),
      body: _pages[currentIndex],
      drawer: Container(
        width: 200,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffDCF8FC), Color(0xFFFFFFFF)],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin:const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Color(0xFFD6F1FA),

            borderRadius: BorderRadius.circular(30)
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            backgroundColor: Color(0xFFD6F1FA),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            iconSize: 30,
            items: const[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.science),
                label: 'Interactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_pharmacy),
                label: 'Pharmacy',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
Widget _drawerItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
      Color color = Colors.black87,
    }) {
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(
      label,
      style: TextStyle(color: color, fontSize: 14),
    ),
    onTap: onTap,
    horizontalTitleGap: 8,
  );
}