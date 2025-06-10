import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/report_page.dart';

class CirclePage extends StatefulWidget {
  const CirclePage({Key? key}) : super(key: key);

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  final List<_Category> _categories = [
    _Category('Travel tips', 'assets/resource/note_2025_6_10.png'),
    _Category('Self-driving tour', 'assets/resource/car_2025_6_10.png'),
    _Category('Small attractions', 'assets/resource/shan_2025_6_10.png'),
  ];
  int _selectedCategory = 0;
  Map<String, List<_TravelNote>> _data = {};
  bool _loading = true;
  List<int> _blockedNoteIds = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    _blockedNoteIds =
        prefs
            .getStringList('travel_note_blocked_ids')
            ?.map((e) => int.tryParse(e) ?? -1)
            .where((id) => id > 0)
            .toList() ??
        [];
    final String jsonStr = await rootBundle.loadString(
      'assets/figureInfoData.json',
    );
    final List figures = json.decode(jsonStr);
    final random = Random();
    final List<List<Map<String, String>>> localNotes = [
      // Travel tips
      [
        {
          "title": "Santorini Sunset",
          "desc":
              "Experience the breathtaking sunset in Santorini, Greece. The view from Oia is unforgettable.",
        },
        {
          "title": "Kyoto Blossoms",
          "desc":
              "Visit Kyoto in spring to see the cherry blossoms. Don't miss the Philosopher's Path.",
        },
        {
          "title": "Maui Snorkeling",
          "desc":
              "Snorkel with turtles in Maui. Book a tour to Molokini Crater for the best experience.",
        },
        {
          "title": "Paris at Night",
          "desc":
              "See the Eiffel Tower sparkle at night. Take a Seine river cruise for a romantic view.",
        },
        {
          "title": "Rome's Colosseum",
          "desc":
              "Explore the Colosseum early in the morning to avoid crowds and enjoy the history.",
        },
        {
          "title": "Bali Rice Terraces",
          "desc":
              "Walk through the lush rice terraces of Ubud, Bali. Best visited at sunrise.",
        },
        {
          "title": "Central Park Autumn",
          "desc":
              "Enjoy the fall colors in Central Park, New York. Rent a bike for a scenic ride.",
        },
      ],
      // Self-driving tour
      [
        {
          "title": "Route 66 Roadtrip",
          "desc":
              "Drive the classic Route 66 across the USA. Plan your stops for quirky roadside attractions.",
        },
        {
          "title": "Great Ocean Road",
          "desc":
              "See the Twelve Apostles on Australia's Great Ocean Road. Drive during daylight for the best views.",
        },
        {
          "title": "Iceland Ring Road",
          "desc":
              "Circle Iceland on the Ring Road. See waterfalls, glaciers, and black sand beaches.",
        },
        {
          "title": "Garden Route",
          "desc":
              "South Africa's Garden Route offers stunning coastal views. Stop at Tsitsikamma National Park.",
        },
        {
          "title": "Amalfi Coast",
          "desc":
              "Drive the winding roads of Italy's Amalfi Coast. Enjoy sea views and charming villages.",
        },
        {
          "title": "Pacific Coast Highway",
          "desc":
              "California's Pacific Coast Highway features Big Sur and dramatic cliffs. Check for road closures.",
        },
        {
          "title": "Blue Ridge Parkway",
          "desc":
              "See fall foliage on the Blue Ridge Parkway. Visit in October for peak colors.",
        },
      ],
      // Small attractions
      [
        {
          "title": "Hallstatt Village",
          "desc":
              "Visit the fairy-tale lakeside village of Hallstatt, Austria. Take the funicular for panoramic views.",
        },
        {
          "title": "Chefchaouen Blue",
          "desc":
              "Explore the blue city of Chefchaouen, Morocco. Wander the medina for hidden gems.",
        },
        {
          "title": "Colmar Canals",
          "desc":
              "Stroll along the colorful canals of Colmar, France. Try the local Alsace wine.",
        },
        {
          "title": "Sintra Palaces",
          "desc":
              "Discover palaces and castles in Sintra, Portugal. Visit Pena Palace early morning.",
        },
        {
          "title": "Giethoorn Boats",
          "desc":
              "Experience Giethoorn, Netherlands, where there are no roads, only canals. Rent a boat!",
        },
        {
          "title": "Shirakawa-go Snow",
          "desc":
              "See traditional thatched-roof houses in Shirakawa-go, Japan. Best in winter with snow.",
        },
        {
          "title": "Bibury Cottages",
          "desc":
              "Walk Arlington Row in Bibury, England, for classic English village charm.",
        },
      ],
    ];
    Map<String, List<_TravelNote>> result = {
      for (var cat in _categories) cat.name: [],
    };
    for (int catIdx = 0; catIdx < _categories.length; catIdx++) {
      String catName = _categories[catIdx].name;
      final notesList = localNotes[catIdx];
      for (int i = 0; i < figures.length && i < notesList.length; i++) {
        var f = figures[i];
        final List imgs = f['figureShowImgArray'] ?? [];
        String coverImg =
            imgs.isNotEmpty
                ? imgs.length > catIdx
                    ? imgs[catIdx]
                    : imgs.last
                : '';
        String avatar = f['figureHeaderIcon'] ?? '';
        String nickname = f['figureNickName'] ?? '';
        int id = f['figureId'] * 10 + catIdx; // 保证唯一
        String likeKey = 'travel_note_like_$id';
        String likedKey = 'travel_note_liked_$id';
        int likeCount = prefs.getInt(likeKey) ?? random.nextInt(11);
        bool isLiked = prefs.getBool(likedKey) ?? false;
        if (!prefs.containsKey(likeKey)) await prefs.setInt(likeKey, likeCount);
        if (!prefs.containsKey(likedKey)) await prefs.setBool(likedKey, false);
        if (!_blockedNoteIds.contains(id)) {
          result[catName]!.add(
            _TravelNote(
              id: id,
              coverImg: coverImg,
              avatar: avatar,
              nickname: nickname,
              title: notesList[i]['title']!,
              desc: notesList[i]['desc']!,
              place: f['figureIntroduction'] ?? '',
              experience: f['figureSayHi'] ?? '',
              guide: '',
              likeCount: likeCount,
              isLiked: isLiked,
            ),
          );
        }
      }
    }
    setState(() {
      _data = result;
      _loading = false;
    });
  }

  void _toggleLike(_TravelNote note, String category) async {
    final prefs = await SharedPreferences.getInstance();
    String likeKey = 'travel_note_like_${note.id}';
    String likedKey = 'travel_note_liked_${note.id}';
    setState(() {
      if (note.isLiked) {
        note.likeCount = (note.likeCount > 0) ? note.likeCount - 1 : 0;
        note.isLiked = false;
      } else {
        note.likeCount += 1;
        note.isLiked = true;
      }
    });
    await prefs.setInt(likeKey, note.likeCount);
    await prefs.setBool(likedKey, note.isLiked);
  }

  void _blockNote(int noteId) async {
    final prefs = await SharedPreferences.getInstance();
    _blockedNoteIds.add(noteId);
    await prefs.setStringList(
      'travel_note_blocked_ids',
      _blockedNoteIds.map((e) => e.toString()).toList(),
    );
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topAreaHeight = statusBarHeight + 10 + 35 + 16;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = (screenWidth - 28 - 10) / 2.0;
    final List<_TravelNote> notes =
        (_data[_categories[_selectedCategory].name] ?? [])
            .where((n) => !_blockedNoteIds.contains(n.id))
            .toList();
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      body: Stack(
        children: [
          // 顶部渐变背景图片
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/resource/bg_top_2025_6_4.png',
              width: screenWidth,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          // 主内容
          Column(
            children: [
              // 顶部内容
              SizedBox(
                height: topAreaHeight,
                width: double.infinity,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 左侧LOGO或图片
                            Image.asset(
                              'assets/resource/fun_2025_6_5.png',
                              width: 54,
                              height: 22,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 25),
                            // 右侧搜索栏
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SearchPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2F2F2F),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Iceland',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 火焰和Popular Notes
              Padding(
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 8,
                  bottom: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/resource/fire_2025_6_10.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/resource/popular_2025_6_10.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              // 分类Tab横向ScrollView
              SizedBox(
                height: 25,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final selected = idx == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = idx;
                        });
                      },
                      child: Container(
                        height: 25,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selected
                                  ? const Color(0xFF393E99)
                                  : Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              _categories[idx].iconPath,
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _categories[idx].name,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 内容区GridView
              Expanded(
                child:
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: itemWidth / 227.0,
                                ),
                            itemCount: notes.length,
                            itemBuilder: (context, idx) {
                              final note = notes[idx];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              TravelNoteDetailPage(note: note),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: itemWidth,
                                      height: 227,
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        16,
                                                      ),
                                                      topRight: Radius.circular(
                                                        16,
                                                      ),
                                                    ),
                                                child:
                                                    note.coverImg.isNotEmpty
                                                        ? Image.asset(
                                                          note.coverImg
                                                                  .startsWith(
                                                                    'assets/',
                                                                  )
                                                              ? note.coverImg
                                                              : 'assets/' +
                                                                  note.coverImg,
                                                          width: itemWidth,
                                                          height: 162,
                                                          fit: BoxFit.cover,
                                                        )
                                                        : Container(
                                                          width: itemWidth,
                                                          height: 162,
                                                          color:
                                                              Colors.grey[300],
                                                        ),
                                              ),
                                              Positioned(
                                                top: 6,
                                                right: 6,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      builder:
                                                          (
                                                            context,
                                                          ) => Container(
                                                            decoration: const BoxDecoration(
                                                              color: Color(
                                                                0xFF2F2F2F,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.vertical(
                                                                    top:
                                                                        Radius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Container(
                                                                  width: 40,
                                                                  height: 4,
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        Colors
                                                                            .white24,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          2,
                                                                        ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                _buildActionButton(
                                                                  context,
                                                                  'Report',
                                                                  const Color(
                                                                    0xFFFF3B30,
                                                                  ),
                                                                  () {
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (
                                                                              context,
                                                                            ) =>
                                                                                const ReportPage(),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                                _buildActionButton(
                                                                  context,
                                                                  'Block',
                                                                  const Color(
                                                                    0xFFFF3B30,
                                                                  ),
                                                                  () async {
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                    _blockNote(
                                                                      note.id,
                                                                    );
                                                                  },
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                _buildActionButton(
                                                                  context,
                                                                  'Cancel',
                                                                  Colors.white,
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                                  isCancel:
                                                                      true,
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .report_gmailerrorred,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: itemWidth,
                                            height: 65,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF393E99),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(16),
                                                bottomRight: Radius.circular(
                                                  16,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 6,
                                                        right: 6,
                                                        top: 6,
                                                      ),
                                                  child: Container(
                                                    height: 27,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      note.title,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 2,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundImage: AssetImage(
                                                          note.avatar
                                                                  .startsWith(
                                                                    'assets/',
                                                                  )
                                                              ? note.avatar
                                                              : 'assets/' +
                                                                  note.avatar,
                                                        ),
                                                        radius: 12,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          note.nickname,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      GestureDetector(
                                                        onTap:
                                                            () => _toggleLike(
                                                              note,
                                                              _categories[_selectedCategory]
                                                                  .name,
                                                            ),
                                                        child: Icon(
                                                          Icons.favorite,
                                                          color:
                                                              note.isLiked
                                                                  ? Color(
                                                                    0xFFFF5A5A,
                                                                  )
                                                                  : Colors
                                                                      .white54,
                                                          size: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${note.likeCount}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color textColor,
    VoidCallback onTap, {
    bool isCancel = false,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isCancel ? 8 : 0, vertical: 4),
      child: Material(
        color: isCancel ? const Color(0xFF363636) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _Category {
  final String name;
  final String iconPath;
  _Category(this.name, this.iconPath);
}

class _TravelNote {
  final int id;
  final String coverImg;
  final String avatar;
  final String nickname;
  final String title;
  final String desc;
  final String place;
  final String experience;
  final String guide;
  int likeCount;
  bool isLiked;
  _TravelNote({
    required this.id,
    required this.coverImg,
    required this.avatar,
    required this.nickname,
    required this.title,
    required this.desc,
    required this.place,
    required this.experience,
    required this.guide,
    required this.likeCount,
    required this.isLiked,
  });
}

class TravelNoteDetailPage extends StatelessWidget {
  final _TravelNote note;
  const TravelNoteDetailPage({required this.note, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F2F2F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          note.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.coverImg.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    note.coverImg.startsWith('assets/')
                        ? note.coverImg
                        : 'assets/' + note.coverImg,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                note.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                note.desc,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
