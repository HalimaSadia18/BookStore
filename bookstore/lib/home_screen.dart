import 'package:bookstore/book_detail_screen.dart';
import 'package:bookstore/screen_categories.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookstore/CartScreen.dart';
import 'package:bookstore/home_screen.dart';
import 'package:bookstore/WishlistScreen.dart';
import 'OrderSuccessScreen.dart';

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
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBooks = [];
  List<Book> _latestBooks = [];
  List<Book> _upcomingBooks = [];
  List<Book> _topBooks = [];
  bool _isLoading = true;
  String _sortOption = 'none';
  @override
  void initState() {
    super.initState();
    _fetchAndFilterBooks();
    _searchController.addListener(_onSearchChanged);
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  void _onSearchChanged() {
    _filterBooks();
  }
  Future<void> _fetchAndFilterBooks() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('books').get();
      _allBooks = querySnapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
      _filterBooks(); // Initial filtering and sorting
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching books: $e');
      setState(() {
        _isLoading = false;
        // Optionally show an error message
      });
    }
  }
  void _filterBooks() {
    final searchQuery = _searchController.text.toLowerCase();
    // Filter books based on search query
    final filtered = _allBooks.where((book) {
      final titleMatch = book.title.toLowerCase().contains(searchQuery);
      final authorMatch = book.author.toLowerCase().contains(searchQuery);
      final categoryMatch = book.category.toLowerCase().contains(searchQuery);
      return titleMatch || authorMatch || categoryMatch;
    }).toList();
    // Apply sorting
    if (_sortOption == 'priceAsc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'priceDesc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    // Assign filtered and sorted lists to the different sections
    _latestBooks = filtered.where((book) => book.category == 'latest').toList();
    _latestBooks.sort((a, b) => b.title.compareTo(a.title));

    _upcomingBooks = filtered.where((book) => book.category == 'upcoming').toList();
    _upcomingBooks.sort((a, b) => a.title.compareTo(b.title));

    _topBooks = filtered.where((book) => book.rating > 4.0).toList();
    _topBooks.sort((a, b) => b.rating.compareTo(a.rating));

    // Fallback if the specific sections are empty, show all filtered books
    if (_latestBooks.isEmpty) _latestBooks = filtered;
    if (_upcomingBooks.isEmpty) _upcomingBooks = filtered;
    if (_topBooks.isEmpty) _topBooks = filtered;

    setState(() {});
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen(cartItems: [],)));
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account screen coming soon!')),
        );
        break;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Filter Books'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _sortOption = 'priceAsc';
                  _filterBooks();
                });
                Navigator.pop(context);
              },
              child: const Text('Price: Low to High'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _sortOption = 'priceDesc';
                  _filterBooks();
                });
                Navigator.pop(context);
              },
              child: const Text('Price: High to Low'),
            ),
          ],
        );
      },
    );
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
            icon: const Icon(Icons.favorite, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar and Filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterDialog,
                    ),
                  ),
                ],
              ),
            ),

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
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Latest Books Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Best Sellers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _latestBooks.length,
                itemBuilder: (context, index) {
                  return _buildCompactBookCard(context, _latestBooks[index]);
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
                    'New Arrivals',
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _upcomingBooks.length,
                itemBuilder: (context, index) {
                  return _buildCompactBookCard(context, _upcomingBooks[index]);
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