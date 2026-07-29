import 'dart:io';

import 'package:coffee_card/data/repositories/auth_repository.dart';
import 'package:coffee_card/domain/models/coffee_card.dart';
import 'package:coffee_card/routing/app_routes.dart';
import 'package:coffee_card/ui/core/responsive_layout.dart';
import 'package:coffee_card/ui/features/cards/view_models/coffee_cards_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CoffeeCardsHomeView extends StatefulWidget {
  const CoffeeCardsHomeView({super.key});

  @override
  State<CoffeeCardsHomeView> createState() => _CoffeeCardsHomeViewState();
}

class _CoffeeCardsHomeViewState extends State<CoffeeCardsHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoffeeCardsViewModel>().loadCards();
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CoffeeCardsViewModel viewModel,
    CoffeeCard card,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete coffee card?'),
        content: Text('Remove "${card.title}" from your collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await viewModel.deleteCard(card.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = context.watch<AuthRepository>();
    final viewModel = context.watch<CoffeeCardsViewModel>();
    final user = authRepository.currentUser;
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coffee Cards'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await context.read<AuthRepository>().logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.cardNew),
        icon: const Icon(Icons.add),
        label: const Text('Add card'),
      ),
      body: ResponsiveCenter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null)
              Text(
                'Hello, ${user.displayName}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Save brews with photos, notes, and ratings.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildBody(context, viewModel, dateFormat)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CoffeeCardsViewModel viewModel,
    DateFormat dateFormat,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(viewModel.errorMessage!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: viewModel.loadCards,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.coffee_outlined,
              size: 72,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text('No coffee cards yet'),
            const SizedBox(height: 8),
            const Text('Tap Add card to capture your first brew.'),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > kLargeScreenMinWidth
            ? 2
            : 1;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 1.35 : 0.82,
          ),
          itemCount: viewModel.cards.length,
          itemBuilder: (context, index) {
            final card = viewModel.cards[index];
            return _CoffeeCardTile(
              card: card,
              dateFormat: dateFormat,
              onEdit: () => context.push(AppRoutes.cardEditPath(card.id)),
              onDelete: () => _confirmDelete(context, viewModel, card),
            );
          },
        );
      },
    );
  }
}

class _CoffeeCardTile extends StatelessWidget {
  const _CoffeeCardTile({
    required this.card,
    required this.dateFormat,
    required this.onEdit,
    required this.onDelete,
  });

  final CoffeeCard card;
  final DateFormat dateFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: card.hasImage
                ? Image.file(
                    File(card.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                  )
                : const _ImagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  card.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _RatingStars(rating: card.rating),
                    const Spacer(),
                    Text(
                      dateFormat.format(card.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.local_cafe_outlined, size: 48)),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 18,
          color: filled ? Colors.amber.shade700 : Colors.grey,
        );
      }),
    );
  }
}
