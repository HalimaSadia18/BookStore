import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bookstore/checkout_screen.dart'; // Import the CheckoutScreen



class CartScreen extends StatefulWidget {



  const CartScreen({super.key, required List cartItems});



  @override

  State<CartScreen> createState() => _CartScreenState();

}



class _CartScreenState extends State<CartScreen> {



  String getUserId() {

    return 'temp_user_id';

  }



// A function to remove a book from the cart

  Future<void> removeFromCart(String bookTitle) async {

    final userId = getUserId();

    final bookInCartDoc = FirebaseFirestore.instance

        .collection('carts')

        .doc(userId)

        .collection('items')

        .doc(bookTitle);



    try {

      await bookInCartDoc.delete();

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('$bookTitle removed from cart.')),

      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Failed to remove $bookTitle from cart.')),

      );

    }

  }



// A function to update the quantity of a book

  Future<void> updateQuantity(String bookTitle, int newQuantity) async {

    final userId = getUserId();

    final bookInCartDoc = FirebaseFirestore.instance

        .collection('carts')

        .doc(userId)

        .collection('items')

        .doc(bookTitle);



    if (newQuantity > 0) {

      await bookInCartDoc.update({'quantity': newQuantity});

    } else {

// If the new quantity is 0 or less, remove the item from the cart

      await removeFromCart(bookTitle);

    }

  }



  @override

  Widget build(BuildContext context) {

    final userId = getUserId();

    final cartItemsCollection = FirebaseFirestore.instance

        .collection('carts')

        .doc(userId)

        .collection('items');



    return Scaffold(

      appBar: AppBar(

        title: const Text(

          'My Cart',

          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),

        ),

        backgroundColor: Colors.white,

        elevation: 0,

        leading: IconButton(

          icon: const Icon(Icons.arrow_back, color: Colors.black),

          onPressed: () {

            Navigator.pop(context);

          },

        ),

      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: cartItemsCollection.snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {

            return const Center(child: CircularProgressIndicator());

          }

          if (snapshot.hasError) {

            return Center(child: Text('Error: ${snapshot.error}'));

          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

            return const Center(child: Text('Your cart is empty.'));

          }



          final cartItems = snapshot.data!.docs;

          double total = 0.0;

          for (var item in cartItems) {

            final data = item.data() as Map<String, dynamic>;

            total += (data['price'] as num) * (data['quantity'] as num);

          }



          return Column(

            children: [

              Expanded(

                child: ListView.builder(

                  itemCount: cartItems.length,

                  itemBuilder: (context, index) {

                    final item = cartItems[index];

                    final data = item.data() as Map<String, dynamic>;

                    final title = data['title'] as String;

                    final price = (data['price'] as num).toDouble();

                    final quantity = (data['quantity'] as num).toInt();

                    final imageUrl = data['imageUrl'] as String;



                    return Card(

                      elevation: 4,

                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(12),

                      ),

                      child: Padding(

                        padding: const EdgeInsets.all(16.0),

                        child: Row(

                          children: [

                            Container(

                              width: 80,

                              height: 100,

                              decoration: BoxDecoration(

                                borderRadius: BorderRadius.circular(8),

                                image: DecorationImage(

                                  image: NetworkImage(imageUrl),

                                  fit: BoxFit.cover,

                                ),

                              ),

                            ),

                            const SizedBox(width: 16),

                            Expanded(

                              child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  Text(

                                    title,

                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),

                                  ),

                                  const SizedBox(height: 4),

                                  Text(

                                    '\$${price.toStringAsFixed(2)}',

                                    style: const TextStyle(

                                      color: Color(0xFF2196F3), // A nicer blue

                                      fontSize: 16,

                                      fontWeight: FontWeight.w600,

                                    ),

                                  ),

                                  const SizedBox(height: 8),

                                  Row(

                                    children: [

                                      GestureDetector(

                                        onTap: () => updateQuantity(title, quantity - 1),

                                        child: Container(

                                          padding: const EdgeInsets.all(4),

                                          decoration: BoxDecoration(

                                            color: Colors.grey[200],

                                            borderRadius: BorderRadius.circular(8),

                                          ),

                                          child: const Icon(Icons.remove, size: 20),

                                        ),

                                      ),

                                      Padding(

                                        padding: const EdgeInsets.symmetric(horizontal: 12),

                                        child: Text(

                                          '$quantity',

                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),

                                        ),

                                      ),

                                      GestureDetector(

                                        onTap: () => updateQuantity(title, quantity + 1),

                                        child: Container(

                                          padding: const EdgeInsets.all(4),

                                          decoration: BoxDecoration(

                                            color: Colors.grey[200],

                                            borderRadius: BorderRadius.circular(8),

                                          ),

                                          child: const Icon(Icons.add, size: 20),

                                        ),

                                      ),

                                    ],

                                  ),

                                ],

                              ),

                            ),

                            IconButton(

                              icon: const Icon(Icons.delete, color: Colors.redAccent),

                              onPressed: () => removeFromCart(title),

                            ),

                          ],

                        ),

                      ),

                    );

                  },

                ),

              ),

              Container(

                decoration: const BoxDecoration(

                  color: Colors.white,

                  boxShadow: [

                    BoxShadow(

                      color: Colors.black12,

                      blurRadius: 10,

                      offset: Offset(0, -5),

                    ),

                  ],

                ),

                padding: const EdgeInsets.all(24.0),

                child: Column(

                  children: [

                    Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [

                        const Text(

                          'Total:',

                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

                        ),

                        Text(

                          '\$${total.toStringAsFixed(2)}',

                          style: const TextStyle(

                            fontSize: 22,

                            fontWeight: FontWeight.bold,

                            color: Color(0xFF2196F3), // A nicer blue

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height: 16),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed: () {

                          if (total > 0) {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (context) => CheckoutScreen(totalPrice: total),

                              ),

                            );

                          } else {

                            ScaffoldMessenger.of(context).showSnackBar(

                              const SnackBar(content: Text('Your cart is empty. Please add items to proceed.')),

                            );

                          }

                        },

                        style: ElevatedButton.styleFrom(

                          backgroundColor: const Color(0xFF000000), // A nicer blue

                          foregroundColor: Colors.white,

                          padding: const EdgeInsets.symmetric(vertical: 15),

                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(12),

                          ),

                          elevation: 5,

                        ),

                        child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                      ),

                    ),

                  ],

                ),

              ),

            ],

          );

        },

      ),

    );

  }

}