/// Pemutar audio azan (asset lokal).
///
/// Dipicu dari notifikasi (tap / aksi "Mainkan azan") atau tombol di layar.
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AzanPlayer {
  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> playing = ValueNotifier(false);
  bool _loaded = false;

  /// Putar azan dari asset. Aman dipanggil berulang; azan yang sedang
  /// berjalan akan dihentikan lebih dulu.
  Future<void> play() async {
    try {
      await _player.stop();
      if (!_loaded) {
        await _player.setSourceAsset('assets/audio/azan.mp3');
        _loaded = true;
      }
      await _player.setVolume(1.0);
      await _player.resume();
      playing.value = true;
    } catch (e) {
      debugPrint('AzanPlayer.play gagal: $e');
      playing.value = false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    playing.value = false;
  }

  Future<void> dispose() async {
    await _player.dispose();
    playing.value = false;
  }
}
