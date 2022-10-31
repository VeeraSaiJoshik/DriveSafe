import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:background_sms/background_sms.dart';

class smsTestingScreen extends StatefulWidget {
  const smsTestingScreen({Key? key}) : super(key: key);

  @override
  State<smsTestingScreen> createState() => _smsTestingScreenState();
}

class _smsTestingScreenState extends State<smsTestingScreen> {
  @override
  final player = AudioPlayer();
  AssetSource thingPlay = AssetSource("audio/alert.mp3");
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FloatingActionButton(
          onPressed: () async {
            player.play(thingPlay, volume: 1, mode: PlayerMode.lowLatency, );
          },
          child: Text("press to end"),
        ),
      ),
    );
  }
}
