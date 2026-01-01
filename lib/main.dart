import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(home: MusicHome(), debugShowCheckedModeBanner: false));

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});
  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // මෙය අලුත්ම ක්‍රමයයි - Redmi/MIUI සඳහා හොඳම විසඳුම
  void _checkPermission() async {
    bool status = await _audioQuery.permissionsStatus();
    if (!status) {
      status = await _audioQuery.permissionsRequest();
    }
    
    if (status) {
      _loadSongs();
    } else {
      setState(() => _isLoading = false);
    }
  }

  _loadSongs() async {
    List<SongModel> temp = await _audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_ALPHABETIC,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    setState(() {
      _songs = temp;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menul Music Pro")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty 
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No songs found! Check Permissions."),
                    ElevatedButton(onPressed: _checkPermission, child: const Text("Allow Permission")),
                  ],
                ))
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: QueryArtworkWidget(id: _songs[index].id, type: ArtworkType.AUDIO),
                    title: Text(_songs[index].displayNameWOExt),
                    subtitle: Text(_songs[index].artist ?? "Unknown"),
                    onTap: () => _audioPlayer.play(DeviceFileSource(_songs[index].uri!)),
                  ),
                ),
    );
  }
}
