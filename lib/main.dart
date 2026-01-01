import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MaterialApp(home: MenulMusicPro(), debugShowCheckedModeBanner: false));

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
    _requestPermission();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => _position = p));
    _audioPlayer.onPlayerComplete.listen((event) => _nextSong());
  }

  void _requestPermission() async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    _loadSongs();
  }

  _loadSongs() async {
    _songs = await _audioQuery.querySongs(uriType: UriType.EXTERNAL, ignoreCase: true);
    setState(() {});
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
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Menul Music Pro", style: GoogleFonts.poppins())),
      body: Column(
        children: [
          Expanded(
            child: _songs.isEmpty 
              ? Center(child: ElevatedButton(onPressed: _requestPermission, child: const Text("Allow Storage Access")))
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: QueryArtworkWidget(id: _songs[index].id, type: ArtworkType.AUDIO),
                    title: Text(_songs[index].displayNameWOExt, style: const TextStyle(color: Colors.white)),
                    onTap: () => _playSong(index),
                  ),
                ),
          ),
          if (_currentIndex != -1) _buildPlayerUI(),
        ],
      ),
    );
  }

  Widget _buildPlayerUI() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Color(0xFF1F1F1F), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        children: [
          Slider(
            activeColor: Colors.cyanAccent,
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
            onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white), onPressed: _prevSong),
              IconButton(icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 60, color: Colors.cyanAccent), 
                onPressed: () {
                  _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
                  setState(() => _isPlaying = !_isPlaying);
                }),
              IconButton(icon: const Icon(Icons.stop, size: 40, color: Colors.redAccent), onPressed: () {
                _audioPlayer.stop();
                setState(() => _isPlaying = false);
              }),
              IconButton(icon: const Icon(Icons.skip_next, size: 40, color: Colors.white), onPressed: _nextSong),
            ],
          ),
        ],
      ),
    );
  }
}
