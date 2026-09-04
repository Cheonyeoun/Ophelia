/// The user's playback/download/media-source preferences (see
/// docs/architecture.md §3.1). Immutable value type — no Flutter, no
/// package imports.
class Settings {
  final String streamingQuality;
  final bool gaplessPlayback;
  final String downloadQuality;
  final bool wifiOnlyDownloads;
  final String connectedServer;

  const Settings({
    required this.streamingQuality,
    required this.gaplessPlayback,
    required this.downloadQuality,
    required this.wifiOnlyDownloads,
    required this.connectedServer,
  });

  /// The out-of-the-box defaults, used to seed a fresh `SettingsPort`
  /// adapter (see data/fakes/fake_settings_port.dart) and the
  /// presentation layer's initial state before anything's been read.
  static const defaults = Settings(
    streamingQuality: 'High',
    gaplessPlayback: true,
    downloadQuality: 'Lossless',
    wifiOnlyDownloads: true,
    connectedServer: 'Home library',
  );

  Settings copyWith({
    String? streamingQuality,
    bool? gaplessPlayback,
    String? downloadQuality,
    bool? wifiOnlyDownloads,
    String? connectedServer,
  }) {
    return Settings(
      streamingQuality: streamingQuality ?? this.streamingQuality,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      connectedServer: connectedServer ?? this.connectedServer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settings &&
          runtimeType == other.runtimeType &&
          streamingQuality == other.streamingQuality &&
          gaplessPlayback == other.gaplessPlayback &&
          downloadQuality == other.downloadQuality &&
          wifiOnlyDownloads == other.wifiOnlyDownloads &&
          connectedServer == other.connectedServer;

  @override
  int get hashCode => Object.hash(
        streamingQuality,
        gaplessPlayback,
        downloadQuality,
        wifiOnlyDownloads,
        connectedServer,
      );
}
