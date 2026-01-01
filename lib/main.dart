import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MenulMusicPro());
}

class MenulMusicPro extends StatelessWidget {
  const MenulMusicPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menul Music Pro',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const SplashScreen(),
    );
  }
}

/* ---------------- SPLASH SCREEN ---------------- */

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PlayerScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Menul Music Pro",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/* ---------------- PLAYER SCREEN ---------------- */

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  final AudioPlayer player = AudioPlayer();

  List<SongModel> songs = [];
  int currentIndex = 0;

  bool shuffle = false;
  bool repeat = false;

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    await audioQuery.permissionsRequest();
    songs = await audioQuery.querySongs();
    setState(() {});
  }

  Future<void> playSong(int index) async {
    currentIndex = index;
    await player.setAudioSource(
      AudioSource.uri(Uri.parse(songs[index].uri!)),
    );
    player.play();
    setState(() {});
  }

  void nextSong() {
    int next = (currentIndex + 1) % songs.length;
    playSong(next);
  }

  void previousSong() {
    int prev = currentIndex == 0 ? songs.length - 1 : currentIndex - 1;
    playSong(prev);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menul Music Pro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          )
        ],
      ),
      body: songs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(songs[index].title),
                  subtitle: Text(songs[index].artist ?? "Unknown Artist"),
                  onTap: () => playSong(index),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = player.duration ?? Duration.zero;
                return Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble() == 0
                      ? 1
                      : duration.inSeconds.toDouble(),
                  value: position.inSeconds
                      .toDouble()
                      .clamp(0, duration.inSeconds.toDouble()),
                  onChanged: (value) {
                    player.seek(Duration(seconds: value.toInt()));
                  },
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: previousSong,
                ),
                IconButton(
                  icon: Icon(
                    player.playing ? Icons.pause_circle : Icons.play_circle,
                    size: 42,
                  ),
                  onPressed: () {
                    player.playing ? player.pause() : player.play();
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: nextSong,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- ABOUT SCREEN ---------------- */

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Menul Music Pro\n\nDeveloped by Menul Mihisara\n© 2026",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
