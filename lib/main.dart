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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.cyanAccent),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF09090B),
      ),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(), // මුලින්ම පෙන්වන්නේ මෙයයි
    );
  }
}

// --- Splash Screen ---
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
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainContainer()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeInDown(
          duration: const Duration(seconds: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note_rounded, size: 100, color: Colors.cyanAccent),
              const SizedBox(height: 20),
              Text("Menul Music Pro", 
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      MusicHome(onPlay: _playSong),
      const Center(child: Text("Library")),
      const Center(child: Text("Liked Songs")),
    ];

    return Scaffold(
      body: Stack(
        children: [
          tabs[_currentIndex],
          if (_currentSongIndex != -1)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildMiniPlayer()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_filled), label: "Home"),
          NavigationDestination(icon: Icon(Icons.library_music), label: "Library"),
          NavigationDestination(icon: Icon(Icons.favorite), label: "Liked"),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return SlideInUp(
      child: Container(
        height: 70, margin: const EdgeInsets.all(10), padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
        child: Row(
          children: [
            QueryArtworkWidget(id: _allSongs[_currentSongIndex].id, type: ArtworkType.AUDIO, size: 45),
            const SizedBox(width: 15),
            Expanded(child: Text(_allSongs[_currentSongIndex].displayNameWOExt, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 40), onPressed: () {
              _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
              setState(() => _isPlaying = !_isPlaying);
            }),
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
  void initState() {
    super.initState();
    _requestPermission();
  }

  // Android 12 Storage Permission Fix
  void _requestPermission() async {
    // පළමුව Permission ලබාගෙන ඇත්දැයි බලන්න
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    
    // වැදගත්: Android 11/12 සඳහා 'Manage External Storage' සමහරවිට අවශ්‍ය වේ
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    if (status.isGranted) {
      _loadSongs();
    } else {
      setState(() => _isLoading = false);
    }
  }

  _loadSongs() async {
    List<SongModel> temp = await _audioQuery.querySongs(uriType: UriType.EXTERNAL, ignoreCase: true);
    setState(() {
      _songs = temp;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menul Music Pro"), actions: [IconButton(icon: const Icon(Icons.search), onPressed: (){})]),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty 
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("No songs found! Did you allow permission?"),
                  ElevatedButton(onPressed: _requestPermission, child: const Text("Try Again"))
                ]))
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: QueryArtworkWidget(id: _songs[index].id, type: ArtworkType.AUDIO),
                    title: Text(_songs[index].displayNameWOExt, maxLines: 1),
                    onTap: () => widget.onPlay(_songs, index),
                  ),
                ),
    );
  }
}
