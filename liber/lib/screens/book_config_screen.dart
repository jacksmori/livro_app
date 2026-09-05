import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/book_cover_widget.dart';
import 'book_reader_screen.dart';

class BookConfigScreen extends StatefulWidget {
  final Book book;
  const BookConfigScreen({super.key, required this.book});

  @override
  State<BookConfigScreen> createState() => _BookConfigScreenState();
}

class _BookConfigScreenState extends State<BookConfigScreen> {
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
  }

  Future<void> _confirmDelete() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Excluir livro',
            style: GoogleFonts.playfairDisplay(
                color: text, fontWeight: FontWeight.bold)),
        content: Text(
          'Tem certeza que deseja excluir "${_book.title}"? Esta ação não pode ser desfeita.',
          style: GoogleFonts.lato(color: secondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: GoogleFonts.lato(color: secondary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Excluir',
                style: GoogleFonts.lato(
                    color: Colors.red[400], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.deleteBook(_book.id);
      if (!mounted) return;
      Navigator.pop(context, 'deleted'); // sinaliza que foi excluído
    }
  }

  Future<void> _toggleFavorite() async {
    await ApiService.toggleFavorite(_book.id);
    setState(() => _book = _book.copyWith(isFavorite: !_book.isFavorite));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header with book info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: text),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          _book.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: secondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book cover
                      SizedBox(
                        width: 100,
                        height: 140,
                        child: BookCoverWidget(
                          book: _book,
                          width: 100,
                          height: 140,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_book.title,
                                style: GoogleFonts.playfairDisplay(
                                    color: text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_book.author,
                                style: GoogleFonts.lato(
                                    color: secondary, fontSize: 13)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(_book.genre,
                                  style: GoogleFonts.lato(
                                      color: primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 14),
                            if (_book.progress > 0) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: _book.progress,
                                      backgroundColor:
                                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                      color: primary,
                                      minHeight: 5,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${(_book.progress * 100).toInt()}%',
                                      style: GoogleFonts.lato(
                                          color: secondary, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Progresso de leitura',
                                  style: GoogleFonts.lato(
                                      color: secondary, fontSize: 11)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ConfigButton(
                    icon: Icons.menu_book_rounded,
                    label: 'Ler Livro',
                    primary: primary,
                    card: card,
                    text: text,
                    isMain: true,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => BookReaderScreen(book: _book))),
                  ),
                  const SizedBox(height: 12),
                  _ConfigButton(
                    icon: _book.isFavorite ? Icons.favorite : Icons.favorite_border,
                    label: _book.isFavorite ? 'Remover Favorito' : 'Salvar a livros',
                    primary: primary,
                    card: card,
                    text: text,
                    onTap: _toggleFavorite,
                  ),
                  const SizedBox(height: 12),
                  _ConfigButton(
                    icon: Icons.bookmark_outline,
                    label: 'Anotações',
                    primary: primary,
                    card: card,
                    text: text,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  // Zona de perigo
                  Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  const SizedBox(height: 12),
                  _ConfigButton(
                    icon: Icons.delete_outline,
                    label: 'Excluir Livro',
                    primary: Colors.red[400]!,
                    card: Colors.red.withValues(alpha: isDark ? 0.12 : 0.07),
                    text: Colors.red[400]!,
                    onTap: _confirmDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;
  final Color card;
  final Color text;
  final bool isMain;
  final VoidCallback onTap;

  const _ConfigButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.card,
    required this.text,
    this.isMain = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isMain ? primary : card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: isMain ? Colors.white : primary, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.lato(
                  color: isMain ? Colors.white : text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
