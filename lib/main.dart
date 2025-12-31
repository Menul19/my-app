import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

void main() => runApp(const MenulMusicApp());

class MenulMusicApp extends StatelessWidget {
  const MenulMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.redAccent,
      ),
      home: const MusicPlayerHome(),
    );
  }
}

class MusicPlayerHome extends StatefulWidget {
  const MusicPlayerHome({super.key});

  @override
  State<MusicPlayerHome> createState() => _MusicPlayerHomeState();
}

class _MusicPlayerHomeState extends State<MusicPlayerHome> with SingleTickerProviderStateMixin {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    requestPermission();
    _audioPlayer.playingStream.listen((playing) {
      setState(() => isPlaying = playing);
    });
  }

  void requestPermission() async {
    await Permission.storage.request();
    setState(() {});
  }

  void playSong(String? uri) {
    _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
    _audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MENUL MUSIC BETA", style: GoogleFonts.russoOne(color: Colors.redAccent, letterSpacing: 2)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // --- Background Bass Visualizer Animation ---
          if (isPlaying) const Positioned.fill(child: BassVisualizer()),

          // --- Song List ---
          FutureBuilder<List<SongModel>>(
            future: _audioQuery.querySongs(uriType: UriType.EXTERNAL),
            builder: (context, item) {
              if (item.data == null) return const Center(child: CircularProgressIndicator(color: Colors.red));
              return ListView.builder(
                itemCount: item.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      title: Text(item.data![index].displayNameWOExt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text("${item.data![index].artist}", style: const TextStyle(color: Colors.grey)),
                      leading: const Icon(Icons.music_note, color: Colors.redAccent),
                      trailing: const Icon(Icons.play_arrow_rounded, color: Colors.redAccent, size: 30),
                      onTap: () => playSong(item.data![index].uri),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildMiniPlayer(),
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        border: Border(top: BorderSide(color: Colors.redAccent, width: 0.5)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(isPlaying ? Icons.music_note : Icons.music_off, color: Colors.white),
        ),
        title: const Text("Now Playing", style: TextStyle(color: Colors.white)),
        trailing: IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.redAccent, size: 40),
          onPressed: () {
            isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
          },
        ),
      ),
    );
  }
}

// --- Bass Visualizer Animation Widget ---
class BassVisualizer extends StatefulWidget {
  const BassVisualizer({super.key});

  @override
  State<BassVisualizer> createState() => _BassVisualizerState();
}

class _BassVisualizerState extends State<BassVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: VisualizerPainter(_controller.value),
        );
      },
    );
  }
}

class VisualizerPainter extends CustomPainter {
  final double animationValue;
  VisualizerPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // සින්දුවේ Bass එකට අනුව රවුම් විශාල වන Animation එකක්
    double radius = (size.width * 0.3) + (animationValue * 50);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius * 1.5, paint..color = Colors.redAccent.withOpacity(0.05));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
