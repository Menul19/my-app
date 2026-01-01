import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Crash වීම වැළැක්වීමට මෙය අත්‍යවශ්‍යයි
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
    // තත්පර 3ක ප්‍රමාදයක් ලබා දීමෙන් ඇප් එක ස්ථාවර වේ
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenulMusicPro()));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Icon(Icons.music_note, size: 100, color: Colors.cyanAccent)),
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
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // ඉතා ආරක්ෂිතව Permission පරීක්ෂා කිරීම
  void _checkPermission() async {
    try {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      
      var status = await Permission.storage.status;
      if (status.isGranted) {
        setState(() => _isPermissionGranted = true);
        _loadSongs();
      } else {
        // Redmi සඳහා විශේෂිතයි
        await Permission.manageExternalStorage.request();
        _loadSongs();
      }
    } catch (e) {
      debugPrint("Permission Error: $e");
    }
  }

  _loadSongs() async {
    try {
      _songs = await _audioQuery.querySongs(uriType: UriType.EXTERNAL);
      setState(() {});
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(title: Text("Menul Music Pro", style: GoogleFonts.poppins())),
      body: _songs.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No songs found!", style: TextStyle(color: Colors.white)),
                  ElevatedButton(onPressed: _checkPermission, child: const Text("Give Permission")),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) => ListTile(
                leading: QueryArtworkWidget(id: _songs[index].id, type: ArtworkType.AUDIO),
                title: Text(_songs[index].displayNameWOExt, style: const TextStyle(color: Colors.white)),
                onTap: () => _audioPlayer.play(DeviceFileSource(_songs[index].uri!)),
              ),
            ),
    );
  }
}

