import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:songapp/Data/model/song.dart';
import 'package:songapp/Data/repository/repository.dart';
import 'package:songapp/UI/discovery/Dicovery.dart';
import 'package:songapp/UI/nowplaying/Play.dart';
import 'package:songapp/UI/setting/Setting.dart';
import '../user/User.dart';
import 'music_bloc.dart';

// Giao diện chính
class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
      ),
      themeMode: ThemeMode.system,
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Homepage với Tab
class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tab = [
    const HomeTab(),
    const DicoveryTab(),
    const AccountTab(),
    const SettingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        middle: Text(
          'Music App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Colors.transparent,
          border: const Border(top: BorderSide.none),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Album'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tab[index];
        },
      ),
    );
  }
}

// HomeTab
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

// Music List với BLoC
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MusicBloc(DefaultRepository())..add(LoadSongsEvent()),
      child: const HomeTabPageContent(),
    );
  }
}

class HomeTabPageContent extends StatefulWidget {
  const HomeTabPageContent({super.key});

  @override
  State<HomeTabPageContent> createState() => _HomeTabPageContentState();
}

class _HomeTabPageContentState extends State<HomeTabPageContent> {
  List<Song> songs = [];
  List<Song> filteredSongs = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo filteredSongs khi searchController thay đổi
    searchController.addListener(() {
      setState(() {
        filteredSongs = songs
            .where((song) =>
                song.title
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                song.artist
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    // AudioPlayerManager().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MusicBloc, MusicState>(
        builder: (context, state) {
          if (state is MusicLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MusicLoaded) {
            // Chỉ cập nhật songs và filteredSongs khi dữ liệu mới được tải
            if (songs.isEmpty || songs != state.songs) {
              songs = state.songs;
              filteredSongs = List.from(songs);
            }
          } else if (state is MusicError) {
            return Center(child: Text(state.message));
          }
          return getBody();
        },
      ),
    );
  }

  Widget getBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: CupertinoSearchTextField(
                  controller: searchController,
                  placeholder: 'Search albums, songs...',
                  placeholderStyle: TextStyle(color: Colors.grey[500]),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredSongs = songs
                          .where((song) =>
                              song.title
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              song.artist
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              if (index == 0) {
                return buildUserInfo();
              }
              return getRow(index - 1);
            },
            separatorBuilder: (context, index) {
              return const Divider(
                color: Colors.grey,
                thickness: 0.5,
                indent: 20,
                endIndent: 20,
              );
            },
            itemCount: (searchController.text.isEmpty
                    ? songs.length
                    : filteredSongs.length) +
                1,
            shrinkWrap: true,
          ),
        ),
      ],
    );
  }

  Widget buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Hello',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                SizedBox(height: 10),
                SelectableText(
                  'Tuấn Thành',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman'),
                ),
              ],
            ),
          ),
          ClipOval(
            child: Image.network(
              'https://i.pravatar.cc/100',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget getRow(int index) {
    final songList = searchController.text.isEmpty ? songs : filteredSongs;
    return _SongItemSection(parent: this, song: songList[index]);
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 300,
            width: 400,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Options",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigate(Song song) {
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => NowPlaying(songs: songs, playingSong: song),
        ));
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({required this.parent, required this.song});

  final _HomeTabPageContentState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 24, right: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/download.png',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/download.png', width: 48, height: 48);
          },
        ),
      ),
      title: SelectableText(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        onPressed: () => parent.showBottomSheet(),
        icon: const Icon(Icons.more_horiz),
      ),
      onTap: () => parent.navigate(song),
    );
  }
}
