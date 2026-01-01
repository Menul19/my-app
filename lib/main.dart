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
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
      ),
      themeMode: themeProvider.themeMode,
      home: const MusicHome(),
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
    requestStoragePermission();
  }

  // Android 13/14 සඳහා නිවැරදිව Permission ඉල්ලීම
  void requestStoragePermission() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      permissionStatus = await _audioQuery.permissionsRequest();
    }
    setState(() {
      _hasPermission = permissionStatus;
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
      appBar: AppBar(
        title: FadeInLeft(child: const Text("Menul Music Pro")),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: !_hasPermission
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_person, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("Need Permission to Show Songs"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: requestStoragePermission,
                    child: const Text("Allow Access"),
                  ),
                ],
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
                if (item.data == null) return const Center(child: CircularProgressIndicator());
                if (item.data!.isEmpty) return const Center(child: Text("No Music Found!"));

                return ListView.builder(
                  itemCount: item.data!.length,
                  itemBuilder: (context, index) => FadeInUp(
                    delay: Duration(milliseconds: 50 * index),
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
                  ),
                );
              },
            ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.playlist_play), label: "Playlist"),
          NavigationDestination(icon: Icon(Icons.favorite), label: "Favorite"),
        ],
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
              leading: Icon(Icons.info),
              title: Text("About"),
              subtitle: Text("Created by Menul Mihisara"),
            ),
          ],
        ),
      ),
    );
  }
}
