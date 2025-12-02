import 'package:flutter/material.dart';

class CarouselSection extends StatelessWidget {
  const CarouselSection();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> shoes = [
      {
        'title': 'Air Max Plus',
        'image':
            'https://assets.adidas.com/images/w_1880,f_auto,q_auto/dc9953df47e443a79524adc50177d71e_9366/GY5427_01_standard.jpg',
      },
      {
        'title': 'Nike Jordan',
        'image':
            'https://m.media-amazon.com/images/I/71UpvHftX6L._AC_SL1500_.jpg',
      },
      {
        'title': 'Adidas Ultra',
        'image':
            'https://assets.adidas.com/images/w_1880,f_auto,q_auto/4a46e180c40643c8b436af9c017a4615_9366/ID2054_01_standard.jpg',
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shoes.length,
            itemBuilder: (context, index) {
              final shoe = shoes[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        shoe['image']!,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, _, __) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(shoe['title']!),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
