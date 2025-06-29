// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/domain/entities/home_feed_item.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'audio_player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeFeedCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        body: BlocBuilder<HomeFeedCubit, HomeFeedState>(
          builder: (context, state) {
            if (state.status == HomeFeedStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == HomeFeedStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                final item = state.items[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _HomeFeedCard(
                    item: item,
                    onTap: () => _handleItemTap(context, item),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HomeFeedCard extends StatelessWidget {
  const _HomeFeedCard({required this.item, required this.onTap});

  final HomeFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: item.when(
          article: (data) => ListTile(
            leading: const Icon(Icons.article),
            title: Text(data.title),
            trailing: const Icon(Icons.chevron_right),
          ),
          audio: (data) => ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(data.title),
            trailing: const Icon(Icons.chevron_right),
          ),
          quote: (data) => ListTile(
            leading: const Icon(Icons.format_quote),
            title: Text('"${data.text}"'),
            subtitle: Text(data.author),
            trailing: const Icon(Icons.more_vert),
          ),
        ),
      ),
    );
  }
}

Future<void> _handleItemTap(BuildContext context, HomeFeedItem item) async {
  await item.when(
    article: (data) async {
      final uri = Uri.parse(data.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan')),
        );
      }
    },
    audio: (data) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AudioPlayerScreen(track: data)),
      );
    },
    quote: (data) {
      _showQuoteActions(context, data);
    },
  );
}

void _showQuoteActions(BuildContext context, MotivationalQuote quote) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: '"${quote.text}" - ${quote.author}'),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disalin ke clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Share.share('"${quote.text}" - ${quote.author}');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
