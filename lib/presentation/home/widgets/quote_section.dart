import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// Displays the latest motivational quote.
class QuoteSection extends StatelessWidget {
  const QuoteSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Tampilkan kutipan statis jika state.feed?.quote null
    final staticQuote = MotivationalQuote(id: 0, text: 'Jangan menyerah, hari ini adalah awal yang baru.', author: 'Dear Diary');
    return BlocBuilder<HomeFeedCubit, HomeFeedState>(
      builder: (context, state) {
        if (state.status == HomeFeedStatus.loading) {
          return const _ShimmerQuoteCard();
        }
        if (state.status == HomeFeedStatus.failure) {
          return Center(
            child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
          );
        }
        final quote = state.feed?.quote ?? staticQuote;
        return _QuoteCard(quote: quote);
      },
    );
  }
}

class _ShimmerQuoteCard extends StatelessWidget {
  const _ShimmerQuoteCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: ListTile(
          leading: Icon(Icons.format_quote, color: Colors.grey[400]),
          title: Container(height: 20.0, color: Colors.grey[400]),
          subtitle: Container(height: 15.0, color: Colors.grey[300]),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});

  final MotivationalQuote quote;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF1DB954).withOpacity(0.15)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
          border: Border.all(color: Color(0x1A1A1A).withOpacity(0.15), width: 1.5),
          backgroundBlendMode: BlendMode.overlay,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.format_quote_rounded, size: 40, color: Color(0xFFB0B0B0), // Monochrome light grey for quote icon
                  shadows: [Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                      child: Text(
                        '"${quote.text}"',
                        key: ValueKey<String>(quote.text),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                            ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                      child: Text(
                        quote.author,
                        key: ValueKey<String>(quote.author),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Montserrat',
                              color: Color(0xFFD1D1D1), // Light grey for secondary text (artist, subtitle)
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              shadows: [Shadow(blurRadius: 6, color: Colors.black38)],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}
