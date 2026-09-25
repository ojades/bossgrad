import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  static const int _sfxPoolSize = 4;
  final List<AudioPlayer> _sfxPlayers = [];
  int _currentSfxIndex = 0;

  String? _currentBgm;
  bool _isAppInBackground = false;

  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);

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

    for (int i = 0; i < _sfxPoolSize; i++) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      _sfxPlayers.add(player);
    }

    final prefs = await SharedPreferences.getInstance();
    isMuted.value = prefs.getBool('is_muted') ?? false;

    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_muted', isMuted.value);

    if (isMuted.value) {
      await _bgmPlayer.pause();
    } else if (_currentBgm != null && !_isAppInBackground) {
      await _bgmPlayer.resume();
      playSfx('btn_click.wav');
    }
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
      if (_currentBgm != null && !isMuted.value) {
        _bgmPlayer.resume();
      }
    }
  }

  Future<void> playSfx(String fileName) async {
    if (isMuted.value) return;

    final player = _sfxPlayers[_currentSfxIndex];
    _currentSfxIndex = (_currentSfxIndex + 1) % _sfxPoolSize;

    await player.stop();
    await player.play(AssetSource('audio/$fileName'));
  }

  Future<void> playBgm(String fileName) async {
    if (_currentBgm == fileName) return;

    _currentBgm = fileName;

    if (!_isAppInBackground && !isMuted.value) {
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

    for (var player in _sfxPlayers) {
      player.dispose();
    }
  }
}
