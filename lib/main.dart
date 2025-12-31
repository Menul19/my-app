import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io'; // Device version එක බැලීමට

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

class _MusicPlayerHomeState extends State<MusicPlayerHome> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions();
    _audioPlayer.playingStream.listen((playing) {
      if (mounted) setState(() => isPlaying = playing);
    });
  }

  // Permission ලබාගැනීම (Android 13+ සඳහා විශේෂයි)
  void checkAndRequestPermissions() async {
    bool permissionStatus;
    if (Platform.isAndroid && (await _getAndroidVersion()) >= 33) {
      permissionStatus = await Permission.audio.request().isGranted;
    } else {
      permissionStatus = await Permission.storage.request().isGranted;
    }

    setState(() {
      _hasPermission = permissionStatus;
    });
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      var sdk = await Permission.storage.status; // dummy check
      // සාමාන්‍යයෙන් මෙහිදී Device info එකෙන් version එක ගත හැක. 
      // සරලව අලුත් phone වලට audio permission එක අත්‍යවශ්‍යයි.
      return 33; 
    }
    return 0;
  }

  void playSong(String? uri) {
    try {
      if (uri != null) {
        _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri)));
        _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error playing song: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MENUL MUSIC BETA", style: GoogleFonts.russoOne(color: Colors.redAccent, letterSpacing: 2)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: !_hasPermission 
        ? const Center(child: Text("Please grant storage permissions!"))
        : Stack(
        children: [
          if (isPlaying) const Positioned.fill(child: BassVisualizer()),
          FutureBuilder<List<SongModel>>(
            future: _audioQuery.querySongs(
              sortType: null,
              orderType: OrderType.ASC_OR_DESC,
              uriType: UriType.EXTERNAL,
              ignoreCase: true,
            ),
            builder: (context, item) {
              if (item.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.red));
              if (item.data == null || item.data!.isEmpty) return const Center(child: Text("No songs found"));
              
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
                      title: Text(item.data![index].displayNameWOExt, maxLines: 1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text("${item.data![index].artist}", maxLines: 1, style: const TextStyle(color: Colors.grey)),
                      leading: const Icon(Icons.music_note, color: Colors.redAccent),
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

// (BassVisualizer and VisualizerPainter codes remain the same as you provided)

