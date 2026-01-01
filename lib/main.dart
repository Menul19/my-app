import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MenulMusicPro());
}

class MenulMusicPro extends StatelessWidget {
  const MenulMusicPro({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.cyanAccent),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainContainer()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeIn(duration: const Duration(seconds: 2), child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note_rounded, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 10),
            Text("Menul Music Pro", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        )),
      ),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});
  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> _allSongs = [];
  int _currentSongIndex = -1;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => _position = p));
    _audioPlayer.onPlayerComplete.listen((event) => _nextSong());
  }

  void _playSong(List<SongModel> songs, int index) {
    setState(() { _allSongs = songs; _currentSongIndex = index; _isPlaying = true; });
    _audioPlayer.play(DeviceFileSource(songs[index].uri!));
  }

  void _nextSong() { if (_currentSongIndex < _allSongs.length - 1) _playSong(_allSongs, _currentSongIndex + 1); }
  void _prevSong() { if (_currentSongIndex > 0) _playSong(_allSongs, _currentSongIndex - 1); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MusicHome(onPlay: _playSong),
          if (_currentSongIndex != -1) Positioned(bottom: 0, left: 0, right: 0, child: _buildAdvancedPlayer()),
        ],
      ),
    );
  }

  Widget _buildAdvancedPlayer() {
    return SlideInUp(
      child: Container(
        height: 150, margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
        child: Column(
          children: [
            Row(children: [
              QueryArtworkWidget(id: _allSongs[_currentSongIndex].id, type: ArtworkType.AUDIO, size: 40),
              const SizedBox(width: 10),
              Expanded(child: Text(_allSongs[_currentSongIndex].displayNameWOExt, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold))),
            ]),
            Slider(
              activeColor: Colors.cyanAccent,
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble(),
              onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(icon: const Icon(Icons.skip_previous), onPressed: _prevSong),
              IconButton(icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 40, color: Colors.cyanAccent), onPressed: () {
                _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
                setState(() => _isPlaying = !_isPlaying);
              }),
              IconButton(icon: const Icon(Icons.skip_next), onPressed: _nextSong),
            ]),
          ],
        ),
      ),
    );
  }
}

class MusicHome extends StatefulWidget {
  final Function(List<SongModel>, int) onPlay;
  const MusicHome({super.key, required this.onPlay});
  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _requestPermission(); }

  void _requestPermission() async {
    // Android 12/13 සඳහා Storage Permission ලබාගැනීම
    var status = await Permission.storage.request();
    
    if (status.isGranted) {
      _loadSongs();
    } else {
      // Permission හිර වී ඇත්නම් settings විවෘත කිරීමට බල කිරීම
      if (mounted) {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text("Permission Needed"),
          content: const Text("MIUI requires manual permission. Please go to Settings -> Permissions -> Storage and Allow access."),
          actions: [TextButton(onPressed: () => openAppSettings(), child: const Text("Open Settings"))],
        ));
      }
      setState(() => _isLoading = false);
    }
  }

  _loadSongs() async {
    List<SongModel> temp = await _audioQuery.querySongs(uriType: UriType.EXTERNAL, ignoreCase: true);
    setState(() { _songs = temp; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menul Music Pro")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty 
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("No songs found!"),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: _requestPermission, child: const Text("Grant Permission & Refresh")),
                ]))
              : ListView.builder(
                  itemCount: _songs.length,
                  padding: const EdgeInsets.only(bottom: 160),
                  itemBuilder: (context, index) => ListTile(
                    leading: QueryArtworkWidget(id: _songs[index].id, type: ArtworkType.AUDIO),
                    title: Text(_songs[index].displayNameWOExt, maxLines: 1),
                    onTap: () => widget.onPlay(_songs, index),
                  ),
                ),
    );
  }
}
