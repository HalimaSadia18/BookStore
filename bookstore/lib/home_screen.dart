import 'package:bookstore/book_detail_screen.dart';
import 'package:bookstore/screen_categories.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      imageUrl: bookData['imageUrl'] as String? ?? 'https://placehold.co/150x200',
      category: bookData['category'] as String? ?? 'General',
      price: (bookData['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (bookData['originalPrice'] as num?)?.toDouble(),
      rating: (bookData['rating'] as num?)?.toDouble() ?? 0.0,
      description: bookData['description'] as String? ?? "No Description Available",
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // New state variables for search functionality
  List<Book> _allBooks = [];
  late Future<List<Book>> _filteredBooksFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch all books, populate the _allBooks list, and set the initial filtered list
    _fetchBooks().then((books) {
      setState(() {
        _allBooks = books;
        _filteredBooksFuture = Future.value(_allBooks);
      });
    });
    // Add a listener to the search controller to filter books as the user types
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBooks);
    _searchController.dispose();
    super.dispose();
  }

  // Method to fetch all books from Firestore
  Future<List<Book>> _fetchBooks() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('books').get();
      return querySnapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }

  // Method to filter books based on the search query
  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBooksFuture = Future.value(_allBooks);
      } else {
        final filteredList = _allBooks.where((book) {
          final titleLower = book.title.toLowerCase();
          final authorLower = book.author.toLowerCase();
          return titleLower.contains(query) || authorLower.contains(query);
        }).toList();
        _filteredBooksFuture = Future.value(filteredList);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already on Home page!')),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CategoriesScreen()),
      );
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart page tapped! (Implement navigation)')),
      );
    } else if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account page tapped! (Implement navigation)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile icon tapped!')),
              );
            },
            child: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        title: const Text(
          'E Book Store',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
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
                controller: _searchController, // Add controller here
                decoration: InputDecoration(
                  hintText: 'Search Books',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                ),
                // onChanged: (value) => _filterBooks(value), // Old way, now we use a listener
              ),
            ),

            // --- All Books Section (now uses filtered list) ---
            _buildSectionHeader(context, 'All Books'),
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: FutureBuilder<List<Book>>(
                future: _filteredBooksFuture, // Use the filtered list here
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No books found.'));
                  } else {
                    final books = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return _buildBookCard(context, book);
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

  Widget _buildBookCard(BuildContext context, Book book, {bool isDeal = false}) {
    return GestureDetector(
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
            Container(
              height: 150,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(book.imageUrl),
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
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
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
      ),
    );
  }
}