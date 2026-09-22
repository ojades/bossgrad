import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  // 1. Create a pool of SFX players
  static const int _sfxPoolSize = 4;
  final List<AudioPlayer> _sfxPlayers = [];
  int _currentSfxIndex = 0;

  String? _currentBgm;
  bool _isAppInBackground = false;

  Future<void> init() async {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          audioMode: AndroidAudioMode.normal,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: const {},
        ),
      ),
    );

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

    // 2. Pre-warm the SFX players so they are ready instantly
    for (int i = 0; i < _sfxPoolSize; i++) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      _sfxPlayers.add(player);
    }

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _isAppInBackground = true;
      _bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      _isAppInBackground = false;
      if (_currentBgm != null) {
        _bgmPlayer.resume();
      }
    }
  }

  Future<void> playSfx(String fileName) async {
    // 3. Grab the next available player in the pool (Round-Robin)
    final player = _sfxPlayers[_currentSfxIndex];
    _currentSfxIndex = (_currentSfxIndex + 1) % _sfxPoolSize;

    // Stop anything that might still be playing on this specific channel, then play
    await player.stop();
    await player.play(AssetSource('audio/$fileName'));
  }

  Future<void> playBgm(String fileName) async {
    if (_currentBgm == fileName) return;

    _currentBgm = fileName;

    if (!_isAppInBackground) {
      await _bgmPlayer.play(AssetSource('audio/$fileName'));
    } else {
      await _bgmPlayer.setSource(AssetSource('audio/$fileName'));
    }
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    await _bgmPlayer.stop();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer.dispose();

    // 4. Dispose the pool safely
    for (var player in _sfxPlayers) {
      player.dispose();
    }
  }
}
