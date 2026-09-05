import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class BookReaderScreen extends StatefulWidget {
  final Book book;
  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  double _fontSize = 16.0;
  double _progress = 0.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _progress = widget.book.progress;
    _scrollCtrl.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (_scrollCtrl.hasClients && _scrollCtrl.position.maxScrollExtent > 0) {
      final p = _scrollCtrl.offset / _scrollCtrl.position.maxScrollExtent;
      setState(() => _progress = p.clamp(0.0, 1.0));
    }
  }

  @override
  void dispose() {
    ApiService.updateProgress(widget.book.id, _progress);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          child: Column(
            children: [
              // Top bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showControls ? null : 0,
                child: _showControls
                    ? Container(
                        color: surface,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: text),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.book.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleSmall),
                                  Text(widget.book.author,
                                      style: GoogleFonts.lato(
                                          color: secondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.settings_outlined, color: secondary),
                              onPressed: _showFontSettings,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ),
              // Progress indicator
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                color: primary,
                minHeight: 3,
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROLOGUE',
                        style: GoogleFonts.playfairDisplay(
                          color: primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: primary.withValues(alpha: 0.4)),
                      const SizedBox(height: 24),
                      Text(
                        widget.book.epubPath,
                        style: GoogleFonts.lato(
                          color: text,
                          fontSize: _fontSize,
                          height: 1.8,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom progress
              if (_showControls)
                Container(
                  color: surface,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: GoogleFonts.lato(
                            color: secondary, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Slider(
                          value: _progress,
                          onChanged: (v) {
                            setState(() => _progress = v);
                            final target = v *
                                _scrollCtrl.position.maxScrollExtent;
                            _scrollCtrl.jumpTo(target);
                          },
                          activeColor: primary,
                          inactiveColor: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tamanho da fonte',
                  style: GoogleFonts.lato(
                      color: text, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: primary),
                    onPressed: () {
                      if (_fontSize > 12) {
                        setModal(() {});
                        setState(() => _fontSize -= 2);
                      }
                    },
                  ),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 12,
                      max: 24,
                      divisions: 6,
                      activeColor: primary,
                      onChanged: (v) {
                        setModal(() {});
                        setState(() => _fontSize = v);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: primary),
                    onPressed: () {
                      if (_fontSize < 24) {
                        setModal(() {});
                        setState(() => _fontSize += 2);
                      }
                    },
                  ),
                ],
              ),
              Text('${_fontSize.toInt()}pt',
                  style: GoogleFonts.lato(color: text)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
