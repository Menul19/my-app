import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MenulMusicPro(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MenulMusicPro extends StatelessWidget {
  const MenulMusicPro({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light, colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.deepPurple, scaffoldBackgroundColor: const Color(0xFF0F0E17)),
      themeMode: themeProvider.themeMode,
      home: const MainContainer(),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> _allSongs = [];
  int _currentSongIndex = -1;
  bool _isPlaying = false;

  void _playSong(List<SongModel> songs, int index) {
    setState(() {
      _allSongs = songs;
      _currentSongIndex = index;
      _isPlaying = true;
    });
    _audioPlayer.play(DeviceFileSource(songs[index].uri!));
  }

  void _nextSong() {
    if (_currentSongIndex < _allSongs.length - 1) {
      _playSong(_allSongs, _currentSongIndex + 1);
    }
  }

  void _prevSong() {
    if (_currentSongIndex > 0) {
      _playSong(_allSongs, _currentSongIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      MusicHome(onPlay: _playSong),
      const Center(child: Text("Playlists Content", style: TextStyle(fontSize: 18))),
      const Center(child: Text("Favorite Songs List", style: TextStyle(fontSize: 18))),
    ];

    return Scaffold(
      body: Stack(
        children: [
          tabs[_currentIndex],
          if (_currentSongIndex != -1)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildPlayerControl()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_filled), label: "Home"),
          NavigationDestination(icon: Icon(Icons.playlist_play), label: "Playlist"),
          NavigationDestination(icon: Icon(Icons.favorite), label: "Favorite"),
        ],
      ),
    );
  }

  Widget _buildPlayerControl() {
    return SlideInUp(
      child: Container(
        height: 80,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.deepPurpleAccent, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.music_note, color: Colors.white)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_allSongs[_currentSongIndex].displayNameWOExt, maxLines: 1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(_allSongs[_currentSongIndex].artist ?? "Unknown", maxLines: 1, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white), onPressed: _prevSong),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 40, color: Colors.white),
              onPressed: () {
                if (_isPlaying) { _audioPlayer.pause(); } else { _audioPlayer.resume(); }
                setState(() => _isPlaying = !_isPlaying);
              }
            ),
            IconButton(icon: const Icon(Icons.skip_next, color: Colors.white), onPressed: _nextSong),
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
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void requestPermission() async {
    // Android 12 (API 31) සඳහා විශේෂිතව Permission ඉල්ලීම
    var status = await Permission.storage.request();
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
    } else {
      openAppSettings(); // Permission දීමට Settings වලට යොමු කිරීම
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menul Music Pro", style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: !_permissionGranted
          ? Center(child: ElevatedButton(onPressed: requestPermission, child: const Text("Allow Access to Songs")))
          : FutureBuilder<List<SongModel>>(
              future: _audioQuery.querySongs(uriType: UriType.EXTERNAL, sortType: null, ignoreCase: true),
              builder: (context, item) {
                if (item.data == null) return const Center(child: CircularProgressIndicator());
                if (item.data!.isEmpty) return const Center(child: Text("No Songs Found on Device"));
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: item.data!.length,
                  itemBuilder: (context, index) => FadeInLeft(
                    child: ListTile(
                      leading: QueryArtworkWidget(id: item.data![index].id, type: ArtworkType.AUDIO, nullArtworkWidget: const CircleAvatar(child: Icon(Icons.music_note))),
                      title: Text(item.data![index].displayNameWOExt),
                      subtitle: Text("${item.data![index].artist}"),
                      onTap: () => widget.onPlay(item.data!, index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
