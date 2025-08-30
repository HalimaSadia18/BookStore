import 'package:bookstore/book_detail_screen.dart';
import 'package:bookstore/screen_categories.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookstore/CartScreen.dart';
import 'package:bookstore/home_screen.dart';
import 'package:bookstore/WishlistScreen.dart'; // Import the new wishlist screen

import 'OrderSuccessScreen.dart';
// import 'package:bookstore/order_success_screen.dart';

// Your existing Book and Category classes are fine.
class Category {
  final String name;
  final String imageUrl;

  Category({required this.name, required this.imageUrl});
}

class Book {
  final String title;
  final String author;
  final String imageUrl;
  final String category;
  final double price;
  final double? originalPrice;
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

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('A document with null data was found.');
    }

    final bookData = data as Map<String, dynamic>;

    return Book(
      title: bookData['title'] as String? ?? 'Unknown Title',
      author: bookData['author'] as String? ?? 'Unknown Author',
      imageUrl: bookData['imageUrl'] as String? ?? '',
      category: bookData['category'] as String? ?? 'General',
      price: (bookData['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (bookData['originalPrice'] as num?)?.toDouble(),
      rating: (bookData['rating'] as num?)?.toDouble() ?? 0.0,
      description: bookData['description'] as String? ?? 'No Description Available',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required List cartItems});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Book>> _latestBooksFuture;
  late Future<List<Book>> _upcomingBooksFuture;
  late Future<List<Book>> _topBooksFuture;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _latestBooksFuture = _fetchBooks('latest');
    _upcomingBooksFuture = _fetchBooks('upcoming');
    _topBooksFuture = _fetchBooks('top_books');
  }

  Future<List<Book>> _fetchBooks(String type) async {
    try {
      Query query = FirebaseFirestore.instance.collection('books');

      switch (type) {
        case 'latest':
          final querySnapshot = await query.get();
          final books = querySnapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
          books.sort((a, b) => b.title.compareTo(a.title));
          return books;
        case 'upcoming':
          query = query.where('is_upcoming', isEqualTo: true);
          break;
        case 'top_books':
          final querySnapshot = await query.get();
          final books = querySnapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
          books.sort((a, b) => b.rating.compareTo(a.rating));
          return books;
        default:
          break;
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching books for $type: $e');
      return [];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch(index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen(cartItems: [],)));
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account screen coming soon!')),
        );
        break;
    }
  }

  Widget _buildCompactBookCard(BuildContext context, Book book) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(book: book),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.imageUrl,
                height: 160,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      height: 160,
                      width: 120,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    height: 160,
                    width: 120,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              book.author,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '\$${book.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Happy Reading!', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Replaced Best Deals with a simple image and quote section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/shelf.jpg',
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.4),
                      ),
                      // const Text(
                      //   '"A book is a gift you can open again and again."',
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 20,
                      //     fontStyle: FontStyle.italic,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Top Books Section
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       const Text(
            //         'Top Books',
            //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //       ),
            //       TextButton(
            //         onPressed: () {},
            //         child: const Text('See more'),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Row(
            //     children: [
            //       ElevatedButton(onPressed: () {}, child: const Text('This Week')),
            //       const SizedBox(width: 8),
            //       ElevatedButton(onPressed: () {}, child: const Text('This Month')),
            //       const SizedBox(width: 8),
            //       ElevatedButton(onPressed: () {}, child: const Text('This Year')),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 16),
            // SizedBox(
            //   height: 250,
            //   child: FutureBuilder<List<Book>>(
            //     future: _topBooksFuture,
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Center(child: CircularProgressIndicator());
            //       } else if (snapshot.hasError) {
            //         return Center(child: Text('Error: ${snapshot.error}'));
            //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //         return const Center(child: Text('No top books found.'));
            //       } else {
            //         final books = snapshot.data!;
            //         return ListView.builder(
            //           scrollDirection: Axis.horizontal,
            //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //           itemCount: books.length,
            //           itemBuilder: (context, index) {
            //             return _buildCompactBookCard(context, books[index]);
            //           },
            //         );
            //       }
            //     },
            //   ),
            // ),
            // const SizedBox(height: 20),

            // Latest Books Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Latest Books',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.push(context, MaterialPageRoute(builder: (context) => OrderSuccessScreen()));
                  //   },
                  //   child: const Text('Go to Order Success Screen'),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: FutureBuilder<List<Book>>(
                future: _latestBooksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No latest books found.'));
                  } else {
                    final books = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return _buildCompactBookCard(context, books[index]);
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Upcoming Books Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Books',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See more'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: FutureBuilder<List<Book>>(
                future: _upcomingBooksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No upcoming books found.'));
                  } else {
                    final books = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return _buildCompactBookCard(context, books[index]);
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
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
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
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
}
