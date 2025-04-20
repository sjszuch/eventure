import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventure', style: TextStyle(fontFamily: 'Poppins')),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: Text(
                'Event Name',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              subtitle: Text(
                'Event Date',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              trailing: Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          // Home
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          // Search
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          // Create
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          // Saved
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          // Profile
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}
