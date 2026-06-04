import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../theme/zfa_theme.dart';

/// Stern-Button zum Merken (Favorit). Persistiert über den FortschrittService.
class FavStern extends StatefulWidget {
  final String id;
  final double groesse;
  const FavStern({super.key, required this.id, this.groesse = 24});

  @override
  State<FavStern> createState() => _FavSternState();
}

class _FavSternState extends State<FavStern> {
  @override
  Widget build(BuildContext context) {
    final fav = fortschrittService.istFavorit(widget.id);
    return IconButton(
      icon: Icon(fav ? Icons.bookmark : Icons.bookmark_border,
          color: fav ? ZfaTheme.gold : null, size: widget.groesse),
      tooltip: fav ? 'Aus Favoriten entfernen' : 'Zu Favoriten',
      onPressed: () async {
        HapticFeedback.selectionClick();
        await fortschrittService.favoritUmschalten(widget.id);
        if (mounted) setState(() {});
      },
    );
  }
}
