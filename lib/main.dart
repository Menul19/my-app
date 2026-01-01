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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF09090B),
      ),
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
  List<SongModel> _favoriteSongs = [];
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

  void _toggleFavorite(SongModel song) {
    setState(() {
      _favoriteSongs.contains(song) ? _favoriteSongs.remove(song) : _favoriteSongs.add(song);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      MusicHome(onPlay: _playSong, favorites: _favoriteSongs, onFavToggle: _toggleFavorite),
      const Center(child: Text("Playlists (Coming Soon)")),
      FavoriteScreen(favorites: _favoriteSongs, onPlay: _playSong),
    ];

    return Scaffold(
      body: Stack(
        children: [
          tabs[_currentIndex],
          if (_currentSongIndex != -1)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildModernPlayer()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        elevation: 0,
        backgroundColor: Colors.transparent,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: "Explore"),
          NavigationDestination(icon: Icon(Icons.library_music), label: "Library"),
          NavigationDestination(icon: Icon(Icons.favorite_rounded), label: "Liked"),
        ],
      ),
    );
  }

  Widget _buildModernPlayer() {
    return FadeInUp(
      child: Container(
        height: 75,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: QueryArtworkWidget(id: _allSongs[_currentSongIndex].id, type: ArtworkType.AUDIO, size: 50),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_allSongs[_currentSongIndex].displayNameWOExt, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(_allSongs[_currentSongIndex].artist ?? "Unknown", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 45, color: Colors.cyanAccent),
              onPressed: () {
                _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
                setState(() => _isPlaying = !_isPlaying);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MusicHome extends StatefulWidget {
  final Function(List<SongModel>, int) onPlay;
  final List<SongModel> favorites;
  final Function(SongModel) onFavToggle;
  const MusicHome({super.key, required this.onPlay, required this.favorites, required this.onFavToggle});

  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  List<SongModel> _filteredSongs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  _fetchSongs() async {
    // Android 12 Storage Permission Fix
    var status = await Permission.storage.request();
    if (status.isGranted) {
      List<SongModel> tempSongs = await _audioQuery.querySongs(uriType: UriType.EXTERNAL, ignoreCase: true);
      setState(() {
        _songs = tempSongs;
        _filteredSongs = tempSongs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hello Menul,", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                  const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person_outline)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _filteredSongs = _songs.where((s) => s.displayNameWOExt.toLowerCase().contains(v.toLowerCase())).toList()),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                  hintText: "Search your vibe...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                  : ListView.builder(
                      itemCount: _filteredSongs.length,
                      itemBuilder: (context, index) {
                        final song = _filteredSongs[index];
                        return FadeInLeft(
                          delay: Duration(milliseconds: index * 50),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: QueryArtworkWidget(id: song.id, type: ArtworkType.AUDIO, nullArtworkWidget: const CircleAvatar(child: Icon(Icons.music_note))),
                            title: Text(song.displayNameWOExt, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(song.artist ?? "Unknown", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            trailing: IconButton(
                              icon: Icon(widget.favorites.contains(song) ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                              onPressed: () => widget.onFavToggle(song),
                            ),
                            onTap: () => widget.onPlay(_filteredSongs, index),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteScreen extends StatelessWidget {
  final List<SongModel> favorites;
  final Function(List<SongModel>, int) onPlay;
  const FavoriteScreen({super.key, required this.favorites, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liked Songs")),
      body: favorites.isEmpty 
        ? const Center(child: Text("Start liking songs to see them here!"))
        : ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) => ListTile(
              leading: QueryArtworkWidget(id: favorites[index].id, type: ArtworkType.AUDIO),
              title: Text(favorites[index].displayNameWOExt),
              onTap: () => onPlay(favorites, index),
            ),
          ),
    );
  }
}
