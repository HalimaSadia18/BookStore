import 'package:bookstore/home_screen.dart'; //homescreen se Book class import karein
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isBookInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkIfInWishlist();
  }

  // A helper function to get a user ID.
  // In a real app with authentication, you would get this from the user's login state.
  // For this example, we'll use a hardcoded value.
  String getUserId() {
    return 'temp_user_id';
  }

  // Check if the book is already in the wishlist
  Future<void> _checkIfInWishlist() async {
    final userId = getUserId();
    final wishlistDoc = FirebaseFirestore.instance
        .collection('wishlist')
        .doc(userId)
        .collection('items')
        .doc(widget.book.title);

    final docSnapshot = await wishlistDoc.get();
    if (docSnapshot.exists) {
      setState(() {
        _isBookInWishlist = true;
      });
    }
  }

  // A function to add/remove the book from the wishlist
  Future<void> _toggleWishlist() async {
    final userId = getUserId();
    final wishlistDoc = FirebaseFirestore.instance
        .collection('wishlist')
        .doc(userId)
        .collection('items')
        .doc(widget.book.title);

    if (_isBookInWishlist) {
      // Remove from wishlist
      await wishlistDoc.delete();
      setState(() {
        _isBookInWishlist = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.book.title} removed from wishlist!')),
      );
    } else {
      // Add to wishlist
      await wishlistDoc.set({
        'title': widget.book.title,
        'author': widget.book.author,
        'imageUrl': widget.book.imageUrl,
        'price': widget.book.price,
        'rating': widget.book.rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isBookInWishlist = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.book.title} added to wishlist!')),
      );
    }
  }

  // A function to handle adding a book to the cart
  Future<void> addToCart(BuildContext context) async {
    final userId = getUserId();
    final cartCollection = FirebaseFirestore.instance.collection('carts').doc(userId).collection('items');
    final bookInCartDoc = cartCollection.doc(widget.book.title); // Use book title as document ID for simplicity

    try {
      final docSnapshot = await bookInCartDoc.get();

      if (docSnapshot.exists) {
        // If the book is already in the cart, increment the quantity
        final currentQuantity = docSnapshot.data()?['quantity'] ?? 1;
        await bookInCartDoc.update({'quantity': currentQuantity + 1});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.book.title} quantity updated in cart!')),
        );
      } else {
        // If the book is not in the cart, add it with a quantity of 1
        await bookInCartDoc.set({
          'title': widget.book.title,
          'author': widget.book.author,
          'imageUrl': widget.book.imageUrl,
          'price': widget.book.price,
          'quantity': 1,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.book.title} added to cart!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add book to cart. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookInWishlist ? Icons.favorite : Icons.favorite_border,
              color: _isBookInWishlist ? Colors.red : Colors.black54,
            ),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.book.imageUrl,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        height: 300,
                        width: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                widget.book.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                widget.book.author,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.book.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            // --- Price and Add to Cart Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${widget.book.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    addToCart(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // --- Description Section ---
            const Text(
              'Description:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
