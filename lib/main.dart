import 'package:flutter/material.dart';
import 'profile.dart' as profile;
import 'recipes.dart';
import 'shopping_cart.dart';
import 'storage.dart';
import 'colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        
        scaffoldBackgroundColor: Color(0xFF33658A), // Deep blue background
        primaryColor: C.orange, // Warm orange as the primary color

       
        appBarTheme: AppBarTheme(
          backgroundColor:
              Color(0xFF33658A), // App bar blends with the background  
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        textTheme: TextTheme(
          bodyLarge: TextStyle(
          ),
          bodyMedium: TextStyle(
              color: Colors.white), // Standard text stays white for contrast
        ),

        buttonTheme: ButtonThemeData(
          buttonColor: C.orange, // Orange buttons for contrast
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  Widget page = ShoppingCart();

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;

      switch (selectedIndex) {
        case 0:
          page = ShoppingCart();
        case 1:
          page = Storage();
        case 2:
          page = Recipies();
        case 3:
          page = profile.Profile();
        default:
          page = ShoppingCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
         Row(
          children: [
            Expanded(child: page),
          ],
        ),
      
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: C.blue, 
          selectedItemColor: C.orange, 
          unselectedItemColor: Colors.grey, 
        showSelectedLabels: true, 
        showUnselectedLabels:true,
           iconSize: 25,
        items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 30.0),
            child: Icon(Icons.shopping_cart),
          ),
          label: 'List',
        ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Storage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
