import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  String? _currentBgm;

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  Future<void> playSfx(String fileName) async {
    await _sfxPlayer.play(AssetSource('audio/$fileName'));
  }

  Future<void> playBgm(String fileName) async {
    if (_currentBgm == fileName) return;

    _currentBgm = fileName;
    await _bgmPlayer.play(AssetSource('audio/$fileName'));
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    await _bgmPlayer.stop();
  }
}
