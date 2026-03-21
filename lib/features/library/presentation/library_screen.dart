import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/bookmarks_tab.dart';
import 'widgets/downloads_tab.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Downloads', icon: Icon(Icons.download_for_offline_rounded)),
              Tab(text: 'Bookmarks', icon: Icon(Icons.bookmark_rounded)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DownloadsTab(),
            BookmarksTab(),
          ],
        ),
      ),
    );
  }
}
