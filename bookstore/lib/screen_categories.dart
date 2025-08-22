import 'package:bookstore/home_screen.dart';
import 'package:flutter/material.dart';

// Dummy data for categories
class Category {
  final String name;
  final String imageUrl;

  Category({required this.name, required this.imageUrl});
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // We'll use this for the Bottom Navigation Bar, assuming 'Categories' is the second item (index 1)
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) { // Home icon tapped
      Navigator.pushReplacement( // Use pushReplacement to replace the current screen
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

  // Sample category data matching the Figma design
  final List<Category> categories = [
    // Category(name: 'Non-fiction', imageUrl: 'https://placehold.co/150x100/e0e0e0/000000?text=Non-fiction'),
    // Category(name: 'Classics', imageUrl: 'https://placehold.co/150x100/d0d0d0/000000?text=Classics'),
    Category(name: 'Fantasy', imageUrl: 'https://placehold.co/150x100/c0c0c0/000000?text=Fantasy'),
    // Category(name: 'Young Adult', imageUrl: 'https://placehold.co/150x100/b0b0b0/000000?text=YA'),
    Category(name: 'Crime', imageUrl: 'https://placehold.co/150x100/a0a0a0/000000?text=Crime'),
    Category(name: 'Horror', imageUrl: 'https://placehold.co/150x100/909090/000000?text=Horror'),
    // Category(name: 'Sci-fi', imageUrl: 'https://placehold.co/150x100/808080/000000?text=Sci-fi'),
    Category(name: 'Drama', imageUrl: 'https://placehold.co/150x100/707070/000000?text=Drama'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensure a white background as per Figma
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90, // Adjust height to accommodate search bar
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 8.0, left: 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            children: [
              // Search Bar
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search title/author',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                    onSubmitted: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Searching for: $value')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Filter Icon
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter icon tapped!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            // Grid of Categories
            GridView.builder(
              shrinkWrap: true, // Allows the grid to take only necessary height
              physics: const NeverScrollableScrollPhysics(), // Disables grid scrolling, handled by SingleChildScrollView
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two items per row
                crossAxisSpacing: 16.0, // Horizontal spacing between items
                mainAxisSpacing: 16.0, // Vertical spacing between items
                childAspectRatio: 1.5, // Aspect ratio of each grid item (width / height)
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${category.name} category tapped!')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Background of the card
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Shadow effect
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(category.imageUrl), // Placeholder image
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken), // Darken image for text readability
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category), // Changed icon for Categories
            label: 'Categories', // Label for Categories
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account', // Changed label to Account as per new Figma
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all labels are shown
      ),
    );
  }
}
