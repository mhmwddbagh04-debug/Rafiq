import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return

      SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        spacing: 14,
        children: [
          _buildSayHi(),
          _buildImage('assets/image/right.png'),
          _buildSecHeader(),
          _buildDrugsList(),
          _buildImage('assets/image/left.png'),
          _buildSecHeader(),
          _buildDrugsList(),
        ],
      ),
    );
  }

  Widget _buildSayHi() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Hi, User',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSecHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Best selling drugs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        TextButton(onPressed: () {}, child: const Text('View all')),
      ],
    );
  }

  Widget _buildDrugsList() {
    final drugs = [
      {
        'name': 'Panadol Advance',
        'tabs': '24 Tab',
        'price': '60 EGP',
        'image': 'assets/image/pandol.png',
      },
      {
        'name': 'Panadol Advance',
        'tabs': '191 Tab',
        'price': '240 EGP',
        'image': 'assets/image/product2.png',
      },
      {
        'name': 'Limitless women',
        'tabs': '38 Tab',
        'price': '40 EGP',
        'image': 'assets/image/panadol2.png',
      }, {
        'name': 'Panadol Advance',
        'tabs': '24 Tab',
        'price': '60 EGP',
        'image': 'assets/image/pandol.png',
      },
      {
        'name': 'Panadol Advance',
        'tabs': '191 Tab',
        'price': '240 EGP',
        'image': 'assets/image/product2.png',
      },
      {
        'name': 'Limitless women',
        'tabs': '38 Tab',
        'price': '40 EGP',
        'image': 'assets/image/panadol2.png',
      },
    ];
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemBuilder: (context, index) {
          return _buildDrugsCard(drugs[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: drugs.length,
      ),
    );
  }

  Widget _buildDrugsCard(Map<String, String> drug) {
    return Container(
      padding: EdgeInsets.all(4),
      width: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(child: Image.asset(drug['image']!, fit: BoxFit.cover)),

          const SizedBox(height: 6),
          Text(
            drug['name']!,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis, ),
          ),
          Text(
            drug['tabs']!,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  drug['price']!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String img) {
    return Image.asset(img);
  }
}
