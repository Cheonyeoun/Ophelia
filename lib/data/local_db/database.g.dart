// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final String id;
  final String name;
  final DateTime createdAt;
  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Playlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Playlist copyWith({String? id, String? name, DateTime? createdAt}) =>
      Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Playlist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedTracksTable extends CachedTracks
    with TableInfo<$CachedTracksTable, CachedTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverArtPathMeta = const VerificationMeta(
    'coverArtPath',
  );
  @override
  late final GeneratedColumn<String> coverArtPath = GeneratedColumn<String>(
    'cover_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDownloadedMeta = const VerificationMeta(
    'isDownloaded',
  );
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
    'is_downloaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_downloaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artist,
    album,
    durationMs,
    coverArtPath,
    isDownloaded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedTrack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('cover_art_path')) {
      context.handle(
        _coverArtPathMeta,
        coverArtPath.isAcceptableOrUnknown(
          data['cover_art_path']!,
          _coverArtPathMeta,
        ),
      );
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
        _isDownloadedMeta,
        isDownloaded.isAcceptableOrUnknown(
          data['is_downloaded']!,
          _isDownloadedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedTrack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      coverArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_path'],
      ),
      isDownloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_downloaded'],
      )!,
    );
  }

  @override
  $CachedTracksTable createAlias(String alias) {
    return $CachedTracksTable(attachedDatabase, alias);
  }
}

class CachedTrack extends DataClass implements Insertable<CachedTrack> {
  final String id;
  final String? title;
  final String? artist;
  final String? album;
  final int? durationMs;
  final String? coverArtPath;
  final bool isDownloaded;
  const CachedTrack({
    required this.id,
    this.title,
    this.artist,
    this.album,
    this.durationMs,
    this.coverArtPath,
    required this.isDownloaded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || coverArtPath != null) {
      map['cover_art_path'] = Variable<String>(coverArtPath);
    }
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    return map;
  }

  CachedTracksCompanion toCompanion(bool nullToAbsent) {
    return CachedTracksCompanion(
      id: Value(id),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      coverArtPath: coverArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArtPath),
      isDownloaded: Value(isDownloaded),
    );
  }

  factory CachedTrack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedTrack(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      coverArtPath: serializer.fromJson<String?>(json['coverArtPath']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'durationMs': serializer.toJson<int?>(durationMs),
      'coverArtPath': serializer.toJson<String?>(coverArtPath),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
    };
  }

  CachedTrack copyWith({
    String? id,
    Value<String?> title = const Value.absent(),
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> coverArtPath = const Value.absent(),
    bool? isDownloaded,
  }) => CachedTrack(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    coverArtPath: coverArtPath.present ? coverArtPath.value : this.coverArtPath,
    isDownloaded: isDownloaded ?? this.isDownloaded,
  );
  CachedTrack copyWithCompanion(CachedTracksCompanion data) {
    return CachedTrack(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      coverArtPath: data.coverArtPath.present
          ? data.coverArtPath.value
          : this.coverArtPath,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedTrack(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('isDownloaded: $isDownloaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    album,
    durationMs,
    coverArtPath,
    isDownloaded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedTrack &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.coverArtPath == this.coverArtPath &&
          other.isDownloaded == this.isDownloaded);
}

class CachedTracksCompanion extends UpdateCompanion<CachedTrack> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<int?> durationMs;
  final Value<String?> coverArtPath;
  final Value<bool> isDownloaded;
  final Value<int> rowid;
  const CachedTracksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.coverArtPath = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedTracksCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.coverArtPath = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CachedTrack> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<String>? coverArtPath,
    Expression<bool>? isDownloaded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (coverArtPath != null) 'cover_art_path': coverArtPath,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedTracksCompanion copyWith({
    Value<String>? id,
    Value<String?>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<int?>? durationMs,
    Value<String?>? coverArtPath,
    Value<bool>? isDownloaded,
    Value<int>? rowid,
  }) {
    return CachedTracksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (coverArtPath.present) {
      map['cover_art_path'] = Variable<String>(coverArtPath.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedTracksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTracksTable extends PlaylistTracks
    with TableInfo<$PlaylistTracksTable, PlaylistTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_tracks (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, playlistId, trackId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTrack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTrack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaylistTracksTable createAlias(String alias) {
    return $PlaylistTracksTable(attachedDatabase, alias);
  }
}

class PlaylistTrack extends DataClass implements Insertable<PlaylistTrack> {
  final int id;

  /// Cascades so deleting a playlist cleans up its track rows instead of
  /// leaving them orphaned.
  final String playlistId;

  /// No `onDelete` action: unlike a playlist owned outright by this
  /// adapter, a `cached_tracks` row deleted by a future cache-cleanup
  /// process shouldn't silently delete a user's playlist entries too.
  final String trackId;
  final int position;
  const PlaylistTrack({
    required this.id,
    required this.playlistId,
    required this.trackId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_id'] = Variable<String>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistTracksCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTracksCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      position: Value(position),
    );
  }

  factory PlaylistTrack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTrack(
      id: serializer.fromJson<int>(json['id']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlistId': serializer.toJson<String>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistTrack copyWith({
    int? id,
    String? playlistId,
    String? trackId,
    int? position,
  }) => PlaylistTrack(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
  );
  PlaylistTrack copyWithCompanion(PlaylistTracksCompanion data) {
    return PlaylistTrack(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrack(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlistId, trackId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTrack &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.position == this.position);
}

class PlaylistTracksCompanion extends UpdateCompanion<PlaylistTrack> {
  final Value<int> id;
  final Value<String> playlistId;
  final Value<String> trackId;
  final Value<int> position;
  const PlaylistTracksCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
  });
  PlaylistTracksCompanion.insert({
    this.id = const Value.absent(),
    required String playlistId,
    required String trackId,
    required int position,
  }) : playlistId = Value(playlistId),
       trackId = Value(trackId),
       position = Value(position);
  static Insertable<PlaylistTrack> custom({
    Expression<int>? id,
    Expression<String>? playlistId,
    Expression<String>? trackId,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
    });
  }

  PlaylistTracksCompanion copyWith({
    Value<int>? id,
    Value<String>? playlistId,
    Value<String>? trackId,
    Value<int>? position,
  }) {
    return PlaylistTracksCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTracksCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $ListeningEventsTable extends ListeningEvents
    with TableInfo<$ListeningEventsTable, ListeningEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_tracks (id)',
    ),
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _msPlayedMeta = const VerificationMeta(
    'msPlayed',
  );
  @override
  late final GeneratedColumn<int> msPlayed = GeneratedColumn<int>(
    'ms_played',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, trackId, playedAt, msPlayed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listening_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListeningEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    if (data.containsKey('ms_played')) {
      context.handle(
        _msPlayedMeta,
        msPlayed.isAcceptableOrUnknown(data['ms_played']!, _msPlayedMeta),
      );
    } else if (isInserting) {
      context.missing(_msPlayedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListeningEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
      msPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ms_played'],
      )!,
    );
  }

  @override
  $ListeningEventsTable createAlias(String alias) {
    return $ListeningEventsTable(attachedDatabase, alias);
  }
}

class ListeningEvent extends DataClass implements Insertable<ListeningEvent> {
  final int id;
  final String trackId;
  final DateTime playedAt;
  final int msPlayed;
  const ListeningEvent({
    required this.id,
    required this.trackId,
    required this.playedAt,
    required this.msPlayed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_id'] = Variable<String>(trackId);
    map['played_at'] = Variable<DateTime>(playedAt);
    map['ms_played'] = Variable<int>(msPlayed);
    return map;
  }

  ListeningEventsCompanion toCompanion(bool nullToAbsent) {
    return ListeningEventsCompanion(
      id: Value(id),
      trackId: Value(trackId),
      playedAt: Value(playedAt),
      msPlayed: Value(msPlayed),
    );
  }

  factory ListeningEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningEvent(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      msPlayed: serializer.fromJson<int>(json['msPlayed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<String>(trackId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'msPlayed': serializer.toJson<int>(msPlayed),
    };
  }

  ListeningEvent copyWith({
    int? id,
    String? trackId,
    DateTime? playedAt,
    int? msPlayed,
  }) => ListeningEvent(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    playedAt: playedAt ?? this.playedAt,
    msPlayed: msPlayed ?? this.msPlayed,
  );
  ListeningEvent copyWithCompanion(ListeningEventsCompanion data) {
    return ListeningEvent(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      msPlayed: data.msPlayed.present ? data.msPlayed.value : this.msPlayed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListeningEvent(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('playedAt: $playedAt, ')
          ..write('msPlayed: $msPlayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trackId, playedAt, msPlayed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningEvent &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.playedAt == this.playedAt &&
          other.msPlayed == this.msPlayed);
}

class ListeningEventsCompanion extends UpdateCompanion<ListeningEvent> {
  final Value<int> id;
  final Value<String> trackId;
  final Value<DateTime> playedAt;
  final Value<int> msPlayed;
  const ListeningEventsCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.msPlayed = const Value.absent(),
  });
  ListeningEventsCompanion.insert({
    this.id = const Value.absent(),
    required String trackId,
    required DateTime playedAt,
    required int msPlayed,
  }) : trackId = Value(trackId),
       playedAt = Value(playedAt),
       msPlayed = Value(msPlayed);
  static Insertable<ListeningEvent> custom({
    Expression<int>? id,
    Expression<String>? trackId,
    Expression<DateTime>? playedAt,
    Expression<int>? msPlayed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (playedAt != null) 'played_at': playedAt,
      if (msPlayed != null) 'ms_played': msPlayed,
    });
  }

  ListeningEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? trackId,
    Value<DateTime>? playedAt,
    Value<int>? msPlayed,
  }) {
    return ListeningEventsCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      playedAt: playedAt ?? this.playedAt,
      msPlayed: msPlayed ?? this.msPlayed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (msPlayed.present) {
      map['ms_played'] = Variable<int>(msPlayed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningEventsCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('playedAt: $playedAt, ')
          ..write('msPlayed: $msPlayed')
          ..write(')'))
        .toString();
  }
}

class $ProfileTable extends Profile with TableInfo<$ProfileTable, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backgroundPathMeta = const VerificationMeta(
    'backgroundPath',
  );
  @override
  late final GeneratedColumn<String> backgroundPath = GeneratedColumn<String>(
    'background_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileImagePathMeta = const VerificationMeta(
    'profileImagePath',
  );
  @override
  late final GeneratedColumn<String> profileImagePath = GeneratedColumn<String>(
    'profile_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    backgroundPath,
    profileImagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('background_path')) {
      context.handle(
        _backgroundPathMeta,
        backgroundPath.isAcceptableOrUnknown(
          data['background_path']!,
          _backgroundPathMeta,
        ),
      );
    }
    if (data.containsKey('profile_image_path')) {
      context.handle(
        _profileImagePathMeta,
        profileImagePath.isAcceptableOrUnknown(
          data['profile_image_path']!,
          _profileImagePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      backgroundPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}background_path'],
      ),
      profileImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_image_path'],
      ),
    );
  }

  @override
  $ProfileTable createAlias(String alias) {
    return $ProfileTable(attachedDatabase, alias);
  }
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final int id;
  final String displayName;
  final String? backgroundPath;
  final String? profileImagePath;
  const ProfileData({
    required this.id,
    required this.displayName,
    this.backgroundPath,
    this.profileImagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || backgroundPath != null) {
      map['background_path'] = Variable<String>(backgroundPath);
    }
    if (!nullToAbsent || profileImagePath != null) {
      map['profile_image_path'] = Variable<String>(profileImagePath);
    }
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: Value(id),
      displayName: Value(displayName),
      backgroundPath: backgroundPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backgroundPath),
      profileImagePath: profileImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(profileImagePath),
    );
  }

  factory ProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      backgroundPath: serializer.fromJson<String?>(json['backgroundPath']),
      profileImagePath: serializer.fromJson<String?>(json['profileImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'backgroundPath': serializer.toJson<String?>(backgroundPath),
      'profileImagePath': serializer.toJson<String?>(profileImagePath),
    };
  }

  ProfileData copyWith({
    int? id,
    String? displayName,
    Value<String?> backgroundPath = const Value.absent(),
    Value<String?> profileImagePath = const Value.absent(),
  }) => ProfileData(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    backgroundPath: backgroundPath.present
        ? backgroundPath.value
        : this.backgroundPath,
    profileImagePath: profileImagePath.present
        ? profileImagePath.value
        : this.profileImagePath,
  );
  ProfileData copyWithCompanion(ProfileCompanion data) {
    return ProfileData(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      backgroundPath: data.backgroundPath.present
          ? data.backgroundPath.value
          : this.backgroundPath,
      profileImagePath: data.profileImagePath.present
          ? data.profileImagePath.value
          : this.profileImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileData(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('backgroundPath: $backgroundPath, ')
          ..write('profileImagePath: $profileImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, displayName, backgroundPath, profileImagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.backgroundPath == this.backgroundPath &&
          other.profileImagePath == this.profileImagePath);
}

class ProfileCompanion extends UpdateCompanion<ProfileData> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String?> backgroundPath;
  final Value<String?> profileImagePath;
  const ProfileCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.backgroundPath = const Value.absent(),
    this.profileImagePath = const Value.absent(),
  });
  ProfileCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    this.backgroundPath = const Value.absent(),
    this.profileImagePath = const Value.absent(),
  }) : displayName = Value(displayName);
  static Insertable<ProfileData> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? backgroundPath,
    Expression<String>? profileImagePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (backgroundPath != null) 'background_path': backgroundPath,
      if (profileImagePath != null) 'profile_image_path': profileImagePath,
    });
  }

  ProfileCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<String?>? backgroundPath,
    Value<String?>? profileImagePath,
  }) {
    return ProfileCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      backgroundPath: backgroundPath ?? this.backgroundPath,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (backgroundPath.present) {
      map['background_path'] = Variable<String>(backgroundPath.value);
    }
    if (profileImagePath.present) {
      map['profile_image_path'] = Variable<String>(profileImagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('backgroundPath: $backgroundPath, ')
          ..write('profileImagePath: $profileImagePath')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, Download> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_tracks (id)',
    ),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    localPath,
    sizeBytes,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Download> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  Download map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Download(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }
}

class Download extends DataClass implements Insertable<Download> {
  final String trackId;
  final String localPath;
  final int sizeBytes;
  final DateTime downloadedAt;
  const Download({
    required this.trackId,
    required this.localPath,
    required this.sizeBytes,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['local_path'] = Variable<String>(localPath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      trackId: Value(trackId),
      localPath: Value(localPath),
      sizeBytes: Value(sizeBytes),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory Download.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Download(
      trackId: serializer.fromJson<String>(json['trackId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'localPath': serializer.toJson<String>(localPath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  Download copyWith({
    String? trackId,
    String? localPath,
    int? sizeBytes,
    DateTime? downloadedAt,
  }) => Download(
    trackId: trackId ?? this.trackId,
    localPath: localPath ?? this.localPath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  Download copyWithCompanion(DownloadsCompanion data) {
    return Download(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Download(')
          ..write('trackId: $trackId, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, localPath, sizeBytes, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Download &&
          other.trackId == this.trackId &&
          other.localPath == this.localPath &&
          other.sizeBytes == this.sizeBytes &&
          other.downloadedAt == this.downloadedAt);
}

class DownloadsCompanion extends UpdateCompanion<Download> {
  final Value<String> trackId;
  final Value<String> localPath;
  final Value<int> sizeBytes;
  final Value<DateTime> downloadedAt;
  final Value<int> rowid;
  const DownloadsCompanion({
    this.trackId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadsCompanion.insert({
    required String trackId,
    required String localPath,
    required int sizeBytes,
    required DateTime downloadedAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       localPath = Value(localPath),
       sizeBytes = Value(sizeBytes),
       downloadedAt = Value(downloadedAt);
  static Insertable<Download> custom({
    Expression<String>? trackId,
    Expression<String>? localPath,
    Expression<int>? sizeBytes,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (localPath != null) 'local_path': localPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadsCompanion copyWith({
    Value<String>? trackId,
    Value<String>? localPath,
    Value<int>? sizeBytes,
    Value<DateTime>? downloadedAt,
    Value<int>? rowid,
  }) {
    return DownloadsCompanion(
      trackId: trackId ?? this.trackId,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('trackId: $trackId, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinkedFoldersTable extends LinkedFolders
    with TableInfo<$LinkedFoldersTable, LinkedFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinkedFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedAtMeta = const VerificationMeta(
    'linkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> linkedAt = GeneratedColumn<DateTime>(
    'linked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [path, linkedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'linked_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinkedFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('linked_at')) {
      context.handle(
        _linkedAtMeta,
        linkedAt.isAcceptableOrUnknown(data['linked_at']!, _linkedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_linkedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  LinkedFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinkedFolder(
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      linkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}linked_at'],
      )!,
    );
  }

  @override
  $LinkedFoldersTable createAlias(String alias) {
    return $LinkedFoldersTable(attachedDatabase, alias);
  }
}

class LinkedFolder extends DataClass implements Insertable<LinkedFolder> {
  final String path;
  final DateTime linkedAt;
  const LinkedFolder({required this.path, required this.linkedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    map['linked_at'] = Variable<DateTime>(linkedAt);
    return map;
  }

  LinkedFoldersCompanion toCompanion(bool nullToAbsent) {
    return LinkedFoldersCompanion(path: Value(path), linkedAt: Value(linkedAt));
  }

  factory LinkedFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinkedFolder(
      path: serializer.fromJson<String>(json['path']),
      linkedAt: serializer.fromJson<DateTime>(json['linkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'linkedAt': serializer.toJson<DateTime>(linkedAt),
    };
  }

  LinkedFolder copyWith({String? path, DateTime? linkedAt}) => LinkedFolder(
    path: path ?? this.path,
    linkedAt: linkedAt ?? this.linkedAt,
  );
  LinkedFolder copyWithCompanion(LinkedFoldersCompanion data) {
    return LinkedFolder(
      path: data.path.present ? data.path.value : this.path,
      linkedAt: data.linkedAt.present ? data.linkedAt.value : this.linkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinkedFolder(')
          ..write('path: $path, ')
          ..write('linkedAt: $linkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(path, linkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinkedFolder &&
          other.path == this.path &&
          other.linkedAt == this.linkedAt);
}

class LinkedFoldersCompanion extends UpdateCompanion<LinkedFolder> {
  final Value<String> path;
  final Value<DateTime> linkedAt;
  final Value<int> rowid;
  const LinkedFoldersCompanion({
    this.path = const Value.absent(),
    this.linkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinkedFoldersCompanion.insert({
    required String path,
    required DateTime linkedAt,
    this.rowid = const Value.absent(),
  }) : path = Value(path),
       linkedAt = Value(linkedAt);
  static Insertable<LinkedFolder> custom({
    Expression<String>? path,
    Expression<DateTime>? linkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (linkedAt != null) 'linked_at': linkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinkedFoldersCompanion copyWith({
    Value<String>? path,
    Value<DateTime>? linkedAt,
    Value<int>? rowid,
  }) {
    return LinkedFoldersCompanion(
      path: path ?? this.path,
      linkedAt: linkedAt ?? this.linkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (linkedAt.present) {
      map['linked_at'] = Variable<DateTime>(linkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinkedFoldersCompanion(')
          ..write('path: $path, ')
          ..write('linkedAt: $linkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackSessionTable extends PlaybackSession
    with TableInfo<$PlaybackSessionTable, PlaybackSessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackSessionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queueIndexMeta = const VerificationMeta(
    'queueIndex',
  );
  @override
  late final GeneratedColumn<int> queueIndex = GeneratedColumn<int>(
    'queue_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, queueIndex, positionMs, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_session';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackSessionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('queue_index')) {
      context.handle(
        _queueIndexMeta,
        queueIndex.isAcceptableOrUnknown(data['queue_index']!, _queueIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_queueIndexMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackSessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackSessionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      queueIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $PlaybackSessionTable createAlias(String alias) {
    return $PlaybackSessionTable(attachedDatabase, alias);
  }
}

class PlaybackSessionData extends DataClass
    implements Insertable<PlaybackSessionData> {
  final int id;
  final int queueIndex;
  final int positionMs;
  final DateTime savedAt;
  const PlaybackSessionData({
    required this.id,
    required this.queueIndex,
    required this.positionMs,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['queue_index'] = Variable<int>(queueIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  PlaybackSessionCompanion toCompanion(bool nullToAbsent) {
    return PlaybackSessionCompanion(
      id: Value(id),
      queueIndex: Value(queueIndex),
      positionMs: Value(positionMs),
      savedAt: Value(savedAt),
    );
  }

  factory PlaybackSessionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackSessionData(
      id: serializer.fromJson<int>(json['id']),
      queueIndex: serializer.fromJson<int>(json['queueIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'queueIndex': serializer.toJson<int>(queueIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  PlaybackSessionData copyWith({
    int? id,
    int? queueIndex,
    int? positionMs,
    DateTime? savedAt,
  }) => PlaybackSessionData(
    id: id ?? this.id,
    queueIndex: queueIndex ?? this.queueIndex,
    positionMs: positionMs ?? this.positionMs,
    savedAt: savedAt ?? this.savedAt,
  );
  PlaybackSessionData copyWithCompanion(PlaybackSessionCompanion data) {
    return PlaybackSessionData(
      id: data.id.present ? data.id.value : this.id,
      queueIndex: data.queueIndex.present
          ? data.queueIndex.value
          : this.queueIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSessionData(')
          ..write('id: $id, ')
          ..write('queueIndex: $queueIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, queueIndex, positionMs, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackSessionData &&
          other.id == this.id &&
          other.queueIndex == this.queueIndex &&
          other.positionMs == this.positionMs &&
          other.savedAt == this.savedAt);
}

class PlaybackSessionCompanion extends UpdateCompanion<PlaybackSessionData> {
  final Value<int> id;
  final Value<int> queueIndex;
  final Value<int> positionMs;
  final Value<DateTime> savedAt;
  const PlaybackSessionCompanion({
    this.id = const Value.absent(),
    this.queueIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  PlaybackSessionCompanion.insert({
    this.id = const Value.absent(),
    required int queueIndex,
    required int positionMs,
    required DateTime savedAt,
  }) : queueIndex = Value(queueIndex),
       positionMs = Value(positionMs),
       savedAt = Value(savedAt);
  static Insertable<PlaybackSessionData> custom({
    Expression<int>? id,
    Expression<int>? queueIndex,
    Expression<int>? positionMs,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (queueIndex != null) 'queue_index': queueIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  PlaybackSessionCompanion copyWith({
    Value<int>? id,
    Value<int>? queueIndex,
    Value<int>? positionMs,
    Value<DateTime>? savedAt,
  }) {
    return PlaybackSessionCompanion(
      id: id ?? this.id,
      queueIndex: queueIndex ?? this.queueIndex,
      positionMs: positionMs ?? this.positionMs,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (queueIndex.present) {
      map['queue_index'] = Variable<int>(queueIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSessionCompanion(')
          ..write('id: $id, ')
          ..write('queueIndex: $queueIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

class $PlaybackQueueEntriesTable extends PlaybackQueueEntries
    with TableInfo<$PlaybackQueueEntriesTable, PlaybackQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playback_session (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverArtPathMeta = const VerificationMeta(
    'coverArtPath',
  );
  @override
  late final GeneratedColumn<String> coverArtPath = GeneratedColumn<String>(
    'cover_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    position,
    trackId,
    title,
    artist,
    album,
    durationMs,
    coverArtPath,
    sourceType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('cover_art_path')) {
      context.handle(
        _coverArtPathMeta,
        coverArtPath.isAcceptableOrUnknown(
          data['cover_art_path']!,
          _coverArtPathMeta,
        ),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      coverArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_path'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
    );
  }

  @override
  $PlaybackQueueEntriesTable createAlias(String alias) {
    return $PlaybackQueueEntriesTable(attachedDatabase, alias);
  }
}

class PlaybackQueueEntry extends DataClass
    implements Insertable<PlaybackQueueEntry> {
  final int id;
  final int sessionId;
  final int position;
  final String trackId;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String? coverArtPath;
  final String sourceType;
  const PlaybackQueueEntry({
    required this.id,
    required this.sessionId,
    required this.position,
    required this.trackId,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    this.coverArtPath,
    required this.sourceType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['position'] = Variable<int>(position);
    map['track_id'] = Variable<String>(trackId);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || coverArtPath != null) {
      map['cover_art_path'] = Variable<String>(coverArtPath);
    }
    map['source_type'] = Variable<String>(sourceType);
    return map;
  }

  PlaybackQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return PlaybackQueueEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      position: Value(position),
      trackId: Value(trackId),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      durationMs: Value(durationMs),
      coverArtPath: coverArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArtPath),
      sourceType: Value(sourceType),
    );
  }

  factory PlaybackQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      position: serializer.fromJson<int>(json['position']),
      trackId: serializer.fromJson<String>(json['trackId']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      coverArtPath: serializer.fromJson<String?>(json['coverArtPath']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'position': serializer.toJson<int>(position),
      'trackId': serializer.toJson<String>(trackId),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'durationMs': serializer.toJson<int>(durationMs),
      'coverArtPath': serializer.toJson<String?>(coverArtPath),
      'sourceType': serializer.toJson<String>(sourceType),
    };
  }

  PlaybackQueueEntry copyWith({
    int? id,
    int? sessionId,
    int? position,
    String? trackId,
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    Value<String?> coverArtPath = const Value.absent(),
    String? sourceType,
  }) => PlaybackQueueEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    position: position ?? this.position,
    trackId: trackId ?? this.trackId,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    durationMs: durationMs ?? this.durationMs,
    coverArtPath: coverArtPath.present ? coverArtPath.value : this.coverArtPath,
    sourceType: sourceType ?? this.sourceType,
  );
  PlaybackQueueEntry copyWithCompanion(PlaybackQueueEntriesCompanion data) {
    return PlaybackQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      position: data.position.present ? data.position.value : this.position,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      coverArtPath: data.coverArtPath.present
          ? data.coverArtPath.value
          : this.coverArtPath,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackQueueEntry(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('sourceType: $sourceType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    position,
    trackId,
    title,
    artist,
    album,
    durationMs,
    coverArtPath,
    sourceType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackQueueEntry &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.position == this.position &&
          other.trackId == this.trackId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.coverArtPath == this.coverArtPath &&
          other.sourceType == this.sourceType);
}

class PlaybackQueueEntriesCompanion
    extends UpdateCompanion<PlaybackQueueEntry> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> position;
  final Value<String> trackId;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<int> durationMs;
  final Value<String?> coverArtPath;
  final Value<String> sourceType;
  const PlaybackQueueEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.position = const Value.absent(),
    this.trackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.coverArtPath = const Value.absent(),
    this.sourceType = const Value.absent(),
  });
  PlaybackQueueEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int position,
    required String trackId,
    required String title,
    required String artist,
    required String album,
    required int durationMs,
    this.coverArtPath = const Value.absent(),
    required String sourceType,
  }) : sessionId = Value(sessionId),
       position = Value(position),
       trackId = Value(trackId),
       title = Value(title),
       artist = Value(artist),
       album = Value(album),
       durationMs = Value(durationMs),
       sourceType = Value(sourceType);
  static Insertable<PlaybackQueueEntry> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? position,
    Expression<String>? trackId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<String>? coverArtPath,
    Expression<String>? sourceType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (position != null) 'position': position,
      if (trackId != null) 'track_id': trackId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (coverArtPath != null) 'cover_art_path': coverArtPath,
      if (sourceType != null) 'source_type': sourceType,
    });
  }

  PlaybackQueueEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? position,
    Value<String>? trackId,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? album,
    Value<int>? durationMs,
    Value<String?>? coverArtPath,
    Value<String>? sourceType,
  }) {
    return PlaybackQueueEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      position: position ?? this.position,
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      sourceType: sourceType ?? this.sourceType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (coverArtPath.present) {
      map['cover_art_path'] = Variable<String>(coverArtPath.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackQueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('sourceType: $sourceType')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streamingQualityMeta = const VerificationMeta(
    'streamingQuality',
  );
  @override
  late final GeneratedColumn<String> streamingQuality = GeneratedColumn<String>(
    'streaming_quality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gaplessPlaybackMeta = const VerificationMeta(
    'gaplessPlayback',
  );
  @override
  late final GeneratedColumn<bool> gaplessPlayback = GeneratedColumn<bool>(
    'gapless_playback',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("gapless_playback" IN (0, 1))',
    ),
  );
  static const VerificationMeta _downloadQualityMeta = const VerificationMeta(
    'downloadQuality',
  );
  @override
  late final GeneratedColumn<String> downloadQuality = GeneratedColumn<String>(
    'download_quality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wifiOnlyDownloadsMeta = const VerificationMeta(
    'wifiOnlyDownloads',
  );
  @override
  late final GeneratedColumn<bool> wifiOnlyDownloads = GeneratedColumn<bool>(
    'wifi_only_downloads',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wifi_only_downloads" IN (0, 1))',
    ),
  );
  static const VerificationMeta _connectedServerMeta = const VerificationMeta(
    'connectedServer',
  );
  @override
  late final GeneratedColumn<String> connectedServer = GeneratedColumn<String>(
    'connected_server',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _immersiveHudAutoHideDelayMeta =
      const VerificationMeta('immersiveHudAutoHideDelay');
  @override
  late final GeneratedColumn<String> immersiveHudAutoHideDelay =
      GeneratedColumn<String>(
        'immersive_hud_auto_hide_delay',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    streamingQuality,
    gaplessPlayback,
    downloadQuality,
    wifiOnlyDownloads,
    connectedServer,
    immersiveHudAutoHideDelay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('streaming_quality')) {
      context.handle(
        _streamingQualityMeta,
        streamingQuality.isAcceptableOrUnknown(
          data['streaming_quality']!,
          _streamingQualityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_streamingQualityMeta);
    }
    if (data.containsKey('gapless_playback')) {
      context.handle(
        _gaplessPlaybackMeta,
        gaplessPlayback.isAcceptableOrUnknown(
          data['gapless_playback']!,
          _gaplessPlaybackMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gaplessPlaybackMeta);
    }
    if (data.containsKey('download_quality')) {
      context.handle(
        _downloadQualityMeta,
        downloadQuality.isAcceptableOrUnknown(
          data['download_quality']!,
          _downloadQualityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadQualityMeta);
    }
    if (data.containsKey('wifi_only_downloads')) {
      context.handle(
        _wifiOnlyDownloadsMeta,
        wifiOnlyDownloads.isAcceptableOrUnknown(
          data['wifi_only_downloads']!,
          _wifiOnlyDownloadsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wifiOnlyDownloadsMeta);
    }
    if (data.containsKey('connected_server')) {
      context.handle(
        _connectedServerMeta,
        connectedServer.isAcceptableOrUnknown(
          data['connected_server']!,
          _connectedServerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectedServerMeta);
    }
    if (data.containsKey('immersive_hud_auto_hide_delay')) {
      context.handle(
        _immersiveHudAutoHideDelayMeta,
        immersiveHudAutoHideDelay.isAcceptableOrUnknown(
          data['immersive_hud_auto_hide_delay']!,
          _immersiveHudAutoHideDelayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_immersiveHudAutoHideDelayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      streamingQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}streaming_quality'],
      )!,
      gaplessPlayback: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}gapless_playback'],
      )!,
      downloadQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_quality'],
      )!,
      wifiOnlyDownloads: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wifi_only_downloads'],
      )!,
      connectedServer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connected_server'],
      )!,
      immersiveHudAutoHideDelay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}immersive_hud_auto_hide_delay'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String streamingQuality;
  final bool gaplessPlayback;
  final String downloadQuality;
  final bool wifiOnlyDownloads;
  final String connectedServer;
  final String immersiveHudAutoHideDelay;
  const AppSetting({
    required this.id,
    required this.streamingQuality,
    required this.gaplessPlayback,
    required this.downloadQuality,
    required this.wifiOnlyDownloads,
    required this.connectedServer,
    required this.immersiveHudAutoHideDelay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['streaming_quality'] = Variable<String>(streamingQuality);
    map['gapless_playback'] = Variable<bool>(gaplessPlayback);
    map['download_quality'] = Variable<String>(downloadQuality);
    map['wifi_only_downloads'] = Variable<bool>(wifiOnlyDownloads);
    map['connected_server'] = Variable<String>(connectedServer);
    map['immersive_hud_auto_hide_delay'] = Variable<String>(
      immersiveHudAutoHideDelay,
    );
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      streamingQuality: Value(streamingQuality),
      gaplessPlayback: Value(gaplessPlayback),
      downloadQuality: Value(downloadQuality),
      wifiOnlyDownloads: Value(wifiOnlyDownloads),
      connectedServer: Value(connectedServer),
      immersiveHudAutoHideDelay: Value(immersiveHudAutoHideDelay),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      streamingQuality: serializer.fromJson<String>(json['streamingQuality']),
      gaplessPlayback: serializer.fromJson<bool>(json['gaplessPlayback']),
      downloadQuality: serializer.fromJson<String>(json['downloadQuality']),
      wifiOnlyDownloads: serializer.fromJson<bool>(json['wifiOnlyDownloads']),
      connectedServer: serializer.fromJson<String>(json['connectedServer']),
      immersiveHudAutoHideDelay: serializer.fromJson<String>(
        json['immersiveHudAutoHideDelay'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'streamingQuality': serializer.toJson<String>(streamingQuality),
      'gaplessPlayback': serializer.toJson<bool>(gaplessPlayback),
      'downloadQuality': serializer.toJson<String>(downloadQuality),
      'wifiOnlyDownloads': serializer.toJson<bool>(wifiOnlyDownloads),
      'connectedServer': serializer.toJson<String>(connectedServer),
      'immersiveHudAutoHideDelay': serializer.toJson<String>(
        immersiveHudAutoHideDelay,
      ),
    };
  }

  AppSetting copyWith({
    int? id,
    String? streamingQuality,
    bool? gaplessPlayback,
    String? downloadQuality,
    bool? wifiOnlyDownloads,
    String? connectedServer,
    String? immersiveHudAutoHideDelay,
  }) => AppSetting(
    id: id ?? this.id,
    streamingQuality: streamingQuality ?? this.streamingQuality,
    gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
    downloadQuality: downloadQuality ?? this.downloadQuality,
    wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
    connectedServer: connectedServer ?? this.connectedServer,
    immersiveHudAutoHideDelay:
        immersiveHudAutoHideDelay ?? this.immersiveHudAutoHideDelay,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      streamingQuality: data.streamingQuality.present
          ? data.streamingQuality.value
          : this.streamingQuality,
      gaplessPlayback: data.gaplessPlayback.present
          ? data.gaplessPlayback.value
          : this.gaplessPlayback,
      downloadQuality: data.downloadQuality.present
          ? data.downloadQuality.value
          : this.downloadQuality,
      wifiOnlyDownloads: data.wifiOnlyDownloads.present
          ? data.wifiOnlyDownloads.value
          : this.wifiOnlyDownloads,
      connectedServer: data.connectedServer.present
          ? data.connectedServer.value
          : this.connectedServer,
      immersiveHudAutoHideDelay: data.immersiveHudAutoHideDelay.present
          ? data.immersiveHudAutoHideDelay.value
          : this.immersiveHudAutoHideDelay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('streamingQuality: $streamingQuality, ')
          ..write('gaplessPlayback: $gaplessPlayback, ')
          ..write('downloadQuality: $downloadQuality, ')
          ..write('wifiOnlyDownloads: $wifiOnlyDownloads, ')
          ..write('connectedServer: $connectedServer, ')
          ..write('immersiveHudAutoHideDelay: $immersiveHudAutoHideDelay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    streamingQuality,
    gaplessPlayback,
    downloadQuality,
    wifiOnlyDownloads,
    connectedServer,
    immersiveHudAutoHideDelay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.streamingQuality == this.streamingQuality &&
          other.gaplessPlayback == this.gaplessPlayback &&
          other.downloadQuality == this.downloadQuality &&
          other.wifiOnlyDownloads == this.wifiOnlyDownloads &&
          other.connectedServer == this.connectedServer &&
          other.immersiveHudAutoHideDelay == this.immersiveHudAutoHideDelay);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> streamingQuality;
  final Value<bool> gaplessPlayback;
  final Value<String> downloadQuality;
  final Value<bool> wifiOnlyDownloads;
  final Value<String> connectedServer;
  final Value<String> immersiveHudAutoHideDelay;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.streamingQuality = const Value.absent(),
    this.gaplessPlayback = const Value.absent(),
    this.downloadQuality = const Value.absent(),
    this.wifiOnlyDownloads = const Value.absent(),
    this.connectedServer = const Value.absent(),
    this.immersiveHudAutoHideDelay = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String streamingQuality,
    required bool gaplessPlayback,
    required String downloadQuality,
    required bool wifiOnlyDownloads,
    required String connectedServer,
    required String immersiveHudAutoHideDelay,
  }) : streamingQuality = Value(streamingQuality),
       gaplessPlayback = Value(gaplessPlayback),
       downloadQuality = Value(downloadQuality),
       wifiOnlyDownloads = Value(wifiOnlyDownloads),
       connectedServer = Value(connectedServer),
       immersiveHudAutoHideDelay = Value(immersiveHudAutoHideDelay);
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? streamingQuality,
    Expression<bool>? gaplessPlayback,
    Expression<String>? downloadQuality,
    Expression<bool>? wifiOnlyDownloads,
    Expression<String>? connectedServer,
    Expression<String>? immersiveHudAutoHideDelay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (streamingQuality != null) 'streaming_quality': streamingQuality,
      if (gaplessPlayback != null) 'gapless_playback': gaplessPlayback,
      if (downloadQuality != null) 'download_quality': downloadQuality,
      if (wifiOnlyDownloads != null) 'wifi_only_downloads': wifiOnlyDownloads,
      if (connectedServer != null) 'connected_server': connectedServer,
      if (immersiveHudAutoHideDelay != null)
        'immersive_hud_auto_hide_delay': immersiveHudAutoHideDelay,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? streamingQuality,
    Value<bool>? gaplessPlayback,
    Value<String>? downloadQuality,
    Value<bool>? wifiOnlyDownloads,
    Value<String>? connectedServer,
    Value<String>? immersiveHudAutoHideDelay,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      streamingQuality: streamingQuality ?? this.streamingQuality,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      connectedServer: connectedServer ?? this.connectedServer,
      immersiveHudAutoHideDelay:
          immersiveHudAutoHideDelay ?? this.immersiveHudAutoHideDelay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (streamingQuality.present) {
      map['streaming_quality'] = Variable<String>(streamingQuality.value);
    }
    if (gaplessPlayback.present) {
      map['gapless_playback'] = Variable<bool>(gaplessPlayback.value);
    }
    if (downloadQuality.present) {
      map['download_quality'] = Variable<String>(downloadQuality.value);
    }
    if (wifiOnlyDownloads.present) {
      map['wifi_only_downloads'] = Variable<bool>(wifiOnlyDownloads.value);
    }
    if (connectedServer.present) {
      map['connected_server'] = Variable<String>(connectedServer.value);
    }
    if (immersiveHudAutoHideDelay.present) {
      map['immersive_hud_auto_hide_delay'] = Variable<String>(
        immersiveHudAutoHideDelay.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('streamingQuality: $streamingQuality, ')
          ..write('gaplessPlayback: $gaplessPlayback, ')
          ..write('downloadQuality: $downloadQuality, ')
          ..write('wifiOnlyDownloads: $wifiOnlyDownloads, ')
          ..write('connectedServer: $connectedServer, ')
          ..write('immersiveHudAutoHideDelay: $immersiveHudAutoHideDelay')
          ..write(')'))
        .toString();
  }
}

abstract class _$OpheliaDatabase extends GeneratedDatabase {
  _$OpheliaDatabase(QueryExecutor e) : super(e);
  $OpheliaDatabaseManager get managers => $OpheliaDatabaseManager(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $CachedTracksTable cachedTracks = $CachedTracksTable(this);
  late final $PlaylistTracksTable playlistTracks = $PlaylistTracksTable(this);
  late final $ListeningEventsTable listeningEvents = $ListeningEventsTable(
    this,
  );
  late final $ProfileTable profile = $ProfileTable(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  late final $LinkedFoldersTable linkedFolders = $LinkedFoldersTable(this);
  late final $PlaybackSessionTable playbackSession = $PlaybackSessionTable(
    this,
  );
  late final $PlaybackQueueEntriesTable playbackQueueEntries =
      $PlaybackQueueEntriesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index playlistTracksTrackId = Index(
    'playlist_tracks_track_id',
    'CREATE INDEX playlist_tracks_track_id ON playlist_tracks (track_id)',
  );
  late final Index listeningEventsTrackId = Index(
    'listening_events_track_id',
    'CREATE INDEX listening_events_track_id ON listening_events (track_id)',
  );
  late final Index listeningEventsPlayedAt = Index(
    'listening_events_played_at',
    'CREATE INDEX listening_events_played_at ON listening_events (played_at)',
  );
  late final Index playbackQueueEntriesSessionId = Index(
    'playback_queue_entries_session_id',
    'CREATE INDEX playback_queue_entries_session_id ON playback_queue_entries (session_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playlists,
    cachedTracks,
    playlistTracks,
    listeningEvents,
    profile,
    downloads,
    linkedFolders,
    playbackSession,
    playbackQueueEntries,
    appSettings,
    playlistTracksTrackId,
    listeningEventsTrackId,
    listeningEventsPlayedAt,
    playbackQueueEntriesSessionId,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_tracks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playback_session',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playback_queue_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PlaylistsTableCreateCompanionBuilder =
    PlaylistsCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlaylistsTableUpdateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PlaylistsTableReferences
    extends BaseReferences<_$OpheliaDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistTracksTable, List<PlaylistTrack>>
  _playlistTracksRefsTable(_$OpheliaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistTracks,
        aliasName: 'playlists__id__playlist_tracks__playlist_id',
      );

  $$PlaylistTracksTableProcessedTableManager get playlistTracksRefs {
    final manager = $$PlaylistTracksTableTableManager(
      $_db,
      $_db.playlistTracks,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistTracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$OpheliaDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistTracksRefs(
    Expression<bool> Function($$PlaylistTracksTableFilterComposer f) f,
  ) {
    final $$PlaylistTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracks,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableFilterComposer(
            $db: $db,
            $table: $db.playlistTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> playlistTracksRefs<T extends Object>(
    Expression<T> Function($$PlaylistTracksTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracks,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, $$PlaylistsTableReferences),
          Playlist,
          PrefetchHooks Function({bool playlistTracksRefs})
        > {
  $$PlaylistsTableTableManager(_$OpheliaDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistTracksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistTracksRefs) db.playlistTracks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistTracksRefs)
                    await $_getPrefetchedData<
                      Playlist,
                      $PlaylistsTable,
                      PlaylistTrack
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableReferences
                          ._playlistTracksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistTracksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, $$PlaylistsTableReferences),
      Playlist,
      PrefetchHooks Function({bool playlistTracksRefs})
    >;
typedef $$CachedTracksTableCreateCompanionBuilder =
    CachedTracksCompanion Function({
      required String id,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<int?> durationMs,
      Value<String?> coverArtPath,
      Value<bool> isDownloaded,
      Value<int> rowid,
    });
typedef $$CachedTracksTableUpdateCompanionBuilder =
    CachedTracksCompanion Function({
      Value<String> id,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<int?> durationMs,
      Value<String?> coverArtPath,
      Value<bool> isDownloaded,
      Value<int> rowid,
    });

final class $$CachedTracksTableReferences
    extends BaseReferences<_$OpheliaDatabase, $CachedTracksTable, CachedTrack> {
  $$CachedTracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistTracksTable, List<PlaylistTrack>>
  _playlistTracksRefsTable(_$OpheliaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playlistTracks,
        aliasName: 'cached_tracks__id__playlist_tracks__track_id',
      );

  $$PlaylistTracksTableProcessedTableManager get playlistTracksRefs {
    final manager = $$PlaylistTracksTableTableManager(
      $_db,
      $_db.playlistTracks,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistTracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ListeningEventsTable, List<ListeningEvent>>
  _listeningEventsRefsTable(_$OpheliaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.listeningEvents,
        aliasName: 'cached_tracks__id__listening_events__track_id',
      );

  $$ListeningEventsTableProcessedTableManager get listeningEventsRefs {
    final manager = $$ListeningEventsTableTableManager(
      $_db,
      $_db.listeningEvents,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _listeningEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DownloadsTable, List<Download>>
  _downloadsRefsTable(_$OpheliaDatabase db) => MultiTypedResultKey.fromTable(
    db.downloads,
    aliasName: 'cached_tracks__id__downloads__track_id',
  );

  $$DownloadsTableProcessedTableManager get downloadsRefs {
    final manager = $$DownloadsTableTableManager(
      $_db,
      $_db.downloads,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CachedTracksTableFilterComposer
    extends Composer<_$OpheliaDatabase, $CachedTracksTable> {
  $$CachedTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistTracksRefs(
    Expression<bool> Function($$PlaylistTracksTableFilterComposer f) f,
  ) {
    final $$PlaylistTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracks,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableFilterComposer(
            $db: $db,
            $table: $db.playlistTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> listeningEventsRefs(
    Expression<bool> Function($$ListeningEventsTableFilterComposer f) f,
  ) {
    final $$ListeningEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listeningEvents,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListeningEventsTableFilterComposer(
            $db: $db,
            $table: $db.listeningEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> downloadsRefs(
    Expression<bool> Function($$DownloadsTableFilterComposer f) f,
  ) {
    final $$DownloadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloads,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadsTableFilterComposer(
            $db: $db,
            $table: $db.downloads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CachedTracksTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $CachedTracksTable> {
  $$CachedTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedTracksTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $CachedTracksTable> {
  $$CachedTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => column,
  );

  Expression<T> playlistTracksRefs<T extends Object>(
    Expression<T> Function($$PlaylistTracksTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracks,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> listeningEventsRefs<T extends Object>(
    Expression<T> Function($$ListeningEventsTableAnnotationComposer a) f,
  ) {
    final $$ListeningEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listeningEvents,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListeningEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.listeningEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> downloadsRefs<T extends Object>(
    Expression<T> Function($$DownloadsTableAnnotationComposer a) f,
  ) {
    final $$DownloadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloads,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadsTableAnnotationComposer(
            $db: $db,
            $table: $db.downloads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CachedTracksTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $CachedTracksTable,
          CachedTrack,
          $$CachedTracksTableFilterComposer,
          $$CachedTracksTableOrderingComposer,
          $$CachedTracksTableAnnotationComposer,
          $$CachedTracksTableCreateCompanionBuilder,
          $$CachedTracksTableUpdateCompanionBuilder,
          (CachedTrack, $$CachedTracksTableReferences),
          CachedTrack,
          PrefetchHooks Function({
            bool playlistTracksRefs,
            bool listeningEventsRefs,
            bool downloadsRefs,
          })
        > {
  $$CachedTracksTableTableManager(
    _$OpheliaDatabase db,
    $CachedTracksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> coverArtPath = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedTracksCompanion(
                id: id,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                coverArtPath: coverArtPath,
                isDownloaded: isDownloaded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> coverArtPath = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedTracksCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                coverArtPath: coverArtPath,
                isDownloaded: isDownloaded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CachedTracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                playlistTracksRefs = false,
                listeningEventsRefs = false,
                downloadsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistTracksRefs) db.playlistTracks,
                    if (listeningEventsRefs) db.listeningEvents,
                    if (downloadsRefs) db.downloads,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistTracksRefs)
                        await $_getPrefetchedData<
                          CachedTrack,
                          $CachedTracksTable,
                          PlaylistTrack
                        >(
                          currentTable: table,
                          referencedTable: $$CachedTracksTableReferences
                              ._playlistTracksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CachedTracksTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistTracksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (listeningEventsRefs)
                        await $_getPrefetchedData<
                          CachedTrack,
                          $CachedTracksTable,
                          ListeningEvent
                        >(
                          currentTable: table,
                          referencedTable: $$CachedTracksTableReferences
                              ._listeningEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CachedTracksTableReferences(
                                db,
                                table,
                                p0,
                              ).listeningEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (downloadsRefs)
                        await $_getPrefetchedData<
                          CachedTrack,
                          $CachedTracksTable,
                          Download
                        >(
                          currentTable: table,
                          referencedTable: $$CachedTracksTableReferences
                              ._downloadsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CachedTracksTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CachedTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $CachedTracksTable,
      CachedTrack,
      $$CachedTracksTableFilterComposer,
      $$CachedTracksTableOrderingComposer,
      $$CachedTracksTableAnnotationComposer,
      $$CachedTracksTableCreateCompanionBuilder,
      $$CachedTracksTableUpdateCompanionBuilder,
      (CachedTrack, $$CachedTracksTableReferences),
      CachedTrack,
      PrefetchHooks Function({
        bool playlistTracksRefs,
        bool listeningEventsRefs,
        bool downloadsRefs,
      })
    >;
typedef $$PlaylistTracksTableCreateCompanionBuilder =
    PlaylistTracksCompanion Function({
      Value<int> id,
      required String playlistId,
      required String trackId,
      required int position,
    });
typedef $$PlaylistTracksTableUpdateCompanionBuilder =
    PlaylistTracksCompanion Function({
      Value<int> id,
      Value<String> playlistId,
      Value<String> trackId,
      Value<int> position,
    });

final class $$PlaylistTracksTableReferences
    extends
        BaseReferences<_$OpheliaDatabase, $PlaylistTracksTable, PlaylistTrack> {
  $$PlaylistTracksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$OpheliaDatabase db) =>
      db.playlists.createAlias('playlist_tracks__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CachedTracksTable _trackIdTable(_$OpheliaDatabase db) => db
      .cachedTracks
      .createAlias('playlist_tracks__track_id__cached_tracks__id');

  $$CachedTracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$CachedTracksTableTableManager(
      $_db,
      $_db.cachedTracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistTracksTableFilterComposer
    extends Composer<_$OpheliaDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CachedTracksTableFilterComposer get trackId {
    final $$CachedTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.cachedTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedTracksTableFilterComposer(
            $db: $db,
            $table: $db.cachedTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CachedTracksTableOrderingComposer get trackId {
    final $$CachedTracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.cachedTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedTracksTableOrderingComposer(
            $db: $db,
            $table: $db.cachedTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CachedTracksTableAnnotationComposer get trackId {
    final $$CachedTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.cachedTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $PlaylistTracksTable,
          PlaylistTrack,
          $$PlaylistTracksTableFilterComposer,
          $$PlaylistTracksTableOrderingComposer,
          $$PlaylistTracksTableAnnotationComposer,
          $$PlaylistTracksTableCreateCompanionBuilder,
          $$PlaylistTracksTableUpdateCompanionBuilder,
          (PlaylistTrack, $$PlaylistTracksTableReferences),
          PlaylistTrack,
          PrefetchHooks Function({bool playlistId, bool trackId})
        > {
  $$PlaylistTracksTableTableManager(
    _$OpheliaDatabase db,
    $PlaylistTracksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> playlistId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => PlaylistTracksCompanion(
                id: id,
                playlistId: playlistId,
                trackId: trackId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String playlistId,
                required String trackId,
                required int position,
              }) => PlaylistTracksCompanion.insert(
                id: id,
                playlistId: playlistId,
                trackId: trackId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable: $$PlaylistTracksTableReferences
                                    ._playlistIdTable(db),
                                referencedColumn:
                                    $$PlaylistTracksTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable: $$PlaylistTracksTableReferences
                                    ._trackIdTable(db),
                                referencedColumn:
                                    $$PlaylistTracksTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $PlaylistTracksTable,
      PlaylistTrack,
      $$PlaylistTracksTableFilterComposer,
      $$PlaylistTracksTableOrderingComposer,
      $$PlaylistTracksTableAnnotationComposer,
      $$PlaylistTracksTableCreateCompanionBuilder,
      $$PlaylistTracksTableUpdateCompanionBuilder,
      (PlaylistTrack, $$PlaylistTracksTableReferences),
      PlaylistTrack,
      PrefetchHooks Function({bool playlistId, bool trackId})
    >;
typedef $$ListeningEventsTableCreateCompanionBuilder =
    ListeningEventsCompanion Function({
      Value<int> id,
      required String trackId,
      required DateTime playedAt,
      required int msPlayed,
    });
typedef $$ListeningEventsTableUpdateCompanionBuilder =
    ListeningEventsCompanion Function({
      Value<int> id,
      Value<String> trackId,
      Value<DateTime> playedAt,
      Value<int> msPlayed,
    });

final class $$ListeningEventsTableReferences
    extends
        BaseReferences<
          _$OpheliaDatabase,
          $ListeningEventsTable,
          ListeningEvent
        > {
  $$ListeningEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CachedTracksTable _trackIdTable(_$OpheliaDatabase db) => db
      .cachedTracks
      .createAlias('listening_events__track_id__cached_tracks__id');

  $$CachedTracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$CachedTracksTableTableManager(
      $_db,
      $_db.cachedTracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ListeningEventsTableFilterComposer
    extends Composer<_$OpheliaDatabase, $ListeningEventsTable> {
  $$ListeningEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get msPlayed => $composableBuilder(
    column: $table.msPlayed,
    builder: (column) => ColumnFilters(column),
  );

  $$CachedTracksTableFilterComposer get trackId {
    final $$CachedTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.cachedTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedTracksTableFilterComposer(
            $db: $db,
            $table: $db.cachedTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListeningEventsTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $ListeningEventsTable> {
  $$ListeningEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get msPlayed => $composableBuilder(
    column: $table.msPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedTracksTableOrderingComposer get trackId {
    final $$CachedTracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.cachedTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedTracksTableOrderingComposer(
            $db: $db,
            $table: $db.cachedTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListeningEventsTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $ListeningEventsTable> {
  $$ListeningEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get msPlayed =>
      $composableBuilder(column: $table.msPlayed, builder: (column) => column);

  $$CachedTracksTableAnnotationComposer get trackId {
    final $$CachedTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.cachedTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListeningEventsTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $ListeningEventsTable,
          ListeningEvent,
          $$ListeningEventsTableFilterComposer,
          $$ListeningEventsTableOrderingComposer,
          $$ListeningEventsTableAnnotationComposer,
          $$ListeningEventsTableCreateCompanionBuilder,
          $$ListeningEventsTableUpdateCompanionBuilder,
          (ListeningEvent, $$ListeningEventsTableReferences),
          ListeningEvent,
          PrefetchHooks Function({bool trackId})
        > {
  $$ListeningEventsTableTableManager(
    _$OpheliaDatabase db,
    $ListeningEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListeningEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListeningEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> msPlayed = const Value.absent(),
              }) => ListeningEventsCompanion(
                id: id,
                trackId: trackId,
                playedAt: playedAt,
                msPlayed: msPlayed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trackId,
                required DateTime playedAt,
                required int msPlayed,
              }) => ListeningEventsCompanion.insert(
                id: id,
                trackId: trackId,
                playedAt: playedAt,
                msPlayed: msPlayed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ListeningEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable:
                                    $$ListeningEventsTableReferences
                                        ._trackIdTable(db),
                                referencedColumn:
                                    $$ListeningEventsTableReferences
                                        ._trackIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ListeningEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $ListeningEventsTable,
      ListeningEvent,
      $$ListeningEventsTableFilterComposer,
      $$ListeningEventsTableOrderingComposer,
      $$ListeningEventsTableAnnotationComposer,
      $$ListeningEventsTableCreateCompanionBuilder,
      $$ListeningEventsTableUpdateCompanionBuilder,
      (ListeningEvent, $$ListeningEventsTableReferences),
      ListeningEvent,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$ProfileTableCreateCompanionBuilder =
    ProfileCompanion Function({
      Value<int> id,
      required String displayName,
      Value<String?> backgroundPath,
      Value<String?> profileImagePath,
    });
typedef $$ProfileTableUpdateCompanionBuilder =
    ProfileCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<String?> backgroundPath,
      Value<String?> profileImagePath,
    });

class $$ProfileTableFilterComposer
    extends Composer<_$OpheliaDatabase, $ProfileTable> {
  $$ProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backgroundPath => $composableBuilder(
    column: $table.backgroundPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileImagePath => $composableBuilder(
    column: $table.profileImagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $ProfileTable> {
  $$ProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backgroundPath => $composableBuilder(
    column: $table.backgroundPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileImagePath => $composableBuilder(
    column: $table.profileImagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $ProfileTable> {
  $$ProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backgroundPath => $composableBuilder(
    column: $table.backgroundPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileImagePath => $composableBuilder(
    column: $table.profileImagePath,
    builder: (column) => column,
  );
}

class $$ProfileTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $ProfileTable,
          ProfileData,
          $$ProfileTableFilterComposer,
          $$ProfileTableOrderingComposer,
          $$ProfileTableAnnotationComposer,
          $$ProfileTableCreateCompanionBuilder,
          $$ProfileTableUpdateCompanionBuilder,
          (
            ProfileData,
            BaseReferences<_$OpheliaDatabase, $ProfileTable, ProfileData>,
          ),
          ProfileData,
          PrefetchHooks Function()
        > {
  $$ProfileTableTableManager(_$OpheliaDatabase db, $ProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> backgroundPath = const Value.absent(),
                Value<String?> profileImagePath = const Value.absent(),
              }) => ProfileCompanion(
                id: id,
                displayName: displayName,
                backgroundPath: backgroundPath,
                profileImagePath: profileImagePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                Value<String?> backgroundPath = const Value.absent(),
                Value<String?> profileImagePath = const Value.absent(),
              }) => ProfileCompanion.insert(
                id: id,
                displayName: displayName,
                backgroundPath: backgroundPath,
                profileImagePath: profileImagePath,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $ProfileTable,
      ProfileData,
      $$ProfileTableFilterComposer,
      $$ProfileTableOrderingComposer,
      $$ProfileTableAnnotationComposer,
      $$ProfileTableCreateCompanionBuilder,
      $$ProfileTableUpdateCompanionBuilder,
      (
        ProfileData,
        BaseReferences<_$OpheliaDatabase, $ProfileTable, ProfileData>,
      ),
      ProfileData,
      PrefetchHooks Function()
    >;
typedef $$DownloadsTableCreateCompanionBuilder =
    DownloadsCompanion Function({
      required String trackId,
      required String localPath,
      required int sizeBytes,
      required DateTime downloadedAt,
      Value<int> rowid,
    });
typedef $$DownloadsTableUpdateCompanionBuilder =
    DownloadsCompanion Function({
      Value<String> trackId,
      Value<String> localPath,
      Value<int> sizeBytes,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });

final class $$DownloadsTableReferences
    extends BaseReferences<_$OpheliaDatabase, $DownloadsTable, Download> {
  $$DownloadsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CachedTracksTable _trackIdTable(_$OpheliaDatabase db) =>
      db.cachedTracks.createAlias('downloads__track_id__cached_tracks__id');

  $$CachedTracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$CachedTracksTableTableManager(
      $_db,
      $_db.cachedTracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadsTableFilterComposer
    extends Composer<_$OpheliaDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CachedTracksTableFilterComposer get trackId {
    final $$CachedTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.cachedTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedTracksTableFilterComposer(
            $db: $db,
            $table: $db.cachedTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedTracksTableOrderingComposer get trackId {
    final $$CachedTracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.cachedTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedTracksTableOrderingComposer(
            $db: $db,
            $table: $db.cachedTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  $$CachedTracksTableAnnotationComposer get trackId {
    final $$CachedTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.cachedTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $DownloadsTable,
          Download,
          $$DownloadsTableFilterComposer,
          $$DownloadsTableOrderingComposer,
          $$DownloadsTableAnnotationComposer,
          $$DownloadsTableCreateCompanionBuilder,
          $$DownloadsTableUpdateCompanionBuilder,
          (Download, $$DownloadsTableReferences),
          Download,
          PrefetchHooks Function({bool trackId})
        > {
  $$DownloadsTableTableManager(_$OpheliaDatabase db, $DownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadsCompanion(
                trackId: trackId,
                localPath: localPath,
                sizeBytes: sizeBytes,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String localPath,
                required int sizeBytes,
                required DateTime downloadedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadsCompanion.insert(
                trackId: trackId,
                localPath: localPath,
                sizeBytes: sizeBytes,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DownloadsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable: $$DownloadsTableReferences
                                    ._trackIdTable(db),
                                referencedColumn: $$DownloadsTableReferences
                                    ._trackIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $DownloadsTable,
      Download,
      $$DownloadsTableFilterComposer,
      $$DownloadsTableOrderingComposer,
      $$DownloadsTableAnnotationComposer,
      $$DownloadsTableCreateCompanionBuilder,
      $$DownloadsTableUpdateCompanionBuilder,
      (Download, $$DownloadsTableReferences),
      Download,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$LinkedFoldersTableCreateCompanionBuilder =
    LinkedFoldersCompanion Function({
      required String path,
      required DateTime linkedAt,
      Value<int> rowid,
    });
typedef $$LinkedFoldersTableUpdateCompanionBuilder =
    LinkedFoldersCompanion Function({
      Value<String> path,
      Value<DateTime> linkedAt,
      Value<int> rowid,
    });

class $$LinkedFoldersTableFilterComposer
    extends Composer<_$OpheliaDatabase, $LinkedFoldersTable> {
  $$LinkedFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get linkedAt => $composableBuilder(
    column: $table.linkedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LinkedFoldersTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $LinkedFoldersTable> {
  $$LinkedFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get linkedAt => $composableBuilder(
    column: $table.linkedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LinkedFoldersTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $LinkedFoldersTable> {
  $$LinkedFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<DateTime> get linkedAt =>
      $composableBuilder(column: $table.linkedAt, builder: (column) => column);
}

class $$LinkedFoldersTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $LinkedFoldersTable,
          LinkedFolder,
          $$LinkedFoldersTableFilterComposer,
          $$LinkedFoldersTableOrderingComposer,
          $$LinkedFoldersTableAnnotationComposer,
          $$LinkedFoldersTableCreateCompanionBuilder,
          $$LinkedFoldersTableUpdateCompanionBuilder,
          (
            LinkedFolder,
            BaseReferences<
              _$OpheliaDatabase,
              $LinkedFoldersTable,
              LinkedFolder
            >,
          ),
          LinkedFolder,
          PrefetchHooks Function()
        > {
  $$LinkedFoldersTableTableManager(
    _$OpheliaDatabase db,
    $LinkedFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinkedFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinkedFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinkedFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> path = const Value.absent(),
                Value<DateTime> linkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinkedFoldersCompanion(
                path: path,
                linkedAt: linkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String path,
                required DateTime linkedAt,
                Value<int> rowid = const Value.absent(),
              }) => LinkedFoldersCompanion.insert(
                path: path,
                linkedAt: linkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LinkedFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $LinkedFoldersTable,
      LinkedFolder,
      $$LinkedFoldersTableFilterComposer,
      $$LinkedFoldersTableOrderingComposer,
      $$LinkedFoldersTableAnnotationComposer,
      $$LinkedFoldersTableCreateCompanionBuilder,
      $$LinkedFoldersTableUpdateCompanionBuilder,
      (
        LinkedFolder,
        BaseReferences<_$OpheliaDatabase, $LinkedFoldersTable, LinkedFolder>,
      ),
      LinkedFolder,
      PrefetchHooks Function()
    >;
typedef $$PlaybackSessionTableCreateCompanionBuilder =
    PlaybackSessionCompanion Function({
      Value<int> id,
      required int queueIndex,
      required int positionMs,
      required DateTime savedAt,
    });
typedef $$PlaybackSessionTableUpdateCompanionBuilder =
    PlaybackSessionCompanion Function({
      Value<int> id,
      Value<int> queueIndex,
      Value<int> positionMs,
      Value<DateTime> savedAt,
    });

final class $$PlaybackSessionTableReferences
    extends
        BaseReferences<
          _$OpheliaDatabase,
          $PlaybackSessionTable,
          PlaybackSessionData
        > {
  $$PlaybackSessionTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PlaybackQueueEntriesTable,
    List<PlaybackQueueEntry>
  >
  _playbackQueueEntriesRefsTable(_$OpheliaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playbackQueueEntries,
        aliasName: 'playback_session__id__playback_queue_entries__session_id',
      );

  $$PlaybackQueueEntriesTableProcessedTableManager
  get playbackQueueEntriesRefs {
    final manager = $$PlaybackQueueEntriesTableTableManager(
      $_db,
      $_db.playbackQueueEntries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playbackQueueEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaybackSessionTableFilterComposer
    extends Composer<_$OpheliaDatabase, $PlaybackSessionTable> {
  $$PlaybackSessionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queueIndex => $composableBuilder(
    column: $table.queueIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playbackQueueEntriesRefs(
    Expression<bool> Function($$PlaybackQueueEntriesTableFilterComposer f) f,
  ) {
    final $$PlaybackQueueEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playbackQueueEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaybackQueueEntriesTableFilterComposer(
            $db: $db,
            $table: $db.playbackQueueEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaybackSessionTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $PlaybackSessionTable> {
  $$PlaybackSessionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queueIndex => $composableBuilder(
    column: $table.queueIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackSessionTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $PlaybackSessionTable> {
  $$PlaybackSessionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get queueIndex => $composableBuilder(
    column: $table.queueIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  Expression<T> playbackQueueEntriesRefs<T extends Object>(
    Expression<T> Function($$PlaybackQueueEntriesTableAnnotationComposer a) f,
  ) {
    final $$PlaybackQueueEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playbackQueueEntries,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlaybackQueueEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.playbackQueueEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlaybackSessionTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $PlaybackSessionTable,
          PlaybackSessionData,
          $$PlaybackSessionTableFilterComposer,
          $$PlaybackSessionTableOrderingComposer,
          $$PlaybackSessionTableAnnotationComposer,
          $$PlaybackSessionTableCreateCompanionBuilder,
          $$PlaybackSessionTableUpdateCompanionBuilder,
          (PlaybackSessionData, $$PlaybackSessionTableReferences),
          PlaybackSessionData,
          PrefetchHooks Function({bool playbackQueueEntriesRefs})
        > {
  $$PlaybackSessionTableTableManager(
    _$OpheliaDatabase db,
    $PlaybackSessionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackSessionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackSessionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackSessionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> queueIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => PlaybackSessionCompanion(
                id: id,
                queueIndex: queueIndex,
                positionMs: positionMs,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int queueIndex,
                required int positionMs,
                required DateTime savedAt,
              }) => PlaybackSessionCompanion.insert(
                id: id,
                queueIndex: queueIndex,
                positionMs: positionMs,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaybackSessionTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playbackQueueEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playbackQueueEntriesRefs) db.playbackQueueEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playbackQueueEntriesRefs)
                    await $_getPrefetchedData<
                      PlaybackSessionData,
                      $PlaybackSessionTable,
                      PlaybackQueueEntry
                    >(
                      currentTable: table,
                      referencedTable: $$PlaybackSessionTableReferences
                          ._playbackQueueEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaybackSessionTableReferences(
                            db,
                            table,
                            p0,
                          ).playbackQueueEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaybackSessionTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $PlaybackSessionTable,
      PlaybackSessionData,
      $$PlaybackSessionTableFilterComposer,
      $$PlaybackSessionTableOrderingComposer,
      $$PlaybackSessionTableAnnotationComposer,
      $$PlaybackSessionTableCreateCompanionBuilder,
      $$PlaybackSessionTableUpdateCompanionBuilder,
      (PlaybackSessionData, $$PlaybackSessionTableReferences),
      PlaybackSessionData,
      PrefetchHooks Function({bool playbackQueueEntriesRefs})
    >;
typedef $$PlaybackQueueEntriesTableCreateCompanionBuilder =
    PlaybackQueueEntriesCompanion Function({
      Value<int> id,
      required int sessionId,
      required int position,
      required String trackId,
      required String title,
      required String artist,
      required String album,
      required int durationMs,
      Value<String?> coverArtPath,
      required String sourceType,
    });
typedef $$PlaybackQueueEntriesTableUpdateCompanionBuilder =
    PlaybackQueueEntriesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> position,
      Value<String> trackId,
      Value<String> title,
      Value<String> artist,
      Value<String> album,
      Value<int> durationMs,
      Value<String?> coverArtPath,
      Value<String> sourceType,
    });

final class $$PlaybackQueueEntriesTableReferences
    extends
        BaseReferences<
          _$OpheliaDatabase,
          $PlaybackQueueEntriesTable,
          PlaybackQueueEntry
        > {
  $$PlaybackQueueEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaybackSessionTable _sessionIdTable(_$OpheliaDatabase db) => db
      .playbackSession
      .createAlias('playback_queue_entries__session_id__playback_session__id');

  $$PlaybackSessionTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$PlaybackSessionTableTableManager(
      $_db,
      $_db.playbackSession,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaybackQueueEntriesTableFilterComposer
    extends Composer<_$OpheliaDatabase, $PlaybackQueueEntriesTable> {
  $$PlaybackQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaybackSessionTableFilterComposer get sessionId {
    final $$PlaybackSessionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.playbackSession,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaybackSessionTableFilterComposer(
            $db: $db,
            $table: $db.playbackSession,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackQueueEntriesTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $PlaybackQueueEntriesTable> {
  $$PlaybackQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaybackSessionTableOrderingComposer get sessionId {
    final $$PlaybackSessionTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.playbackSession,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaybackSessionTableOrderingComposer(
            $db: $db,
            $table: $db.playbackSession,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackQueueEntriesTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $PlaybackQueueEntriesTable> {
  $$PlaybackQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverArtPath => $composableBuilder(
    column: $table.coverArtPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  $$PlaybackSessionTableAnnotationComposer get sessionId {
    final $$PlaybackSessionTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.playbackSession,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaybackSessionTableAnnotationComposer(
            $db: $db,
            $table: $db.playbackSession,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaybackQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $PlaybackQueueEntriesTable,
          PlaybackQueueEntry,
          $$PlaybackQueueEntriesTableFilterComposer,
          $$PlaybackQueueEntriesTableOrderingComposer,
          $$PlaybackQueueEntriesTableAnnotationComposer,
          $$PlaybackQueueEntriesTableCreateCompanionBuilder,
          $$PlaybackQueueEntriesTableUpdateCompanionBuilder,
          (PlaybackQueueEntry, $$PlaybackQueueEntriesTableReferences),
          PlaybackQueueEntry,
          PrefetchHooks Function({bool sessionId})
        > {
  $$PlaybackQueueEntriesTableTableManager(
    _$OpheliaDatabase db,
    $PlaybackQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackQueueEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaybackQueueEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String?> coverArtPath = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
              }) => PlaybackQueueEntriesCompanion(
                id: id,
                sessionId: sessionId,
                position: position,
                trackId: trackId,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                coverArtPath: coverArtPath,
                sourceType: sourceType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int position,
                required String trackId,
                required String title,
                required String artist,
                required String album,
                required int durationMs,
                Value<String?> coverArtPath = const Value.absent(),
                required String sourceType,
              }) => PlaybackQueueEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                position: position,
                trackId: trackId,
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                coverArtPath: coverArtPath,
                sourceType: sourceType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaybackQueueEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$PlaybackQueueEntriesTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$PlaybackQueueEntriesTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaybackQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $PlaybackQueueEntriesTable,
      PlaybackQueueEntry,
      $$PlaybackQueueEntriesTableFilterComposer,
      $$PlaybackQueueEntriesTableOrderingComposer,
      $$PlaybackQueueEntriesTableAnnotationComposer,
      $$PlaybackQueueEntriesTableCreateCompanionBuilder,
      $$PlaybackQueueEntriesTableUpdateCompanionBuilder,
      (PlaybackQueueEntry, $$PlaybackQueueEntriesTableReferences),
      PlaybackQueueEntry,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      required String streamingQuality,
      required bool gaplessPlayback,
      required String downloadQuality,
      required bool wifiOnlyDownloads,
      required String connectedServer,
      required String immersiveHudAutoHideDelay,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> streamingQuality,
      Value<bool> gaplessPlayback,
      Value<String> downloadQuality,
      Value<bool> wifiOnlyDownloads,
      Value<String> connectedServer,
      Value<String> immersiveHudAutoHideDelay,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$OpheliaDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamingQuality => $composableBuilder(
    column: $table.streamingQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get gaplessPlayback => $composableBuilder(
    column: $table.gaplessPlayback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadQuality => $composableBuilder(
    column: $table.downloadQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wifiOnlyDownloads => $composableBuilder(
    column: $table.wifiOnlyDownloads,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectedServer => $composableBuilder(
    column: $table.connectedServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get immersiveHudAutoHideDelay => $composableBuilder(
    column: $table.immersiveHudAutoHideDelay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$OpheliaDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamingQuality => $composableBuilder(
    column: $table.streamingQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get gaplessPlayback => $composableBuilder(
    column: $table.gaplessPlayback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadQuality => $composableBuilder(
    column: $table.downloadQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wifiOnlyDownloads => $composableBuilder(
    column: $table.wifiOnlyDownloads,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectedServer => $composableBuilder(
    column: $table.connectedServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get immersiveHudAutoHideDelay => $composableBuilder(
    column: $table.immersiveHudAutoHideDelay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$OpheliaDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get streamingQuality => $composableBuilder(
    column: $table.streamingQuality,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get gaplessPlayback => $composableBuilder(
    column: $table.gaplessPlayback,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadQuality => $composableBuilder(
    column: $table.downloadQuality,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wifiOnlyDownloads => $composableBuilder(
    column: $table.wifiOnlyDownloads,
    builder: (column) => column,
  );

  GeneratedColumn<String> get connectedServer => $composableBuilder(
    column: $table.connectedServer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get immersiveHudAutoHideDelay => $composableBuilder(
    column: $table.immersiveHudAutoHideDelay,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$OpheliaDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$OpheliaDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$OpheliaDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> streamingQuality = const Value.absent(),
                Value<bool> gaplessPlayback = const Value.absent(),
                Value<String> downloadQuality = const Value.absent(),
                Value<bool> wifiOnlyDownloads = const Value.absent(),
                Value<String> connectedServer = const Value.absent(),
                Value<String> immersiveHudAutoHideDelay = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                streamingQuality: streamingQuality,
                gaplessPlayback: gaplessPlayback,
                downloadQuality: downloadQuality,
                wifiOnlyDownloads: wifiOnlyDownloads,
                connectedServer: connectedServer,
                immersiveHudAutoHideDelay: immersiveHudAutoHideDelay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String streamingQuality,
                required bool gaplessPlayback,
                required String downloadQuality,
                required bool wifiOnlyDownloads,
                required String connectedServer,
                required String immersiveHudAutoHideDelay,
              }) => AppSettingsCompanion.insert(
                id: id,
                streamingQuality: streamingQuality,
                gaplessPlayback: gaplessPlayback,
                downloadQuality: downloadQuality,
                wifiOnlyDownloads: wifiOnlyDownloads,
                connectedServer: connectedServer,
                immersiveHudAutoHideDelay: immersiveHudAutoHideDelay,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$OpheliaDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$OpheliaDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $OpheliaDatabaseManager {
  final _$OpheliaDatabase _db;
  $OpheliaDatabaseManager(this._db);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$CachedTracksTableTableManager get cachedTracks =>
      $$CachedTracksTableTableManager(_db, _db.cachedTracks);
  $$PlaylistTracksTableTableManager get playlistTracks =>
      $$PlaylistTracksTableTableManager(_db, _db.playlistTracks);
  $$ListeningEventsTableTableManager get listeningEvents =>
      $$ListeningEventsTableTableManager(_db, _db.listeningEvents);
  $$ProfileTableTableManager get profile =>
      $$ProfileTableTableManager(_db, _db.profile);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
  $$LinkedFoldersTableTableManager get linkedFolders =>
      $$LinkedFoldersTableTableManager(_db, _db.linkedFolders);
  $$PlaybackSessionTableTableManager get playbackSession =>
      $$PlaybackSessionTableTableManager(_db, _db.playbackSession);
  $$PlaybackQueueEntriesTableTableManager get playbackQueueEntries =>
      $$PlaybackQueueEntriesTableTableManager(_db, _db.playbackQueueEntries);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
