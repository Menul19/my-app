import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: SplashScreen(), debugShowCheckedModeBanner: false));
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenulMusicPro()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note_rounded, size: 100, color: Colors.cyanAccent),
              const SizedBox(height: 20),
              Text("Menul Music Pro", style: GoogleFonts.poppins(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class MenulMusicPro extends StatefulWidget {
  const MenulMusicPro({super.key});
  @override
  State<MenulMusicPro> createState() => _MenulMusicProState();
}

class _MenulMusicProState extends State<MenulMusicPro> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> _songs = [];
  int _currentIndex = -1;
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

  void _requestPermission() async {
    var status = await Permission.storage.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      await Permission.manageExternalStorage.request();
    }
    _loadSongs();
  }

  _loadSongs() async {
    try {
      List<SongModel> temp = await _audioQuery.querySongs(uriType: UriType.EXTERNAL, ignoreCase: true);
      setState(() => _songs = temp);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _playSong(int index) {
    _currentIndex = index;
    _audioPlayer.play(DeviceFileSource(_songs[index].uri!));
    setState(() => _isPlaying = true);
  }

  void _nextSong() { if (_currentIndex < _songs.length - 1) _playSong(_currentIndex + 1); }
  void _prevSong() { if (_currentIndex > 0) _playSong(_currentIndex - 1); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("Menul Music Pro", style: GoogleFonts.poppins()),
        backgroundColor: Colors.cyanAccent.withOpacity(0.7),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _requestPermission)],
      ),
      body: Column(
        children: [
          Expanded(
            child: _songs.isEmpty 
              ? Center(child: ElevatedButton(onPressed: _requestPermission, child: const Text("Load Songs / Grant Permission")))
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: QueryArtworkWidget(id: _songs[index].id, type: ArtworkType.AUDIO),
                    title: Text(_songs[index].displayNameWOExt, maxLines: 1, style: const TextStyle(color: Colors.white)),
                    onTap: () => _playSong(index),
                  ),
                ),
          ),
          if (_currentIndex != -1) _buildPlayerControls(),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return SlideInUp(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          children: [
            Text(_songs[_currentIndex].displayNameWOExt, maxLines: 1, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            Slider(
              activeColor: Colors.cyanAccent,
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
              onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous, size: 35, color: Colors.white), onPressed: _prevSong),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 55, color: Colors.cyanAccent),
                  onPressed: () {
                    _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
                    setState(() => _isPlaying = !_isPlaying);
                  },
                ),
                IconButton(icon: const Icon(Icons.stop, size: 35, color: Colors.redAccent), onPressed: () {
                  _audioPlayer.stop();
                  setState(() => _isPlaying = false);
                }),
                IconButton(icon: const Icon(Icons.skip_next, size: 35, color: Colors.white), onPressed: _nextSong),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

