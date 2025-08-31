import 'package:bookstore/CartScreen.dart';
import 'package:flutter/material.dart';
import 'package:bookstore/category_books_screen.dart';
import 'package:bookstore/home_screen.dart';

// Dummy data for categories with image URLs
class Category {
  final String name;
  final String imagePath;

  Category({required this.name, required this.imagePath});
}

final List<Category> allCategories = [
  Category(name: 'Non-fiction', imagePath: 'assets/images/category.png'),
  Category(name: 'Classics', imagePath: 'assets/images/category.png'),
  Category(name: 'Fantasy', imagePath: 'assets/images/category.png'),
  Category(name: 'Young Adult', imagePath: 'assets/images/category.png'),
  Category(name: 'Crime', imagePath: 'assets/images/category.png'),
  Category(name: 'Horror', imagePath: 'assets/images/category.png'),
  Category(name: 'Literature', imagePath: 'assets/images/category.png'),
  Category(name: 'Drama', imagePath: 'assets/images/category.png'),
];

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  List<Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = allCategories;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    filterCategories();
  }

  void filterCategories() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = allCategories.where((category) {
        return category.name.toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch(index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen(cartItems: [])));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen(cartItems: [],)));
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account screen coming soon!')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSearchBar(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: _filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = _filteredCategories[index];
                  return _buildCategoryCard(context, category);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Category',
                border: InputBorder.none,
              ),
            ),
          ),
          // The filter button functionality is not implemented as per the original code.
          // You can add a filter dialog here if you need more advanced sorting.

        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryBooksScreen(categoryName: category.name),
          ),
        );
      },
      child: Container(
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
                child: Image.asset(
                  category.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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