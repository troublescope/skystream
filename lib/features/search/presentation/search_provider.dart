import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extension_manager.dart';
import '../../../../core/domain/entity/multimedia_item.dart';

class ProviderSearchResult {
  final String providerId;
  final String providerName;
  final List<MultimediaItem> results;
  final String? error;

  ProviderSearchResult({
    required this.providerId,
    required this.providerName,
    required this.results,
    this.error,
  });
}

/// Shared search orchestration — the single source of truth for provider
/// fan-out, result mapping, and prefix filtering. Returns results
/// incrementally as each provider completes natively concurrently.
Stream<List<ProviderSearchResult>> searchAllProviders(
  String query,
  ExtensionManager manager,
) async* {
  final providers = manager.getAllProviders();

  if (query.length < 2 || providers.isEmpty) {
    yield [];
    return;
  }

  final results = <ProviderSearchResult>[];
  final queryLower = query.toLowerCase();
  final queryParts = queryLower.split(' ').where((s) => s.isNotEmpty).toList();

  final controller = StreamController<List<ProviderSearchResult>>();
  int activeFutures = providers.length;

  for (final provider in providers) {
    Future(() async {
      try {
        final rawResults = await provider.search(query);

        final providerResults = rawResults
            .map(
              (item) => MultimediaItem(
                title: item.title,
                url: item.url,
                posterUrl: item.posterUrl,
                bannerUrl: item.bannerUrl,
                description: item.description,
                isFolder: item.isFolder,
                episodes: item.episodes,
                provider: provider.id,
              ),
            )
            .toList();

        final filtered = providerResults.where((item) {
          final titleLower = item.title.toLowerCase();
          final titleParts = titleLower
              .split(' ')
              .where((s) => s.isNotEmpty)
              .toList();

          for (final qPart in queryParts) {
            bool foundPrefix = false;
            for (final tPart in titleParts) {
              if (tPart.startsWith(qPart)) {
                foundPrefix = true;
                break;
              }
            }
            if (!foundPrefix) return false;
          }
          return true;
        }).toList();

        results.add(
          ProviderSearchResult(
            providerId: provider.id,
            providerName: provider.name,
            results: filtered,
          ),
        );
      } catch (e) {
        results.add(
          ProviderSearchResult(
            providerId: provider.id,
            providerName: provider.name,
            results: [],
            error: e.toString(),
          ),
        );
      } finally {
        if (!controller.isClosed) {
          controller.add(List.from(results));
        }
        activeFutures--;
        if (activeFutures == 0 && !controller.isClosed) {
          controller.close();
        }
      }
    }); // Spawns Future concurrently
  }

  yield* controller.stream;
}

// State for the search query
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

// Incremental search results — delegates to shared searchAllProviders()
final searchResultsProvider =
    StreamProvider.autoDispose<List<ProviderSearchResult>>((ref) {
      final query = ref.watch(searchQueryProvider);
      final manager = ref.read(extensionManagerProvider.notifier);
      return searchAllProviders(query, manager);
    });
