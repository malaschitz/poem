import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class SoundService {
  Soundpool pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(
    streamType: StreamType.notification,
    iosOptions:
        SoundpoolOptionsIos(audioSessionCategory: AudioSessionCategory.ambient),
  ));
  late int soundClick;

  click() async {
    await pool.play(soundClick);
  }

  Future<void> init() async {
    soundClick = await rootBundle
        .load('assets/sounds/click.mp3')
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
  }
}
