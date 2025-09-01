import 'package:bookstore/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isBookInWishlist = false;
  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 0.0;
  final String _userId = 'temp_user_id'; // Placeholder for the current user ID

  @override
  void initState() {
    super.initState();
    _checkIfInWishlist();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // Check if the book is already in the wishlist
  Future<void> _checkIfInWishlist() async {
    final wishlistDoc = FirebaseFirestore.instance
        .collection('wishlists')
        .doc(_userId)
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
    final wishlistDoc = FirebaseFirestore.instance
        .collection('wishlists')
        .doc(_userId)
        .collection('items')
        .doc(widget.book.title);

    if (_isBookInWishlist) {
      await wishlistDoc.delete();
      setState(() {
        _isBookInWishlist = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.book.title} removed from wishlist!')),
      );
    } else {
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
    final cartCollection = FirebaseFirestore.instance.collection('carts').doc(_userId).collection('items');
    final bookInCartDoc = cartCollection.doc(widget.book.title);

    try {
      final docSnapshot = await bookInCartDoc.get();
      if (docSnapshot.exists) {
        final currentQuantity = docSnapshot.data()?['quantity'] ?? 1;
        await bookInCartDoc.update({'quantity': currentQuantity + 1});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.book.title} quantity updated in cart!')),
        );
      } else {
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

  // Method to submit a new review
  Future<void> _submitReview() async {
    if (_userRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating.')),
      );
      return;
    }

    final reviewText = _reviewController.text.trim();
    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'bookTitle': widget.book.title,
        'userId': _userId,
        'rating': _userRating,
        'reviewText': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'likedBy': [],
      });

      _reviewController.clear();
      setState(() {
        _userRating = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review. Please try again.')),
      );
    }
  }

  // Method to toggle a like on a review
  Future<void> _toggleLike(String reviewId, List<dynamic> likedBy) async {
    final reviewRef = FirebaseFirestore.instance.collection('reviews').doc(reviewId);

    // Use a transaction to prevent race conditions
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final reviewDoc = await transaction.get(reviewRef);
      if (!reviewDoc.exists) {
        throw Exception("Review does not exist!");
      }

      int newLikesCount = reviewDoc.data()!['likesCount'] as int;
      List<dynamic> newLikedBy = List.from(reviewDoc.data()!['likedBy'] ?? []);

      if (newLikedBy.contains(_userId)) {
        // User already liked, so unlike
        newLikesCount--;
        newLikedBy.remove(_userId);
      } else {
        // User has not liked, so like
        newLikesCount++;
        newLikedBy.add(_userId);
      }

      transaction.update(reviewRef, {
        'likesCount': newLikesCount,
        'likedBy': newLikedBy,
      });
    }).catchError((e) {
      print("Failed to update like count: $e");
    });
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
            // --- Review Section ---
            const Text(
              'Ratings & Reviews:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Review Submission Form
            _buildReviewList(),
            const SizedBox(height: 20),
            // Review List
            _buildReviewForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        RatingBar.builder(
          initialRating: _userRating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 28.0,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _userRating = rating;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reviewController,
          decoration: InputDecoration(
            hintText: 'Write your review here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Submit Review'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('bookTitle', isEqualTo: widget.book.title)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No reviews yet. Be the first to review!'));
        }

        final reviews = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index].data() as Map<String, dynamic>;
            final reviewId = reviews[index].id;
            final likedBy = review['likedBy'] as List<dynamic>? ?? [];
            final bool isLikedByMe = likedBy.contains(_userId);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'User: ${review['userId']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        RatingBarIndicator(
                          rating: (review['rating'] as num?)?.toDouble() ?? 0.0,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(review['reviewText']),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${review['likesCount'] ?? 0}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        IconButton(
                          icon: Icon(
                            isLikedByMe ? Icons.favorite : Icons.favorite_border,
                            color: isLikedByMe ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleLike(reviewId, likedBy),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}