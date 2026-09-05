import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/book_cover_widget.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  String _selectedGenre = 'Fantasy';
  bool _loading = false;
  File? _selectedEpub;
  String? _epubFileName;

  final List<String> _genres = [
    'Fantasy',
    'Sci-Fi',
    'Romance',
    'Adventure',
    'Mystery',
    'Drama',
    'Horror',
    'Biography',
    'General',
  ];

  Book get _preview => Book(
        id: 0,
        title: _titleCtrl.text.isEmpty ? 'Título do Livro' : _titleCtrl.text,
        author: _authorCtrl.text.isEmpty ? 'Autor' : _authorCtrl.text,
        coverUrl: '',
        epubPath: _epubFileName ?? '',
        genre: _selectedGenre,
        isFavorite: false,
        progress: 0.0,
      );

  Future<void> _pickEpub() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        if (result.files.single.path != null) {
          _selectedEpub = File(result.files.single.path!);
        }
        _epubFileName = result.files.single.name;
      });
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showError('O título é obrigatório');
      return;
    }
    if (_authorCtrl.text.trim().isEmpty) {
      _showError('O autor é obrigatório');
      return;
    }

    if (_selectedEpub == null) {
      _showError('Por favor, selecione o arquivo .epub do livro');
      return;
    }

    setState(() => _loading = true);

    final serverEpubPath = await ApiService.uploadEpub(_selectedEpub!);
    if (serverEpubPath == null) {
      setState(() => _loading = false);
      _showError('Falha ao enviar o arquivo. Tente novamente.');
      return;
    }

    final book = await ApiService.addBook(
      title: _titleCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      genre: _selectedGenre,
      epubPath: serverEpubPath,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (book != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Livro "${book.title}" adicionado!',
              style: GoogleFonts.lato()),
          backgroundColor: AppColors.lightPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, book);
    } else {
      _showError('Erro ao salvar. Tente novamente.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg, style: GoogleFonts.lato()),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
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
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 16, 20, 24),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text('Adicionar Livro',
                          style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Preview da capa
                  Center(
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation:
                              Listenable.merge([_titleCtrl, _authorCtrl]),
                          builder: (_, __) => BookCoverWidget(
                            book: _preview,
                            width: 100,
                            height: 140,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Pré-visualização',
                            style: GoogleFonts.lato(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Título *', text),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleCtrl,
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Ex: O Nome do Vento',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _label('Autor *', text),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _authorCtrl,
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Ex: Patrick Rothfuss',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _label('Gênero', text),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGenre,
                          dropdownColor: surface,
                          style: GoogleFonts.lato(color: text, fontSize: 15),
                          icon: Icon(Icons.expand_more, color: secondary),
                          items: _genres
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Row(
                                      children: [
                                        Icon(_genreIcon(g),
                                            color: primary, size: 18),
                                        const SizedBox(width: 10),
                                        Text(g),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedGenre = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // --- O NOVO BOTÃO DE ARQUIVO ENTRA AQUI ---
                    _label('Arquivo do Livro *', text),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickEpub,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 14),
                        decoration: BoxDecoration(
                          color: surface,
                          border: Border.all(color: border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedEpub == null
                                  ? Icons.upload_file
                                  : Icons.check_circle,
                              color: _selectedEpub == null
                                  ? secondary
                                  : Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _epubFileName ??
                                    'Clique para escolher o arquivo .epub',
                                style: GoogleFonts.lato(
                                  color:
                                      _selectedEpub == null ? secondary : text,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ------------------------------------------

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _save,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.add_circle_outline),
                        label:
                            Text(_loading ? 'Salvando...' : 'Adicionar Livro'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Text(text,
      style: GoogleFonts.lato(
          color: color, fontSize: 13, fontWeight: FontWeight.w600));

  IconData _genreIcon(String genre) {
    switch (genre) {
      case 'Fantasy':
        return Icons.auto_fix_high;
      case 'Sci-Fi':
        return Icons.rocket_launch_outlined;
      case 'Romance':
        return Icons.favorite_outline;
      case 'Adventure':
        return Icons.explore_outlined;
      case 'Mystery':
        return Icons.search;
      case 'Drama':
        return Icons.theater_comedy_outlined;
      case 'Horror':
        return Icons.nightlight_outlined;
      case 'Biography':
        return Icons.person_outline;
      default:
        return Icons.menu_book_outlined;
    }
  }
}
