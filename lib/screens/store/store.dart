import 'package:flutter/material.dart';
import 'package:vac/assets/components/detailed_product_card.dart';
import 'package:vac/assets/dbTempInfo/product_db.dart';
import 'package:vac/assets/dbTypes/product_class.dart';

class Store extends StatelessWidget {
  final ProductRepository productRepository = ProductRepository();

  Store({super.key});

  @override
  Widget build(BuildContext context) {
    List<Product> products = productRepository.getProducts();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tienda',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const SearchBar(),
          const SizedBox(height: 20),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true, // Allow GridView to size itself based on content
            physics:
                const NeverScrollableScrollPhysics(), // Disable GridView's scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return DetailedProductCard(product: products[index]);
            },
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Buscar...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[300],
        suffixIcon: const Icon(Icons.tune),
      ),
    );
  }
}
