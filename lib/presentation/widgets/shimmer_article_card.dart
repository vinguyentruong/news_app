// lib/presentation/widgets/shimmer_article_card.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerArticleCard extends StatelessWidget {
  const ShimmerArticleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2A2A2A),
      highlightColor: const Color(0xFF3A3A3A),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: const Color(0xFF2A2A2A)),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(60, 10),
                  const SizedBox(height: 10),
                  _bar(double.infinity, 16),
                  const SizedBox(height: 6),
                  _bar(double.infinity, 16),
                  const SizedBox(height: 6),
                  _bar(200, 16),
                  const SizedBox(height: 10),
                  _bar(double.infinity, 12),
                  const SizedBox(height: 4),
                  _bar(160, 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
