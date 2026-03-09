import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/entity/multimedia_item.dart';
import '../../../core/services/external_player_service.dart';
import '../../../core/extensions/extension_manager.dart';
import '../../../core/extensions/base_provider.dart';
import '../../settings/presentation/player_settings_provider.dart';

class PlaybackLauncher {
  final Ref _ref;

  PlaybackLauncher(this._ref);

  Future<void> play(
    BuildContext context,
    String url, {
    required MultimediaItem baseItem,
    MultimediaItem? detailedItem,
  }) async {
    final settings = await _ref.read(playerSettingsProvider.future);
    if (!context.mounted) return;

    if (settings.preferredPlayer != null) {
      _launchExternal(
        context,
        url,
        detailedItem ?? baseItem,
        settings.preferredPlayer!,
      );
    } else {
      context.push(
        '/player',
        extra: {'item': detailedItem ?? baseItem, 'url': url},
      );
    }
  }

  Future<void> _launchExternal(
    BuildContext context,
    String episodeDataUrl,
    MultimediaItem item,
    String playerId,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Resolving streams...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final manager = _ref.read(extensionManagerProvider.notifier);
      SkyStreamProvider? provider;
      if (item.provider != null) {
        try {
          final val = item.provider!;
          provider = manager.getAllProviders().firstWhere(
            (p) => p.id == val || p.name == val,
          );
        } catch (_) {}
      }
      provider ??= _ref.read(activeProviderStateProvider);
      if (provider == null) throw Exception('No active provider');

      final streams = await provider.loadStreams(episodeDataUrl);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (streams.isEmpty) {
        final playerName =
            ExternalPlayerService.instance
                .getPlayerById(playerId)
                ?.displayName ??
            playerId;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not resolve video for $playerName. Starting internal player.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        context.push('/player', extra: {'item': item, 'url': episodeDataUrl});
        return;
      }

      if (streams.length == 1) {
        _launchStream(context, streams.first, item, episodeDataUrl, playerId);
      } else {
        _showSourcePicker(context, streams, item, episodeDataUrl, playerId);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e. Using internal player.')),
      );
      context.push('/player', extra: {'item': item, 'url': episodeDataUrl});
    }
  }

  Future<void> _launchStream(
    BuildContext context,
    StreamResult stream,
    MultimediaItem item,
    String episodeDataUrl,
    String playerId,
  ) async {
    final success = await ExternalPlayerService.instance.launch(
      stream.url,
      headers: stream.headers,
      playerId: playerId,
      title: item.title,
    );

    if (!success && context.mounted) {
      final playerName =
          ExternalPlayerService.instance.getPlayerById(playerId)?.displayName ??
          playerId;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$playerName not detected. Starting internal player.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      context.push('/player', extra: {'item': item, 'url': episodeDataUrl});
    }
  }

  void _showSourcePicker(
    BuildContext context,
    List<StreamResult> streams,
    MultimediaItem item,
    String episodeDataUrl,
    String playerId,
  ) {
    final playerName =
        ExternalPlayerService.instance.getPlayerById(playerId)?.displayName ??
        playerId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose source for $playerName',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: streams.length,
                  itemBuilder: (context, index) {
                    final stream = streams[index];
                    final label = stream.quality != 'Auto'
                        ? stream.quality
                        : 'Source ${index + 1}';
                    final host = Uri.tryParse(stream.url)?.host ?? '';

                    return ListTile(
                      leading: const Icon(Icons.play_circle_outline),
                      title: Text(label),
                      subtitle: host.isNotEmpty ? Text(host) : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        _launchStream(
                          context,
                          stream,
                          item,
                          episodeDataUrl,
                          playerId,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

final playbackLauncherProvider = Provider<PlaybackLauncher>((ref) {
  return PlaybackLauncher(ref);
});
