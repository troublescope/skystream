import 'package:flutter/material.dart';
import 'package:skystream/core/providers/device_info_provider.dart';
import 'package:skystream/features/home/presentation/widgets/continue_watching_card.dart';
import 'package:skystream/features/library/presentation/history_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContinueWatchingSection extends ConsumerWidget {
  final String title;
  final List<HistoryItem> items;

  const ContinueWatchingSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();

    final device = ref.watch(deviceProfileProvider).asData?.value;
    final isLarge = device?.isLargeScreen ?? false;

    final double width = isLarge ? 360.0 : 280.0;
    final double listHeight = isLarge ? 200.0 : 150.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isLarge ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: isLarge ? 30 : 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All History'),
                      content: const Text(
                        'Are you sure you want to remove all items from your watch history?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(watchHistoryProvider.notifier)
                                .clearAllHistory();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Watch history cleared'),
                              ),
                            );
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: isLarge ? 24 : 12),
            itemBuilder: (context, index) {
              return ContinueWatchingCard(
                historyItem: items[index],
                width: width,
                isLarge: isLarge,
              );
            },
          ),
        ),
      ],
    );
  }
}
