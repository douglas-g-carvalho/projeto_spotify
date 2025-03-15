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
  // Lista de informações visuais.
  List<String> imageList = [];
  List<String> nameMusic = [];
  List<String> artistName = [];
  // Lista de música já carregadas.
  Map<int, AudioSource> listMusic = {};
  // Duração das músicas já carregadas.
  Map<int, Duration> durationMusic = {};
  // Bloqueia o index da música caso ela dê algum problema.
  List<int> indexBlocked = [];
  // Para saber quando Multi Mode está carregando.
  int? multiIndex;
  // Index principal das músicas.
  int? lastIndex;
  // Playlist principal.
  late ConcatenatingAudioSource playlist;
  // modo random.
  bool shuffle = false;
  // para não rodar várias vezes o shuffle.
  bool delayShuffle = false;
  // 0 = deactivated. / 1 = next music. / 2 = repeat one.
  int repeat = 0;
  // bool para saber se a música foi completa.
  bool completed = false;
  // bool para saber se precisa dar play ou não no SkipTo.
  bool isPlayingSkipTo = false;

  // Verifica se a index está bloqueada.
  bool isIndexNotBlocked(int index) {
    if (indexBlocked.contains(index)) {
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
      ));

      lastIndex = index;

      return false;
    } else {
      return true;
    }
  }

  // Transforma a lista de nomes dos artistas em String.
  String textArtists(List<String> listArtists) {
    String artistName = '';
    for (var value in listArtists) {
      artistName += '$value, ';
    }
    artistName = artistName.replaceRange(artistName.length - 2, null, '');
    return artistName;
  }

  // Função de pesquisa essencial da aplicação.
  Future<void> loadMusic(int index) async {
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.loading,
    ));

    bool lastGambit = false;

    multiIndex = index;

    int indexLoadMusic = 0;

    final yt = YoutubeExplode();

    String nameArtist = artistName[index].contains(',')
        ? artistName[index].split(',')[0]
        : artistName[index];

    String musicName = songList.elementAt(index);

    Future<void> removeMusicNameWords() async {
      if (musicName.split(' ').length > 1) {
        List<String> newMusicName = musicName.split(' ');
        newMusicName.removeWhere((value) => value == '');
        newMusicName.removeWhere((value) => value == '-');
        newMusicName.removeLast();
        musicName = '';
        for (String value in newMusicName) {
          musicName += value;

          if (value != newMusicName.last) {
            musicName += ' ';
          }
        }
      }
    }

    Future<void> removeNameArtistWords() async {
      if (nameArtist.split(' ').length > 1) {
        List<String> newnameArtist = nameArtist.split(' ');
        newnameArtist.removeWhere((value) => value == '');
        newnameArtist.removeLast();
        nameArtist = '';
        for (String value in newnameArtist) {
          nameArtist += value;

          if (value != newnameArtist.last) {
            nameArtist += ' ';
          }
        }
      }
    }

    VideoSearchList video = await yt.search
        .search('${musicName.toLowerCase()} ${nameArtist.toLowerCase()} Music');

    while (true) {
      if (indexLoadMusic > video.length - 1 &&
          musicName.split(' ').length != 1) {
        await removeMusicNameWords();
        indexLoadMusic = 0;
      }

      if (indexLoadMusic > video.length - 1 &&
          musicName.split(' ').length == 1 &&
          lastGambit == false) {
        indexLoadMusic = 0;
        musicName = songList.elementAt(index);

        await removeNameArtistWords();

        video = await yt.search
            .search('${musicName.toLowerCase()} ${nameArtist.toLowerCase()}');

        lastGambit = true;
      }

      if (musicName.split(' ').length == 1 && lastGambit == true) {
        playbackState.add(playbackState.value.copyWith(
          processingState: AudioProcessingState.idle,
        ));

        indexBlocked.add(index);
        lastIndex = index;

        throw Error;
      }

      if (video.elementAtOrNull(indexLoadMusic)?.duration == null ||
          (video.elementAt(indexLoadMusic).duration ?? Duration(minutes: 15)) >
              Duration(minutes: 10) ||
          !video
              .elementAt(indexLoadMusic)
              .title
              .toLowerCase()
              .contains(musicName.toLowerCase())) {
        indexLoadMusic += 1;
        continue;
      }

      final videoId = video.elementAt(indexLoadMusic).id.value;
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioUrl = manifest.audioOnly.last.url;

      listMusic.addAll({index: AudioSource.uri(audioUrl)});

      mediaItemList.addAll({
        index: MediaItem(
          id: mediaItemList.length.toString(),
          album: video.elementAt(indexLoadMusic).author,
          duration: video.elementAt(indexLoadMusic).duration!,
          title: video.elementAt(indexLoadMusic).title,
          artUri: Uri.parse(imageList.elementAt(index)),
        )
      });

      durationMusic.addAll({index: video.elementAt(indexLoadMusic).duration!});
      break;
    }

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

    lastIndex = index;
  }

  // AudioHandler
  Map<int, MediaItem> mediaItemList = {};

  AudioPlayer _player = AudioPlayer();

  bool get playing => _player.playing;

  int? get currentIndex => _player.currentIndex;

  Stream<Duration> get positionStream => _player.positionStream;

  Duration get position => _player.position;
  Duration get bufferedPosition => _player.bufferedPosition;

  bool get stateLoading =>
      playbackState.value.processingState.name == 'loading';

  // Modo repetir.
  Future<void> trueRepeatMode([bool ready = true]) async {
    if (ready) {
      repeat != 2 ? repeat += 1 : repeat = 0;
      playbackState.add(playbackState.value.copyWith());
    } else {
      switch (repeat) {
        case 0:
          if (playing) {
            await pause();
            completed = true;
          }
        case 1:
          if (songList.contains(
              songList.elementAtOrNull((lastIndex ?? -2) + 1) ?? '')) {
            await skipToNext();
          } else {
            await setAudioSolo(playlist, 0);
          }
        case 2:
          await _player.seek(Duration.zero);
          playbackState.add(playbackState.value.copyWith(
            updatePosition: position,
          ));
      }
    }
  }

  // Modo aleatório.
  Future<void> trueShuffleMode([bool ready = true]) async {
    if (ready) {
      shuffle = !shuffle;
      playbackState.add(playbackState.value.copyWith());
    } else {
      bool isPlayingShuffle = playing;
      delayShuffle = true;

      int number = lastIndex!;

      while (lastIndex == number) {
        number = Random().nextInt(songList.length);
      }

      if (isPlayingShuffle) {
        await pause();
      }

      if (!listMusic.containsKey(number)) {
        await loadMusic(number);
      } else {
        await setAudioSolo(
          playlist,
          listMusic.keys.toList().indexOf(number),
        );
      }

      if (isPlayingShuffle) {
        await play();
      }

      await seek(Duration.zero);

      delayShuffle = false;
    }
  }

  // StreamBuilder com ProgressBar principal.
  StreamBuilder customizeStreamBuilder() {
    if (indexBlocked.contains(multiIndex) || stateLoading) {
      return StreamBuilder(
          stream: playbackState.stream,
          builder: (context, data) {
            return ProgressBar(
              progress: Duration.zero,
              total: Duration.zero,
              baseBarColor: Colors.white,
              bufferedBarColor: Colors.purple[200],
              timeLabelTextStyle: TextStyle(color: Colors.white),
              thumbCanPaintOutsideBar: false,
            );
          });
    } else {
      return StreamBuilder<Duration>(
        stream: positionStream,
        builder: (context, data) {
          if (currentIndex != null &&
              lastIndex != null &&
              position.inSeconds == (durationMusic[lastIndex]!.inSeconds - 1) &&
              position != Duration.zero &&
              durationMusic[lastIndex] != Duration.zero &&
              !delayShuffle) {
            if (shuffle == true) {
              trueShuffleMode(false);
            } else {
              trueRepeatMode(false);
            }
          }

          return ProgressBar(
            progress: position > (durationMusic[lastIndex] ?? Duration.zero)
                ? Duration.zero
                : position,
            buffered: bufferedPosition,
            total: (durationMusic[lastIndex] ?? Duration(seconds: 1)) -
                Duration(seconds: 1),
            baseBarColor: Colors.white,
            bufferedBarColor: Colors.purple[200],
            timeLabelTextStyle: TextStyle(color: Colors.white),
            thumbCanPaintOutsideBar: false,
            onSeek: (value) async {
              await seek(value);
            },
          );
        },
      );
    }
  }

  // Play da notificação que chama o choosePlayOrPause.
  @override
  Future<void> play() async {
    await choosePlayOrPause('Play');
  }

  // Função de dar Play ou Pause principal.
  Future<void> choosePlayOrPause(String name) async {
    if (name == 'Play') {
      if (completed && currentIndex != null) {
        completed = false;
        await _player.seek(Duration.zero);
      }
    }

    switch (name) {
      case 'Play':
        _player.play();
      case 'Pause':
        await _player.pause();
    }

    playbackState.add(playbackState.value.copyWith(
      playing: playing ? true : false,
      updatePosition: position,
      bufferedPosition: bufferedPosition,
      controls: [
        if (lastIndex != 0 || listMusic.containsKey((lastIndex ?? -1) - 1))
          MediaControl.skipToPrevious,
        if (songList
            .contains(songList.elementAtOrNull((lastIndex ?? -2) + 1) ?? ''))
          MediaControl.skipToNext,
      ],
    ));
  }

  // Pause da notificação que chama o choosePlayOrPause.
  @override
  Future<void> pause() async {
    await choosePlayOrPause('Pause');
  }

  // Stop da notificação.
  @override
  Future<void> stop() async {
    // Release any audio decoders back to the system
    await _player.stop();

    // Set the audio_service state to `idle` to deactivate the notification.
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
  }

  // Função dá notificação que chama o skipToCustomized.
  @override
  Future<void> skipToPrevious() async {
    if (!stateLoading && isIndexNotBlocked(lastIndex! - 1)) {
      await skipToCustomized('Previous');
    }
  }

  // Função de dar SkipToPrevious ou SkipToNext principal.
  Future<void> skipToCustomized(String skipTo) async {
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.loading,
    ));

    isPlayingSkipTo = playing;
    bool hasToPlay = false;

    if (isPlayingSkipTo) {
      await _player.pause();
      await seek(Duration.zero);
    }

    // Diferença nos códigos começa aqui.

    // Skip to Previous.
    if (skipTo == 'Previous') {
      if (!listMusic.containsKey(lastIndex! - 1)) {
        await loadMusic(lastIndex! - 1);
      } else {
        lastIndex = lastIndex! - 1;
        multiIndex = multiIndex! - 1;
        mediaItem.value = mediaItemList[lastIndex!];
        hasToPlay = true;
      }
    }

    // Skip To Next.
    if (skipTo == 'Next') {
      if (!listMusic.containsKey(lastIndex! + 1)) {
        await loadMusic(lastIndex! + 1);
      } else {
        lastIndex = lastIndex! + 1;
        multiIndex = multiIndex! + 1;
        mediaItem.value = mediaItemList[lastIndex];
        hasToPlay = true;
      }
    }

    if (hasToPlay) {
      await _player.setAudioSource(
        playlist,
        initialIndex: listMusic.keys.toList().indexOf(lastIndex!),
        initialPosition: Duration.zero,
      );
    }

    if (isPlayingSkipTo) {
      _player.play();
    }

    playbackState.add(playbackState.value.copyWith(
      playing: playing ? true : false,
      processingState: AudioProcessingState.ready,
      updatePosition: position,
      bufferedPosition: bufferedPosition,
      controls: [
        if (lastIndex != 0 || listMusic.containsKey((lastIndex ?? -1) - 1))
          MediaControl.skipToPrevious,
        if (songList
            .contains(songList.elementAtOrNull((lastIndex ?? -2) + 1) ?? ''))
          MediaControl.skipToNext,
      ],
    ));
  }

  // Função dá notificação que chama o skipToCustomized.
  @override
  Future<void> skipToNext() async {
    if (!stateLoading && isIndexNotBlocked(lastIndex! + 1)) {
      await skipToCustomized('Next');
    }
  }

  // Função Seek Principal.
  @override
  Future<void> seek(Duration position) async {
    if (!stateLoading) {
      await _player.seek(position);

      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    }
  }

  // Função para o Multi Mode de iniciar uma música já carregada.
  Future<void> setAudioSolo(AudioSource audio, int index) async {
    multiIndex = index;
    lastIndex = index;
    mediaItem.value = mediaItemList[lastIndex];

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.loading,
    ));

    await _player.setAudioSource(
      audio,
      initialIndex: listMusic.keys.toList().indexOf(index),
      initialPosition: Duration.zero,
    );

    playbackState.add(playbackState.value.copyWith(
      playing: playing ? true : false,
      processingState: AudioProcessingState.ready,
      updatePosition: position,
      bufferedPosition: bufferedPosition,
      controls: [
        if (lastIndex != 0 || listMusic.containsKey((lastIndex ?? -1) - 1))
          MediaControl.skipToPrevious,
        if (songList
            .contains(songList.elementAtOrNull((lastIndex ?? -2) + 1) ?? ''))
          MediaControl.skipToNext,
      ],
    ));
  }

  // Função para Pesquisar e iniciar a música do SearchPlay.
  Future<void> setAudioSource(VideoId id, Map<String, dynamic> mapMedia) async {
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.loading,
    ));

    lastIndex = 0;

    // Pesquisa pelo ID do vídeo.
    var manifest = await YoutubeExplode().videos.streamsClient.getManifest(id);

    listMusic.addAll({0: AudioSource.uri(manifest.audioOnly.last.url)});

    mediaItemList.addAll(
      {
        0: MediaItem(
          id: mediaItemList.length.toString(),
          album: mapMedia['album'],
          duration: mapMedia['duration'],
          title: mapMedia['title'],
        ),
      },
    );

    await _player.setAudioSource(listMusic[0]!, initialPosition: Duration.zero);

    mediaItem.value = mediaItemList[0];

    // Broadcast that we've finished loading
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      processingState: AudioProcessingState.ready,
      systemActions: const {
        MediaAction.seek,
      },
    ));

    _player.play();
  }

  // Dispose para fechar e limpar tudo que foi usado.
  Future<void> dispose() async {
    nameMusic = [];
    imageList = [];
    artistName = [];
    indexBlocked = [];
    playlist = ConcatenatingAudioSource(children: []);
    listMusic = {};
    artistImage = {};
    durationMusic = {};
    playlistName = {};
    songList = {};
    mediaItemList = {};
    lastIndex = null;
    completed = false;
    shuffle = false;
    delayShuffle = false;
    repeat = 0;

    await stop();

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));

    await _player.dispose();

    _player = AudioPlayer();
  }
}
