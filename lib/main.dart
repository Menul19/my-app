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
      title: 'Menul Music Pro',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
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
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MainContainer()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeInDown(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note_rounded, size: 80, color: Colors.deepPurpleAccent),
              const SizedBox(height: 20),
              Text("Menul Music Pro", 
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
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
  final List<Widget> _tabs = [
    const MusicHome(),
    const Center(child: Text("Playlists")),
    const Center(child: Text("Favorites")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
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
}

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});

  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  // ෆෝන් එකේ සින්දු කියවීමට අවසර ලබා ගැනීම
  void requestPermission() async {
    await Permission.storage.request();
    if (await Permission.audio.isDenied) {
      await Permission.audio.request();
    }
    setState(() {});
  }

  // සින්දුව ප්ලේ කරන Function එක
  void playSong(String? uri) {
    try {
      if (uri != null) {
        _audioPlayer.play(DeviceFileSource(uri));
      }
    } catch (e) {
      debugPrint("Error playing song: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Music"),
        actions: [
          IconButton(icon: const Icon(Icons.settings), 
            onPressed: () => _showSettings(context)),
        ],
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (item.data!.isEmpty) {
            return const Center(child: Text("No Songs Found!"));
          }
          return ListView.builder(
            itemCount: item.data!.length,
            itemBuilder: (context, index) {
              return FadeInUp(
                delay: Duration(milliseconds: 30 * index),
                child: ListTile(
                  leading: QueryArtworkWidget(
                    id: item.data![index].id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: const CircleAvatar(child: Icon(Icons.music_note)),
                  ),
                  title: Text(item.data![index].displayNameWOExt, maxLines: 1),
                  subtitle: Text("${item.data![index].artist}", maxLines: 1),
                  onTap: () => playSong(item.data![index].uri),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
              onChanged: (val) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(val),
            ),
            const ListTile(
              title: Text("About"),
              subtitle: Text("Created by Menul Mihisara (2026)"),
            ),
          ],
        ),
      ),
    );
  }
}
