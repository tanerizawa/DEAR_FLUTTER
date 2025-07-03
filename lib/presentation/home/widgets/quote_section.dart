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
        final quote = state.feed?.quote;
        if (quote == null) return const SizedBox.shrink();
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
    return Card(
      child: ListTile(
        leading: const Icon(Icons.format_quote),
        title: Text('"${quote.text}"'),
        subtitle: Text(quote.author),
        onTap: () => context.go('/quote', extra: quote),
      ),
    );
  }
}
