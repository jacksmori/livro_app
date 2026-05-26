import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/book_cover_widget.dart';
import 'book_config_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  List<Book> _results = [];
  List<Book> _all = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final books = await ApiService.getBooks();
    setState(() => _all = books);
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    setState(() {
      _searched = true;
      _results = _all
          .where((b) =>
              b.title.toLowerCase().contains(query.toLowerCase()) ||
              b.author.toLowerCase().contains(query.toLowerCase()) ||
              b.genre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header arc
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text('Pesquisa',
                          style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _search,
                    style: GoogleFonts.lato(color: text),
                    decoration: InputDecoration(
                      hintText: 'Buscar livros, autores...',
                      hintStyle: GoogleFonts.lato(color: secondary),
                      prefixIcon: Icon(Icons.search, color: secondary),
                      fillColor: surface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Actions (when no search)
            if (!_searched) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _ActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Adicionar Novo Livro',
                      primary: primary,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.favorite_outline,
                      label: 'Adicionar Aos Favoritos',
                      primary: primary,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Editar Capa Livro',
                      primary: primary,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
            // Search results
            if (_searched)
              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Text('Nenhum resultado encontrado',
                            style: GoogleFonts.lato(color: secondary)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (context, i) {
                          return BookCoverWidget(
                            book: _results[i],
                            width: double.infinity,
                            height: double.infinity,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        BookConfigScreen(book: _results[i]))),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.primary,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkCard : AppColors.lightCard;
    final text = isDark ? AppColors.darkText : AppColors.lightText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.lato(
                    color: text, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
