import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  // Set de informações importantes diretas do Spotify.
  Set<String> playlistName = {};
  Set<String> artistImage = {};
  Set<String> songList = {};

  List<String> imageList = [];
  List<String> nameMusic = [];
  List<String> artistName = [];

  Map<int, AudioSource> listMusic = {};

  Map<int, Duration> durationMusic = {};

  // Index principal das músicas.
  int? _lastIndex;
  // Playlist principal.
  late ConcatenatingAudioSource playlist;
  // modo random.
  bool shuffle = false;
  // 0 = deactivated. / 1 = next music. / 2 = repeat one.
  int repeat = 0;
  bool completed = false;

  bool isPlayingNext = false;

  String textArtists(List<String> listArtists) {
    String artistName = '';
    for (var value in listArtists) {
      artistName += '$value, ';
    }
    artistName = artistName.replaceRange(artistName.length - 2, null, '');
    return artistName;
  }

  Future<void> loadMusic(int index) async {
    _lastIndex = index;

    bool isPlaying = playing;

    final yt = YoutubeExplode();

    String nameArtist = artistName[index];

    final video = (await yt.search.search(
        '${songList.elementAt(index)} $nameArtist',
        filter: TypeFilters.video));

    final videoId = video.elementAt(0).id.value;
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var audioUrl = manifest.audioOnly.last.url;

    listMusic.addAll({index: AudioSource.uri(audioUrl)});

    addMediaItems(MediaItem(
      id: mediaItemList.length.toString(),
      album: video.elementAt(0).author,
      duration: video.elementAt(0).duration!,
      title: video.elementAt(0).title,
      artUri: Uri.parse(imageList.elementAt(index)),
    ));

    durationMusic.addAll({index: video.elementAt(0).duration!});

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.loading,
    ));

    playlist = ConcatenatingAudioSource(children: listMusic.values.toList());
    _player.setAudioSource(
      playlist,
      initialIndex: playlist.length - 1,
      initialPosition: Duration.zero,
    );

    mediaItem.value = mediaItemList[index];

    // Broadcast that we've finished loading
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.ready,
      systemActions: const {
        MediaAction.seek,
      },
    ));

    if (isPlaying) {
      _player.play();
    }
  }

  // AudioHandler
  Map<int, MediaItem> mediaItemList = {};

  AudioPlayer _player = AudioPlayer();

  bool get playing => _player.playing;

  int? get currentIndex => _player.currentIndex;

  int? get lastIndex => _lastIndex;

  Stream<Duration> get positionStream => _player.positionStream;
  Duration get position => _player.position;
  Duration get bufferedPosition => _player.bufferedPosition;

  String get stateLoading => playbackState.value.processingState.name;

  Future<void> trueRepeatMode([bool ready = true]) async {
    if (ready) {
      repeat != 2 ? repeat += 1 : repeat = 0;
    } else {
      switch (repeat) {
        case 0:
          if (playing) {
            await pause();
            completed = true;
          }
        case 1:
          await skipToNext();

        case 2:
          await _player.seek(Duration.zero);
          playbackState.add(playbackState.value.copyWith(
            updatePosition: position,
          ));
      }
    }
  }

  Future<void> trueShuffleMode([bool ready = true]) async {
    if (ready) {
      shuffle = !shuffle;
    } else {
      int number = _lastIndex!;

      while (_lastIndex == number) {
        number = Random().nextInt(songList.length);
      }

      if (!listMusic.containsKey(number)) {
        await loadMusic(number);
      } else {
        _lastIndex = number;
        await pause();

        playbackState.add(playbackState.value.copyWith(
          processingState: AudioProcessingState.loading,
        ));

        await _player
            .setAudioSource(
          playlist,
          initialIndex: listMusic.keys.toList().indexOf(number),
          initialPosition: Duration.zero,
        )
            .then((value) async {
          playbackState.add(playbackState.value
              .copyWith(processingState: AudioProcessingState.ready));

          await play();
        });
        mediaItem.value = mediaItemList[_lastIndex];
      }
    }
  }

  void addMediaItems(MediaItem mediaitem) {
    mediaItemList.addAll({_lastIndex!: mediaitem});
  }

  StreamBuilder customizeStreamBuilder() {
    return StreamBuilder(
      stream: positionStream,
      builder: (context, data) {
        if (currentIndex != null &&
            position.inSeconds ==
                ((durationMusic[_lastIndex] ?? Duration.zero).inSeconds - 1) &&
            position != Duration.zero) {
          if (shuffle == true) {
            trueShuffleMode(false);
          } else {
            trueRepeatMode(false);
          }
        }

        return ProgressBar(
          progress: position > (durationMusic[_lastIndex] ?? Duration.zero)
              ? Duration.zero
              : position,
          buffered: bufferedPosition,
          total: durationMusic[_lastIndex] ?? Duration.zero,
          baseBarColor: Colors.white,
          bufferedBarColor: Colors.purple[200],
          timeLabelTextStyle: TextStyle(color: Colors.white),
          onSeek: (value) async {
            await seek(value);
            playbackState.add(playbackState.value.copyWith(
              updatePosition: position,
            ));
          },
        );
      },
    );
  }

  @override
  Future<void> play() async {
    if (completed && currentIndex != null) {
      completed = false;
      _player.seek(Duration.zero);
    }

    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [
        MediaControl.pause,
        if (lastIndex != 0 || listMusic.containsKey(lastIndex! - 1))
          MediaControl.skipToPrevious,
        if (songList.contains(songList.elementAtOrNull(lastIndex! + 1) ?? ''))
          MediaControl.skipToNext,
      ],
      updatePosition: position,
      bufferedPosition: bufferedPosition,
    ));

    _player.play();
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [
        MediaControl.play,
        if (lastIndex != 0 || listMusic.containsKey(lastIndex! - 1))
          MediaControl.skipToPrevious,
        if (songList.contains(songList.elementAtOrNull(lastIndex! + 1) ?? ''))
          MediaControl.skipToNext,
      ],
      updatePosition: position,
      bufferedPosition: bufferedPosition,
    ));
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    // Release any audio decoders back to the system
    await _player.stop();

    // Set the audio_service state to `idle` to deactivate the notification.
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> skipToPrevious() async {
    isPlayingNext = playing;

    if (isPlayingNext) {
      await _player.pause();
      await seek(Duration.zero);
    }

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.loading,
    ));

    if (_lastIndex != 0 && _player.hasPrevious) {
      await loadMusic((_lastIndex ?? 1) - 1);
    } else {
      _lastIndex = _lastIndex! - 1;
    }

    await _player.seekToPrevious();

    mediaItem.value = mediaItemList[_lastIndex!];

    playbackState.add(playbackState.value.copyWith(
      playing: playing ? true : false,
      processingState: AudioProcessingState.ready,
      updatePosition: position,
      bufferedPosition: bufferedPosition,
      controls: [
        if (lastIndex != 0 || listMusic.containsKey(lastIndex! - 1))
          MediaControl.skipToPrevious,
        if (songList.contains(songList.elementAtOrNull(lastIndex! + 1) ?? ''))
          MediaControl.skipToNext,
      ],
    ));

    if (isPlayingNext) {
      _player.play();
    }
  }

  @override
  Future<void> skipToNext() async {
    isPlayingNext = playing;

    if (isPlayingNext) {
      await _player.pause();
      await seek(Duration.zero);
    }

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.loading,
    ));

    if (listMusic.length != songList.length || !_player.hasNext) {
      await loadMusic((_lastIndex ?? 0) + 1);
    } else {
      _lastIndex = _lastIndex! + 1;
    }

    await _player.seekToNext();

    mediaItem.value = mediaItemList[_lastIndex];

    playbackState.add(playbackState.value.copyWith(
      playing: playing ? true : false,
      processingState: AudioProcessingState.ready,
      updatePosition: position,
      bufferedPosition: bufferedPosition,
      controls: [
        if (lastIndex != 0 || listMusic.containsKey(lastIndex! - 1))
          MediaControl.skipToPrevious,
        if (songList.contains(songList.elementAtOrNull(lastIndex! + 1) ?? ''))
          MediaControl.skipToNext,
      ],
    ));

    if (isPlayingNext) {
      _player.play();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void setAudioSource(AudioSource source, Map<String, dynamic> mapMedia) async {
    _lastIndex = 0;

    listMusic.addAll({0: source});

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.loading,
    ));

    addMediaItems(
      MediaItem(
        id: mediaItemList.length.toString(),
        album: mapMedia['album'],
        duration: mapMedia['duration'],
        title: mapMedia['title'],
      ),
    );

    await _player.setAudioSource(source, initialPosition: Duration.zero);

    mediaItem.value = mediaItemList[0];

    // Broadcast that we've finished loading
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.ready,
      systemActions: const {
        MediaAction.seek,
      },
    ));
  }

  Future<void> dispose() async {
    artistImage = {};
    nameMusic = [];
    listMusic = {};
    imageList = [];
    durationMusic = {};
    artistName = [];
    playlistName = {};
    songList = {};
    mediaItemList = {};
    playlist = ConcatenatingAudioSource(children: []);
    _lastIndex = null;
    completed = false;

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));

    repeat = 2;
    trueRepeatMode();

    await _player.dispose();

    _player = AudioPlayer();
  }
}
