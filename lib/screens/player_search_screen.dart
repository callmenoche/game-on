import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/profile.dart';
import '../services/profile_service.dart';
import '../widgets/game_on_logo.dart';

class PlayerSearchScreen extends StatefulWidget {
  const PlayerSearchScreen({super.key});

  @override
  State<PlayerSearchScreen> createState() => _PlayerSearchScreenState();
}

class _PlayerSearchScreenState extends State<PlayerSearchScreen> {
  final _ctrl = TextEditingController();
  final _service = ProfileService();
  List<Profile> _results = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      try {
        final r = await _service.searchPlayers(q.trim());
        if (mounted) setState(() { _results = r; _searching = false; });
      } catch (_) {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search players by username…',
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            hintStyle:
                TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          ),
          onChanged: _onChanged,
        ),
      ),
      body: _searching
          ? const Center(
              child:
                  CircularProgressIndicator(color: GameOnBrand.saffron))
          : _results.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _ctrl.text.isEmpty
                          ? 'Search for players by username'
                          : 'No players found for "${_ctrl.text}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _results.length,
                  itemBuilder: (ctx, i) {
                    final p = _results[i];
                    final initial = p.username.isNotEmpty
                        ? p.username[0].toUpperCase()
                        : '?';
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            GameOnBrand.saffron.withValues(alpha: 0.15),
                        backgroundImage: p.avatarUrl != null
                            ? CachedNetworkImageProvider(p.avatarUrl!)
                            : null,
                        child: p.avatarUrl == null
                            ? Text(
                                initial,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: GameOnBrand.saffron,
                                ),
                              )
                            : null,
                      ),
                      title: Text(p.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      subtitle: p.bio != null && p.bio!.isNotEmpty
                          ? Text(
                              p.bio!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.5)),
                            )
                          : null,
                      onTap: () => context.push('/player/${p.id}'),
                    );
                  },
                ),
    );
  }
}
