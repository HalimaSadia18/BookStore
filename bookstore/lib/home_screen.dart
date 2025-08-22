import 'package:bookstore/screen_categories.dart';
import 'package:flutter/material.dart';


// Dummy data for books to populate the UI
class Book {
  final String title;
  final String author;
  final String imageUrl;
  final String category;
  final double price;
  final double? originalPrice; // For best deals
  final double rating;
  final String description;


  Book({
    required this.title,
    required this.author,
    required this.imageUrl,
    this.category = 'General',
    required this.price,
    this.originalPrice,
    this.rating = 0.0,
    this.description = "No Description Available"
  });
}

// Dummy data for categories (still useful for general data but not displayed as a primary section here)
class Category {
  final String name;
  final String imageUrl;

  Category({required this.name, required this.imageUrl});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // State for bottom navigation bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) { // Home icon tapped
      // Already on Home, or handle a refresh/pop to root of home stack
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already on Home page!')),
      );
    } else if (index == 1) { // Categories icon tapped
      // Navigate to CategoriesScreen
      Navigator.pushReplacement( // Use pushReplacement to replace the current screen
        context,
        MaterialPageRoute(builder: (context) => const CategoriesScreen()),
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

  // Sample book data for "Best Deals"
  final List<Book> bestDeals = [
    Book(
      title: 'The Silent Patient',
      author: 'Alex Michaelides',
      imageUrl: 'https://placehold.co/100x150/e0e0e0/000000?text=Book+1',
      category: 'Thriller',
      price: 12.99,
      originalPrice: 19.99,
      rating: 4.5,
      description: 'A psychological thriller about Alicia, a woman who murders her husband and then stops speaking forever. A psychotherapist becomes obsessed with uncovering the truth behind her silence.'
    ),
    Book(
      title: 'Where the Crawdads Sing',
      author: 'Delia Owens',
      imageUrl: 'https://placehold.co/100x150/e0e0e0/000000?text=Book+2',
      category: 'Mystery',
      price: 10.50,
      originalPrice: 16.00,
      rating: 4.7,
      description: 'Set in the marshes of North Carolina, it follows Kya, a girl abandoned by her family. Her story intertwines with a local murder mystery and themes of survival and love.'
    ),
    Book(
      title: 'Project Hail Mary',
      author: 'Andy Weir',
      imageUrl: 'https://placehold.co/100x150/e0e0e0/000000?text=Book+3',
      category: 'Science Fiction',
      price: 14.99,
      originalPrice: 22.99,
      rating: 4.8,
      description: 'A lone astronaut awakens on a spaceship with no memory. He must save humanity from extinction while uncovering why he was chosen.'
    ),
  ];

  // Sample book data for "Top Books" (new section)
  final List<Book> bestSellers = [
    Book(
      title: 'Atomic Habits',
      author: 'James Clear',
      imageUrl: 'https://placehold.co/100x150/d0d0d0/000000?text=Top+1',
      category: 'Personal Development',
      price: 15.00,
      rating: 4.9,
      description: 'A practical guide to building better habits and breaking bad ones. Shows how small daily changes lead to big life transformations.'
    ),
    Book(
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      imageUrl: 'https://placehold.co/100x150/d0d0d0/000000?text=Top+2',
      category: 'Philosophical Fiction',
      price: 9.00,
      rating: 4.7,
      description: 'A shepherd named Santiago follows his dream of finding treasure. Along the way, he discovers lessons about destiny, love, and purpose.'
    ),
    Book(
      title: 'Dune',
      author: 'Frank Herbert',
      imageUrl: 'https://placehold.co/100x150/d0d0d0/000000?text=Top+3',
      category: 'Science Fiction',
      price: 13.75,
      rating: 4.8,
      description: 'On the desert planet Arrakis, young Paul Atreides faces betrayal and destiny. A tale of politics, religion, ecology, and power struggles.'
    ),
  ];


  // Sample book data for "Latest Books"
  final List<Book> newArrivals = [
    Book(
      title: 'The Midnight Library',
      author: 'Matt Haig',
      imageUrl: 'https://placehold.co/100x150/b0b0b0/000000?text=Latest+1',
      category: 'Fantasy',
      price: 11.00,
      rating: 4.6,
      description: 'Nora discovers a magical library that lets her live alternate versions of her life. She explores regret, choices, and the meaning of happiness.'
    ),
    Book(
      title: 'Circe',
      author: 'Madeline Miller',
      imageUrl: 'https://placehold.co/100x150/b0b0b0/000000?text=Latest+2',
      category: 'Fantasy',
      price: 9.75,
      rating: 4.7,
      description: 'A retelling of the life of Circe, the witch from Greek mythology. It explores her struggles, powers, and defiance against gods and men.'
    ),
    Book(
      title: 'The Four Winds',
      author: 'Kristin Hannah',
      imageUrl: 'https://placehold.co/100x150/b0b0b0/000000?text=Latest+3',
      category: 'Drama',
      price: 13.50,
      rating: 4.5,
      description: 'Set during the Great Depression, it follows Elsa as she battles poverty, drought, and survival. A story of resilience, family, and hope.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Left side: User Avatar
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile icon tapped!')),
              );
            },
            child: const CircleAvatar(
              backgroundColor: Colors.blueGrey, // Placeholder for user avatar
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        title: const Text(
          'Happy Reading!', // Title as seen in Figma
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false, // Align title to the left
        actions: [
          // Right side: Filter Icon
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter icon tapped!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Allows the content to scroll if it exceeds screen height
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search Bar Section ---
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search books',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                ),
                onSubmitted: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for: $value')),
                  );
                },
              ),
            ),

            // --- Best Deals Section ---
            _buildSectionHeader(context, 'Best Deals'),
            const SizedBox(height: 10),
            SizedBox(
              height: 220, // Height for the horizontal list of best deals
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bestDeals.length,
                itemBuilder: (context, index) {
                  final book = bestDeals[index];
                  return _buildBookCard(context, book, isDeal: true);
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- Top Books Section (New) ---
            _buildSectionHeader(context, 'Best Sellers'),
            const SizedBox(height: 10),
            SizedBox(
              height: 200, // Height for the horizontal list of top books
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bestSellers.length,
                itemBuilder: (context, index) {
                  final book = bestSellers[index];
                  return _buildBookCard(context, book);
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- Latest Books Section ---
            _buildSectionHeader(context, 'New Arrivals'),
            const SizedBox(height: 10),
            SizedBox(
              height: 200, // Height for the horizontal list of latest books
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newArrivals.length,
                itemBuilder: (context, index) {
                  final book = newArrivals[index];
                  return _buildBookCard(context, book);
                },
              ),
            ),
            const SizedBox(height: 20),
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
            icon: Icon(Icons.category), // Changed icon
            label: 'Categories', // Changed label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), // Changed icon
            label: 'Cart', // Changed label
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
        type: BottomNavigationBarType.fixed, // Ensures all labels are shown
      ),
    );
  }

  // Helper widget to build section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            // Handle "See All" tap
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('See All $title tapped!')),
            );
          },
          child: const Text(
            'See All',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // Helper widget to build a book card
  Widget _buildBookCard(BuildContext context, Book book, {bool isDeal = false}) {
    return Container(
      width: 120, // Width of each book card
      margin: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Image
          Container(
            height: 150, // Height of the book cover image
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(book.imageUrl), // Using placeholder images
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Book Title
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          // Book Author
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          // Price and (optional) original price for deals
          if (isDeal && book.originalPrice != null)
            Row(
              children: [
                Text(
                  '\$${book.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '\$${book.originalPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            )
          else
            Text(
              '\$${book.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          // Optional: Rating for books, if available
          if (book.rating > 0)
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  book.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
