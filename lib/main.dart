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
      if (_favoriteSongs.contains(song)) {
        _favoriteSongs.remove(song);
      } else {
        _favoriteSongs.add(song);
      }
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
        height: 80, margin: const EdgeInsets.all(10), padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.deepPurpleAccent, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.music_note, color: Colors.white)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_allSongs[_currentSongIndex].displayNameWOExt, maxLines: 1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(_allSongs[_currentSongIndex].artist ?? "Unknown", maxLines: 1, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            IconButton(icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 40, color: Colors.white),
                onPressed: () {
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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  _fetchSongs() async {
    // Android 12 permissions
    if (await Permission.storage.request().isGranted || await Permission.audio.request().isGranted) {
      List<SongModel> tempSongs = await _audioQuery.querySongs(uriType: UriType.EXTERNAL, ignoreCase: true);
      setState(() {
        _songs = tempSongs;
        _filteredSongs = tempSongs;
        _isLoading = false;
      });
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _filteredSongs = _songs.where((song) => song.displayNameWOExt.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(controller: _searchController, autofocus: true, decoration: const InputDecoration(hintText: "Search songs...", border: InputBorder.none), onChanged: _filterSongs)
          : const Text("Menul Music Pro"),
        actions: [
          IconButton(icon: Icon(_isSearching ? Icons.close : Icons.search), onPressed: () => setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) { _filteredSongs = _songs; _searchController.clear(); }
          })),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _filteredSongs.length,
            padding: const EdgeInsets.only(bottom: 100),
            itemBuilder: (context, index) {
              final song = _filteredSongs[index];
              final isFav = widget.favorites.contains(song);
              return ListTile(
                leading: QueryArtworkWidget(id: song.id, type: ArtworkType.AUDIO),
                title: Text(song.displayNameWOExt, maxLines: 1),
                subtitle: Text("${song.artist}"),
                trailing: IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                  onPressed: () => widget.onFavToggle(song),
                ),
                onTap: () => widget.onPlay(_filteredSongs, index),
              );
            },
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
      appBar: AppBar(title: const Text("My Favorites")),
      body: favorites.isEmpty 
        ? const Center(child: Text("No favorites yet!"))
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
