import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  String? _currentBgm;
  bool _isAppInBackground = false;

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);

    // Register the audio service to listen to global app lifecycle changes
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
    await _sfxPlayer.play(AssetSource('audio/$fileName'));
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
    _sfxPlayer.dispose();
  }
}
