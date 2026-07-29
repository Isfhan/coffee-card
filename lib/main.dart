import 'package:flutter/material.dart';

void main() {
  runApp(const CoffeeCardApp());
}

class CoffeeCardApp extends StatelessWidget {
  const CoffeeCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // App bar of the app
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            'Coffee Card',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          actions: [
            IconButton(
              onPressed: () {
                print('Settings icon pressed');
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),

        // Body of the app
        body: Container(
          color: Colors.black12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [Text('1')]),
              Column(children: [Text('2')]),
              Column(children: [Text('3')]),
            ],
          ),
        ),

        // Bottom navigation bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
