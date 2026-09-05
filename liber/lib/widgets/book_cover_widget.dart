import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class BookCoverWidget extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const BookCoverWidget({
    super.key,
    required this.book,
    this.onTap,
    this.width = 120,
    this.height = 160,
  });

  Color _genreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'fantasy': return const Color(0xFF4A7B6F);
      case 'sci-fi': return const Color(0xFF3D5A8A);
      case 'romance': return const Color(0xFF8A4A5A);
      case 'adventure': return const Color(0xFF7B5E3A);
      default: return const Color(0xFF6B7C47);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _genreColor(book.genre),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Book spine effect
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    book.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (book.progress > 0) ...[
                        LinearProgressIndicator(
                          value: book.progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          color: Colors.white,
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Genre badge
            Positioned(
              top: 10,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  book.genre,
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
