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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
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
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainContainer()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeInDown(
          child: Text("Menul Music Pro", 
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
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
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
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
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions();
  }

  // Crash වීම නැවැත්වීමට නිවැරදිව Permissions ඉල්ලීම
  checkAndRequestPermissions() async {
    bool status = await _audioQuery.permissionsStatus();
    if (!status) {
      status = await _audioQuery.permissionsRequest();
    }
    setState(() {
      _hasPermission = status;
    });
  }

  void playSong(String? uri) {
    if (uri != null) {
      _audioPlayer.play(DeviceFileSource(uri));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menul Music Pro")),
      body: !_hasPermission
          ? Center(
              child: ElevatedButton(
                onPressed: checkAndRequestPermissions,
                child: const Text("Allow Access to Music"),
              ),
            )
          : FutureBuilder<List<SongModel>>(
              future: _audioQuery.querySongs(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true,
              ),
              builder: (context, item) {
                if (item.hasError) return Center(child: Text(item.error.toString()));
                if (item.data == null) return const Center(child: CircularProgressIndicator());
                if (item.data!.isEmpty) return const Center(child: Text("No Songs Found!"));

                return ListView.builder(
                  itemCount: item.data!.length,
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      child: ListTile(
                        leading: QueryArtworkWidget(
                          id: item.data![index].id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: const CircleAvatar(child: Icon(Icons.music_note)),
                        ),
                        title: Text(item.data![index].displayNameWOExt),
                        subtitle: Text("${item.data![index].artist}"),
                        onTap: () => playSong(item.data![index].uri),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
