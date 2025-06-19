
import 'package:asset/screens/qr_display_screen.dart';
import 'package:asset/screens/qr_scanner_windows.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asset/create.dart';
import 'package:asset/fetch.dart';
import 'package:asset/screens/fetch_rentals.dart';
import 'package:asset/providers/auth_provider.dart';

//import 'package:asset/screens/qr_display_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FetchDataScreen(),
    CreateData(),
    FetchRentalScreen(),
  ];

  final List<String> _titles = [
    'Materials',
    'Add Material',
    'Rentals',
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<AuthProvider>(context).themeMode;

    // Prevent out-of-range index errors
    if (_currentIndex >= _screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Add your notification logic here
                },
              ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          )
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text('Welcome!', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Materials'),
              onTap: () => setState(() => _currentIndex = 0),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Material'),
              onTap: () => setState(() => _currentIndex = 1),
            ),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text('Rentals'),
              onTap: () => setState(() => _currentIndex = 2),
            ),
           ListTile(
              leading: const Icon(Icons.qr_code),
               title: const Text('Show QR Code'),
                  onTap: () {
                 Navigator.pop(context); // Close the drawer
                 Navigator.push(
                 context,
                MaterialPageRoute(
               builder: (_) => const QRDisplayScreen(),
                 ),
               );
              },
               ),
               
                ListTile(
              leading: const Icon(Icons.qr_code),
               title: const Text(' QR Code scanner'),
                  onTap: () {
                 Navigator.pop(context); // Close the drawer
                Navigator.push(
                    context,
                  MaterialPageRoute(builder: (context) =>  QRScannerWindows()),
                        );

              },
               ),
            const Divider(),
            SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: const Icon(Icons.brightness_6),
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                Provider.of<AuthProvider>(context, listen: false).toggleTheme(val); // ✅ Fixed
              },
            ),
          ],
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),

      bottomNavigationBar: NavigationBar(
        height: 65,
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).bottomAppBarTheme.color ?? Colors.white, // ✅ Fixed
        elevation: 4,
        indicatorColor: Colors.teal.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Materials',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Rentals',
          ),
        ],
      ),
    );
  }
}
