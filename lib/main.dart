import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

/* ---------- SPLASH ---------- */

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

/* ---------- PLAYER ---------- */

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();

  List<SongModel> _songs = [];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    bool permission = await _audioQuery.permissionsRequest();
    if (!permission) return;

    _songs = await _audioQuery.querySongs();
    setState(() {});
  }

  Future<void> _playSong(int index) async {
    _index = index;
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(_songs[index].uri!)),
    );
    _player.play();
    setState(() {});
  }

  void _next() {
    if (_songs.isEmpty) return;
    _playSong((_index + 1) % _songs.length);
  }

  void _previous() {
    if (_songs.isEmpty) return;
    _playSong(_index == 0 ? _songs.length - 1 : _index - 1);
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
      body: _songs.isEmpty
          ? const Center(child: Text("No songs found"))
          : ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(_songs[i].title),
                subtitle: Text(_songs[i].artist ?? "Unknown"),
                onTap: () => _playSong(i),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (_, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _player.duration ?? Duration.zero;
                return Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble().clamp(1, double.infinity),
                  value: position.inSeconds
                      .toDouble()
                      .clamp(0, duration.inSeconds.toDouble()),
                  onChanged: (v) =>
                      _player.seek(Duration(seconds: v.toInt())),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: _previous),
                IconButton(
                  icon: Icon(
                    _player.playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 42,
                  ),
                  onPressed: () {
                    _player.playing ? _player.pause() : _player.play();
                    setState(() {});
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.skip_next), onPressed: _next),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- ABOUT ---------- */

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
