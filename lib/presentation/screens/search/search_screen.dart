import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search EthioShop...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            border: InputBorder.none, filled: false,
          ),
          onChanged: (q) => ref.read(searchProvider.notifier).search(q),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(onPressed: () { _ctrl.clear(); ref.read(searchProvider.notifier).clear(); },
                icon: const Icon(Icons.close_rounded)),
        ],
      ),
      body: state.query.isEmpty
          ? const EmptyStateWidget(icon: Icons.search_rounded, title: 'Search Products', subtitle: 'Find anything you need in EthioShop')
          : state.isSearching
              ? const Center(child: CircularProgressIndicator())
              : state.results.isEmpty
                  ? EmptyStateWidget(icon: Icons.search_off_rounded, title: 'No results', subtitle: 'Nothing found for "${state.query}"')
                  : MasonryGridView.count(
                      padding: const EdgeInsets.all(16),
                      crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                      itemCount: state.results.length,
                      itemBuilder: (_, i) => ProductCard(product: state.results[i]),
                    ),
    );
  }
}