import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/book_cover_widget.dart';
import 'search_screen.dart';
import 'book_reader_screen.dart';
import 'book_config_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Book> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await ApiService.getBooks();
    setState(() {
      _books = books;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration:
                        BoxDecoration(color: primary, shape: BoxShape.circle),
                    child: const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Consumer<ThemeProvider>(
                    builder: (context, tp, _) => IconButton(
                      icon: Icon(
                        tp.isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: secondary,
                      ),
                      onPressed: tp.toggleTheme,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: secondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _currentIndex == 0
                      ? _buildHomeContent(
                          isDark, primary, bg, surface, text, secondary)
                      : _buildFavoritesContent(
                          isDark, primary, text, secondary),
            ),
          ],
        ),
      ),
      // FAB
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: primary,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(isDark, primary, surface, secondary),
    );
  }

  Widget _buildHomeContent(bool isDark, Color primary, Color bg, Color surface,
      Color text, Color secondary) {
    final recent = _books.where((b) => b.progress > 0).toList();
    final all = _books;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Histórico section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Histórico',
                    style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Books grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: all.length,
            itemBuilder: (context, i) {
              final book = all[i];
              return BookCoverWidget(
                book: book,
                width: double.infinity,
                height: double.infinity,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BookConfigScreen(book: book)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent(
      bool isDark, Color primary, Color text, Color secondary) {
    final favs = _books.where((b) => b.isFavorite).toList();
    if (favs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: secondary),
            const SizedBox(height: 16),
            Text('Nenhum favorito ainda',
                style: GoogleFonts.lato(color: secondary, fontSize: 16)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: favs.length,
      itemBuilder: (context, i) {
        return BookCoverWidget(
          book: favs[i],
          width: double.infinity,
          height: double.infinity,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BookConfigScreen(book: favs[i]))),
        );
      },
    );
  }

  Widget _buildBottomNav(
      bool isDark, Color primary, Color surface, Color secondary) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primary,
        unselectedItemColor: secondary,
        selectedLabelStyle:
            GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.lato(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Pesquisa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'Favoritos'),
        ],
      ),
    );
  }
}
