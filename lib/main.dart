
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  // ඇප් එක Crash වීම වැළැක්වීමට මෙම කොටස ඉතා වැදගත්
  void _checkPermissions() async {
    try {
      var status = await Permission.storage.request();
      if (status.isDenied) {
        // Redmi 12C වැනි Android 12 ෆෝන් සඳහා අනිවාර්යයි
        await Permission.manageExternalStorage.request();
      }
      _loadSongs();
    } catch (e) {
      print("Permission Error: $e");
    }
  }

  void _loadSongs() async {
    try {
      _songs = await _audioQuery.querySongs(uriType: UriType.EXTERNAL);
      setState(() {});
    } catch (e) {
      print("Load Songs Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menul Music Pro")),
      body: _songs.isEmpty 
        ? const Center(child: Text("සින්දු සොයාගත නොහැක. Permissions පරීක්ෂා කරන්න."))
        : ListView.builder(
            itemCount: _songs.length,
            itemBuilder: (context, index) => ListTile(
              leading: QueryArtworkWidget(id: _songs[index].id, type: ArtworkType.AUDIO),
              title: Text(_songs[index].displayNameWOExt),
              onTap: () => _audioPlayer.play(DeviceFileSource(_songs[index].uri!)),
            ),
          ),
    );
  }
}
