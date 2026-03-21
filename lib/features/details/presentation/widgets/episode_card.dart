import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:skystream/core/domain/entity/multimedia_item.dart';
import 'package:skystream/core/storage/history_repository.dart';
import 'package:skystream/core/services/download_service.dart';
import 'package:skystream/core/utils/layout_constants.dart';
import '../../../../shared/widgets/thumbnail_error_placeholder.dart';
import '../../../library/presentation/history_provider.dart';
import '../details_controller.dart';
import '../download_launcher.dart';
import '../downloaded_file_provider.dart';
import 'download_progress_dialog.dart';
import 'download_management_dialog.dart';

class EpisodeCard extends HookConsumerWidget {
  final Episode episode;
  final MultimediaItem parentItem;
  final double? width;

  const EpisodeCard({
    super.key,
    required this.episode,
    required this.parentItem,
    this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final scaleAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: scaleController, curve: Curves.easeInOut),
      ),
    );

    final isFocused = useState(false);

    final historyRepo = ref.watch(historyRepositoryProvider);
    final historyItem = ref.watch(
      watchHistoryProvider.select(
        (list) => list.whereType<HistoryItem>().firstWhereOrNull(
          (h) => h.item.url == parentItem.url,
        ),
      ),
    );

    final epPos = historyRepo.getEpisodePosition(
      episode.url,
      mainUrl: parentItem.url,
      season: episode.season,
      episode: episode.episode,
    );
    final epDur = historyRepo.getEpisodeDuration(
      episode.url,
      mainUrl: parentItem.url,
      season: episode.season,
      episode: episode.episode,
    );

    final double progress = epDur > 0 ? epPos / epDur : 0;
    String? statusBadge;

    if (progress > 0.02) {
      statusBadge = progress > 0.98 ? "WATCHED" : "WATCHING";
    }

    if (historyItem != null && statusBadge == null) {
      final hSeason = historyItem.season ?? 1;
      final hEpisode = historyItem.episode ?? 1;
      final eSeason = episode.season;
      final eEpisode = episode.episode;

      if (eSeason == hSeason && eEpisode == hEpisode) {
        statusBadge = "LAST WATCHED";
      }
    }

    final activeDownloads = ref.watch(activeDownloadsProvider);
    final isDownloading = activeDownloads.contains(episode.url);
    final detailsState = ref.watch(detailsControllerProvider(parentItem.url));
    final details = detailsState.item;

    final progressMap = ref.watch(downloadProgressProvider);
    final downloadProgressData = progressMap[episode.url];
    final downloadProgress = downloadProgressData?.progress ?? 0.0;

    final downloadedFile = ref.watch(downloadedFilesProvider)[episode.url];

    // Check for downloaded file on load
    useEffect(() {
      if (!isDownloading) {
        Future.microtask(() {
          ref.read(downloadedFilesProvider.notifier).checkFile(
                parentItem,
                episode: episode,
              );
        });
      }
      return null;
    }, [episode.url, isDownloading]);

    void onFocusChange(bool focused) {
      isFocused.value = focused;
      if (focused) {
        scaleController.forward();
      } else {
        scaleController.reverse();
      }
    }

    return Focus(
      onFocusChange: onFocusChange,
      child: Transform.scale(
        scale: scaleAnimation,
        child: GestureDetector(
          onTap: () => ref
              .read(detailsControllerProvider(parentItem.url).notifier)
              .handlePlayPress(context, parentItem, specificEpisode: episode),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isFocused.value
                    ? Colors.white
                    : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: isFocused.value ? 2 : 1,
              ),
              boxShadow: isFocused.value
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                _buildThumbnail(context, progress, statusBadge),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(LayoutConstants.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "E${episode.episode} • ${episode.name}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isFocused.value
                                          ? Theme.of(context).colorScheme.primary
                                          : null,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (downloadedFile != null)
                              IconButton(
                                icon: const Icon(Icons.check_circle_rounded,
                                    color: Colors.green, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  DownloadManagementDialog.show(
                                    context,
                                    details ?? parentItem,
                                    downloadedFile,
                                    episode: episode,
                                  );
                                },
                              )
                            else if (isDownloading)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: InkWell(
                                  onTap: () => DownloadProgressDialog.show(
                                    context,
                                    '${parentItem.title} - ${episode.name}',
                                    episode.url,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: downloadProgressData?.status ==
                                            TaskStatus.paused
                                        ? Icon(
                                            Icons.pause_rounded,
                                            size: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          )
                                        : CircularProgressIndicator(
                                            value: downloadProgress > 0
                                                ? downloadProgress
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                  ),
                                ),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.download_rounded, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  ref.read(downloadLauncherProvider).launch(
                                        context,
                                        parentItem,
                                        episodeUrl: episode.url,
                                      );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          episode.description ?? 'No description available.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                height: 1.3,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(
    BuildContext context,
    double progress,
    String? statusBadge,
  ) {
    return Stack(
      children: [
        SizedBox(
          width: 140,
          child: CachedNetworkImage(
            imageUrl: episode.posterUrl ?? '',
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                const ThumbnailErrorPlaceholder(),
            placeholder: (context, url) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        ),
        if (progress > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: Colors.black26,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        if (statusBadge != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusBadge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
