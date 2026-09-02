import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI-only settings state — every row on the Settings screen holds and
/// reflects what the user tapped, but nothing here is persisted yet.
/// Real persistence is a future LocalLibraryPort/SettingsPort adapter;
/// this is presentation-layer state standing in for it until then, not
/// something reached through a use case.
class SettingsState {
  final String streamingQuality;
  final bool gaplessPlayback;
  final String downloadQuality;
  final bool wifiOnlyDownloads;
  final String connectedServer;

  const SettingsState({
    this.streamingQuality = 'High',
    this.gaplessPlayback = true,
    this.downloadQuality = 'Lossless',
    this.wifiOnlyDownloads = true,
    this.connectedServer = 'Home library',
  });

  SettingsState copyWith({
    String? streamingQuality,
    bool? gaplessPlayback,
    String? downloadQuality,
    bool? wifiOnlyDownloads,
    String? connectedServer,
  }) {
    return SettingsState(
      streamingQuality: streamingQuality ?? this.streamingQuality,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      connectedServer: connectedServer ?? this.connectedServer,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  static const _streamingQualities = ['Low', 'Normal', 'High'];
  static const _downloadQualities = ['Standard', 'High', 'Lossless'];
  static const _servers = ['Home library', 'Backup library'];

  @override
  SettingsState build() => const SettingsState();

  void cycleStreamingQuality() {
    state = state.copyWith(
      streamingQuality: _next(_streamingQualities, state.streamingQuality),
    );
  }

  void toggleGaplessPlayback() {
    state = state.copyWith(gaplessPlayback: !state.gaplessPlayback);
  }

  void cycleDownloadQuality() {
    state = state.copyWith(
      downloadQuality: _next(_downloadQualities, state.downloadQuality),
    );
  }

  void toggleWifiOnlyDownloads() {
    state = state.copyWith(wifiOnlyDownloads: !state.wifiOnlyDownloads);
  }

  void cycleConnectedServer() {
    state = state.copyWith(
      connectedServer: _next(_servers, state.connectedServer),
    );
  }

  String _next(List<String> options, String current) {
    final index = options.indexOf(current);
    return options[(index + 1) % options.length];
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);
