import 'package:flutter/material.dart';
import 'package:bookstore/category_books_screen.dart';
import 'package:bookstore/home_screen.dart';

// Dummy data for categories with image URLs
class Category {
  final String name;
  final String imagePath;

  Category({required this.name, required this.imagePath});
}

final List<Category> categories = [
  Category(name: 'drama', imagePath: 'assets/images/category.png'),
  Category(name: 'Literature', imagePath: 'assets/images/category.png'),
  Category(name: 'Fantasy', imagePath: 'assets/images/category.png'),
  Category(name: 'Horror', imagePath: 'assets/images/category.png'),
];

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) { // Home icon tapped
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) { // Categories icon tapped
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already on Categories Screen!')),
      );
    } else if (index == 2) { // Cart icon tapped
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart page tapped! (Implement navigation)')),
      );
    } else if (index == 3) { // Account icon tapped
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account page tapped! (Implement navigation)')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(context, category);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Helper widget to build the category card
  Widget _buildCategoryCard(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryBooksScreen(categoryName: category.name),
          ),
        );
      },
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset( // Image.asset is for PNG, JPG, etc.
                  category.imagePath,
                  fit: BoxFit.cover,
                  // colorFilter: ColorFilter.mode(
                  //   Colors.black.withOpacity(0.4),
                  //   BlendMode.darken,
                  // ),
                ),
              ),
            ),
            Center(
              child: Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}