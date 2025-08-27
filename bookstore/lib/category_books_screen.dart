import 'package:bookstore/book_detail_screen.dart';
import 'package:bookstore/home_screen.dart'; // To use the Book class
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryBooksScreen extends StatefulWidget {
  final String categoryName;

  const CategoryBooksScreen({super.key, required this.categoryName});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooksByCategory(widget.categoryName);
  }

  // Method to fetch books based on category
  Future<List<Book>> _fetchBooksByCategory(String categoryName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('category', isEqualTo: categoryName)
          .get();
      return querySnapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching books for category $categoryName: $e');
      return [];
    }
  }

  // Helper method to build a book card, same as in home_screen.dart
  Widget _buildBookCard(BuildContext context, Book book) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: book)
          )
        );
      },
      child : Container(
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
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books found in this category.'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Using the same card design as home screen to save code.
                      _buildBookCard(context, book),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}