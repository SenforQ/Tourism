import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'pages/report_page.dart';
import 'pages/maldives_detail_page.dart';
import 'pages/search_page.dart';
import 'pages/profile_page.dart';
import './main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late Future<List<_FriendCircleItemData>> _friendCircleFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _friendCircleFuture = _loadFriendCircleItems();
    });
  }

  @override
  void initState() {
    super.initState();
    _friendCircleFuture = _loadFriendCircleItems();
  }

  Future<List<_FriendCircleItemData>> _loadFriendCircleItems() async {
    final figures = await FriendCircleProvider.loadFriendCircleFigures();
    final allFigures = await FriendCircleProvider.loadAllFigures();
    final prefs = await SharedPreferences.getInstance();
    final blockedIds = await FriendCircleStateManager.getBlockedUserIds();
    final List<_FriendCircleItemData> items = [];
    DateTime baseTime = DateTime(2025, 6, 6, 8, 0);
    final random = Random();

    final List<String> commentContents = [
      "This looks incredibly beautiful, where is it?",
      "Where is this place?",
      "So beautiful!",
      "This place is absolutely stunning",
      "What a gorgeous view!",
      "I'd love to visit here someday",
      "This is breathtaking!",
      "Such a beautiful location!",
      "I'm in love with this view!",
      "This is paradise!",
    ];

    for (int i = 0; i < figures.length; i++) {
      final f = figures[i];
      if (blockedIds.contains(f.figureId)) continue;
      // 时间本地持久化
      final timeKey = 'friend_circle_time_${f.figureId}';
      String? timeStr = prefs.getString(timeKey);
      DateTime time;
      if (timeStr != null) {
        time = DateTime.parse(timeStr);
      } else {
        final hourAdd =
            5 + (DateTime.now().millisecondsSinceEpoch + i * 13) % 8;
        final minAdd = (DateTime.now().millisecondsSinceEpoch + i * 17) % 60;
        time = baseTime.add(Duration(hours: hourAdd * i, minutes: minAdd));
        await prefs.setString(timeKey, time.toIso8601String());
      }

      // 加载状态和评论
      final state = await FriendCircleStateManager.loadState(f.figureId);

      // 如果是首次加载，生成随机评论
      if (state.comments.isEmpty) {
        final availableFigures =
            allFigures
                .where((ff) => ff.figureId >= 1 && ff.figureId <= 11)
                .toList();
        for (int j = 0; j < state.commentCount; j++) {
          final user =
              availableFigures[random.nextInt(availableFigures.length)];
          state.comments.add(
            _CommentData(
              userName: user.figureNickName,
              userIcon: 'assets/' + user.figureHeaderIcon,
              content: commentContents[random.nextInt(commentContents.length)],
            ),
          );
        }
        await FriendCircleStateManager.saveState(f.figureId, state);
      }

      items.add(
        _FriendCircleItemData(
          figure: f,
          time: time,
          state: state,
          comments: state.comments,
        ),
      );
    }
    return items;
  }

  void _onLike(int figureId) async {
    await FriendCircleStateManager.like(figureId);
    setState(() {
      _friendCircleFuture = _loadFriendCircleItems();
    });
  }

  void _onUnlike(int figureId) async {
    await FriendCircleStateManager.unlike(figureId);
    setState(() {
      _friendCircleFuture = _loadFriendCircleItems();
    });
  }

  void _onComment(int figureId) async {
    await FriendCircleStateManager.comment(figureId);
    setState(() {
      _friendCircleFuture = _loadFriendCircleItems();
    });
  }

  void _onFollow(int figureId) async {
    await FriendCircleStateManager.follow(figureId);
    setState(() {
      _friendCircleFuture = _loadFriendCircleItems();
    });
  }

  void _onUnfollow(int figureId) async {
    await FriendCircleStateManager.unfollow(figureId);
    setState(() {
      _friendCircleFuture = _loadFriendCircleItems();
    });
  }

  dynamic _onBlocked(int figureId) {
    setState(() {
      _friendCircleFuture = _loadFriendCircleItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topAreaHeight = statusBarHeight + 10 + 35 + 16;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      body: Stack(
        children: [
          // 背景图片，宽为屏幕宽，高度自适应，y=0
          Image.asset(
            'assets/resource/bg_top_2025_6_4.png',
            width: screenWidth,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
          // 主内容
          Column(
            children: [
              // 顶部内容（SafeArea包裹，防止被状态栏遮挡）
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
                            Image.asset(
                              'assets/resource/fun_2025_6_5.png',
                              width: 54,
                              height: 22,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 25),
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
                                          'Please input search text',
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
              // 内容区...
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            topAreaHeight -
                            56, // 56为TabBar高度
                      ),
                      child: Column(
                        children: [
                          Center(child: _GradientCardWithVideo()),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Image.asset(
                                'assets/resource/recommend_2025_6_4.png',
                                width: 117,
                                height: 22,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const MaldivesDetailPage(),
                                  ),
                                );
                              },
                              child: Image.asset(
                                'assets/resource/recommend_view_2025_6_5.png',
                                fit: BoxFit.fitWidth,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Image.asset(
                                'assets/resource/video_2025_6_5.png',
                                width: 54,
                                height: 22,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 朋友圈动态列表
                          FutureBuilder<List<_FriendCircleItemData>>(
                            future: _friendCircleFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    '加载出错:\n${snapshot.error}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final items = snapshot.data!;
                              if (items.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No Video data',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }
                              return _FriendCircleList(
                                items: items,
                                onBlocked: _onBlocked,
                                onLike: _onLike,
                                onUnlike: _onUnlike,
                                onComment: _onComment,
                                onFollow: _onFollow,
                                onUnfollow: _onUnfollow,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      // bottomNavigationBar: 你的TabBar
    );
  }
}

class _FriendCircleItemData {
  final FigureInfo figure;
  final DateTime time;
  final FriendCircleState state;
  final List<_CommentData> comments;
  _FriendCircleItemData({
    required this.figure,
    required this.time,
    required this.state,
    required this.comments,
  });
}

class _CommentData {
  final String userName;
  final String userIcon;
  final String content;
  _CommentData({
    required this.userName,
    required this.userIcon,
    required this.content,
  });
}

class VideoCoverWidget extends StatefulWidget {
  final String videoPath;
  final VoidCallback onTap;
  const VideoCoverWidget({
    required this.videoPath,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<VideoCoverWidget> createState() => _VideoCoverWidgetState();
}

class _VideoCoverWidgetState extends State<VideoCoverWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        _controller.pause();
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // 1. 强制暂停并回到首帧
    if (_controller.value.isPlaying) {
      await _controller.pause();
    }
    await _controller.seekTo(Duration.zero);
    // 2. 调用外部onTap（即原生播放器）
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _initialized ? _controller.value.aspectRatio : 16 / 9,
            child:
                _initialized
                    ? VideoPlayer(_controller)
                    : Container(color: Colors.black12),
          ),
          const Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
        ],
      ),
    );
  }
}

void showFullScreenVideo(BuildContext context, String videoPath) {
  showDialog(
    context: context,
    barrierColor: Colors.black,
    builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Chewie(
                  controller: ChewieController(
                    videoPlayerController: VideoPlayerController.asset(
                      videoPath,
                    ),
                    autoPlay: true,
                    looping: false,
                    allowFullScreen: true,
                    allowMuting: true,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class FriendCircleCard extends StatefulWidget {
  final _FriendCircleItemData data;
  final void Function(int figureId) onLike;
  final void Function(int figureId) onUnlike;
  final void Function(int figureId) onComment;
  final void Function(int figureId) onFollow;
  final void Function(int figureId) onUnfollow;
  final void Function(int figureId)? onBlocked;
  const FriendCircleCard({
    required this.data,
    required this.onLike,
    required this.onUnlike,
    required this.onComment,
    required this.onFollow,
    required this.onUnfollow,
    this.onBlocked,
    Key? key,
  }) : super(key: key);

  @override
  State<FriendCircleCard> createState() => _FriendCircleCardState();
}

class _FriendCircleCardState extends State<FriendCircleCard> {
  final TextEditingController _commentController = TextEditingController();
  String? _userNickname;
  String? _userAvatarPath;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final docDir = await getApplicationDocumentsDirectory();
    setState(() {
      _userNickname = prefs.getString('profile_nickname') ?? 'You';
      final relativePath = prefs.getString('profile_avatar');
      if (relativePath != null && relativePath.isNotEmpty) {
        _userAvatarPath = path.join(docDir.path, relativePath);
      } else {
        _userAvatarPath = 'assets/resource/user_default_2025_6_4.png';
      }
    });
  }

  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2F2F2F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                _buildActionButton('Report', const Color(0xFFFF3B30), () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportPage()),
                  );
                }),
                _buildActionButton('Block', const Color(0xFFFF3B30), () async {
                  Navigator.pop(context);
                  await FriendCircleStateManager.blockUser(
                    widget.data.figure.figureId,
                  );
                  if (widget.onBlocked != null)
                    widget.onBlocked!(widget.data.figure.figureId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This user has been blocked/hidden and their posts will no longer appear.',
                        ),
                        backgroundColor: Color(0xFF363636),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }),
                _buildActionButton('Hide', const Color(0xFFFF3B30), () async {
                  Navigator.pop(context);
                  await FriendCircleStateManager.blockUser(
                    widget.data.figure.figureId,
                  );
                  if (widget.onBlocked != null)
                    widget.onBlocked!(widget.data.figure.figureId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This user has been blocked/hidden and their posts will no longer appear.',
                        ),
                        backgroundColor: Color(0xFF363636),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }),
                const SizedBox(height: 8),
                _buildActionButton(
                  'Cancel',
                  Colors.white,
                  () => Navigator.pop(context),
                  isCancel: true,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Widget _buildActionButton(
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

  void _showComments() async {
    final blockedUsers =
        await FriendCircleStateManager.getBlockedCommentUsers();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF363636),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          widget.data.comments
                              .where((c) => !blockedUsers.contains(c.userName))
                              .length,
                      itemBuilder: (context, index) {
                        final visibleComments =
                            widget.data.comments
                                .where(
                                  (c) => !blockedUsers.contains(c.userName),
                                )
                                .toList();
                        final comment = visibleComments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    comment.userName == _userNickname
                                        ? _userAvatarPath!.startsWith('assets/')
                                            ? Image.asset(
                                              _userAvatarPath!,
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.file(
                                              File(_userAvatarPath!),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            )
                                        : Image.asset(
                                          comment.userIcon,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            _showCommentActionSheet(
                                              comment.userName,
                                            );
                                          },
                                          child: const Icon(
                                            Icons.flag_outlined,
                                            color: Colors.white38,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.content,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
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
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F2F2F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            if (_commentController.text.trim().isNotEmpty) {
                              await FriendCircleStateManager.addComment(
                                widget.data.figure.figureId,
                                _CommentData(
                                  userName: _userNickname ?? 'You',
                                  userIcon:
                                      _userAvatarPath ??
                                      'assets/resource/user_default_2025_6_4.png',
                                  content: _commentController.text.trim(),
                                ),
                              );
                              setState(() {
                                widget.data.state.commentCount++;
                                widget.data.comments.add(
                                  _CommentData(
                                    userName: _userNickname ?? 'You',
                                    userIcon:
                                        _userAvatarPath ??
                                        'assets/resource/user_default_2025_6_4.png',
                                    content: _commentController.text.trim(),
                                  ),
                                );
                              });
                              Navigator.pop(context);
                              _commentController.clear();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9D44E1), Color(0xFF59BCFA)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Send',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
    );
  }

  void _showCommentActionSheet(String userName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2F2F2F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                _buildActionButton('Report', const Color(0xFFFF3B30), () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportPage()),
                  );
                }),
                _buildActionButton('Block', const Color(0xFFFF3B30), () async {
                  Navigator.pop(context);
                  await FriendCircleStateManager.blockCommentUser(userName);
                  // 重新统计未被屏蔽的评论数并更新
                  final blockedUsers =
                      await FriendCircleStateManager.getBlockedCommentUsers();
                  final visibleComments =
                      widget.data.comments
                          .where((c) => !blockedUsers.contains(c.userName))
                          .toList();
                  widget.data.state.commentCount = visibleComments.length;
                  await FriendCircleStateManager.saveState(
                    widget.data.figure.figureId,
                    widget.data.state,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This user has been blocked/hidden and their comments will no longer appear.',
                        ),
                        backgroundColor: Color(0xFF363636),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    setState(() {});
                  }
                }),
                _buildActionButton('Hide', const Color(0xFFFF3B30), () async {
                  Navigator.pop(context);
                  await FriendCircleStateManager.blockCommentUser(userName);
                  // 重新统计未被屏蔽的评论数并更新
                  final blockedUsers =
                      await FriendCircleStateManager.getBlockedCommentUsers();
                  final visibleComments =
                      widget.data.comments
                          .where((c) => !blockedUsers.contains(c.userName))
                          .toList();
                  widget.data.state.commentCount = visibleComments.length;
                  await FriendCircleStateManager.saveState(
                    widget.data.figure.figureId,
                    widget.data.state,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This user has been blocked/hidden and their comments will no longer appear.',
                        ),
                        backgroundColor: Color(0xFF363636),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    setState(() {});
                  }
                }),
                const SizedBox(height: 8),
                _buildActionButton(
                  'Cancel',
                  Colors.white,
                  () => Navigator.pop(context),
                  isCancel: true,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.data.figure;
    final state = widget.data.state;
    final timeStr = _formatTime(widget.data.time);
    final videoPath = 'assets/' + f.figureShowVideo;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF363636),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProfilePage(
                            nickname: f.figureNickName,
                            signature:
                                f.figureIntroduction.isNotEmpty
                                    ? f.figureIntroduction
                                    : 'No personal signature yet',
                            avatarPath: 'assets/' + f.figureHeaderIcon,
                            figureId: f.figureId,
                          ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/' + f.figureHeaderIcon,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.figureNickName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (state.followed) {
                    widget.onUnfollow(f.figureId);
                  } else {
                    widget.onFollow(f.figureId);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9D44E1), Color(0xFF59BCFA)],
                    ),
                  ),
                  child: Text(
                    state.followed ? 'Unfollow' : 'Follow',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: VideoCoverWidget(
              key: ValueKey(f.figureId),
              videoPath: videoPath,
              onTap: () => showFullScreenVideo(context, videoPath),
            ),
          ),
          const SizedBox(height: 12),
          // 点赞和评论icon一行
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (state.liked) {
                    widget.onUnlike(f.figureId);
                  } else {
                    widget.onLike(f.figureId);
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color:
                          state.liked
                              ? const Color(0xFFFF5A5A)
                              : Colors.white38,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${state.likeCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _showComments(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mode_comment,
                      color: Colors.white38,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${state.commentCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _showActionSheet,
                child: const Icon(
                  Icons.flag_outlined,
                  color: Colors.white38,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _GradientCardWithVideo extends StatefulWidget {
  const _GradientCardWithVideo({Key? key}) : super(key: key);

  @override
  State<_GradientCardWithVideo> createState() => _GradientCardWithVideoState();
}

class _GradientCardWithVideoState extends State<_GradientCardWithVideo> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
        'assets/resource/resourceChat/10/v/10_v_2025_06_04_1.mp4',
      )
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width - 28;
    return Container(
      width: cardWidth,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
          colors: [Color(0xFF59BCFA), Color(0xFF9D44E1)],
          begin: Alignment(-1, 0.5),
          end: Alignment(1, 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child:
                _initialized
                    ? SizedBox(
                      width: cardWidth,
                      height: 196,
                      child: Stack(
                        children: [
                          VideoPlayer(_controller),
                          if (!_controller.value.isPlaying)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black26,
                                child: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                  } else {
                                    _controller.play();
                                  }
                                });
                              },
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Container(
                      width: cardWidth,
                      height: 196,
                      color: Colors.black12,
                    ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'One day tour of sea',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900, // black
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Experience a sea journey',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal, // Regular
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class FigureInfo {
  final int figureId;
  final String figureNickName;
  final String figureIntroduction;
  final String figureHeaderIcon;
  final String figureShowVideo;
  final List<String> figureShowImgArray;
  final String figureSayHi;

  FigureInfo({
    required this.figureId,
    required this.figureNickName,
    required this.figureIntroduction,
    required this.figureHeaderIcon,
    required this.figureShowVideo,
    required this.figureShowImgArray,
    required this.figureSayHi,
  });

  factory FigureInfo.fromJson(Map<String, dynamic> json) {
    return FigureInfo(
      figureId: json['figureId'],
      figureNickName: json['figureNickName'],
      figureIntroduction: json['figureIntroduction'],
      figureHeaderIcon: json['figureHeaderIcon'],
      figureShowVideo: json['figureShowVideo'],
      figureShowImgArray: List<String>.from(json['figureShowImgArray']),
      figureSayHi: json['figureSayHi'],
    );
  }
}

class FriendCircleProvider {
  static Future<List<FigureInfo>> loadFriendCircleFigures() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/figureInfoData.json',
    );
    final List<dynamic> jsonList = json.decode(jsonStr);
    // 只筛选ID为7-11的数据
    final List<FigureInfo> figures =
        jsonList
            .map((e) => FigureInfo.fromJson(e))
            .where((f) => f.figureId >= 7 && f.figureId <= 11)
            .toList();
    return figures;
  }

  static Future<List<FigureInfo>> loadAllFigures() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/figureInfoData.json',
    );
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => FigureInfo.fromJson(e)).toList();
  }
}

class FriendCircleState {
  int likeCount;
  int commentCount;
  bool liked;
  bool followed;
  List<_CommentData> comments;

  FriendCircleState({
    required this.likeCount,
    required this.commentCount,
    required this.liked,
    required this.followed,
    required this.comments,
  });

  Map<String, dynamic> toJson() => {
    'likeCount': likeCount,
    'commentCount': commentCount,
    'liked': liked,
    'followed': followed,
    'comments':
        comments
            .map(
              (c) => {
                'userName': c.userName,
                'userIcon': c.userIcon,
                'content': c.content,
              },
            )
            .toList(),
  };

  factory FriendCircleState.fromJson(Map<String, dynamic> json) {
    return FriendCircleState(
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      liked: json['liked'],
      followed: json['followed'] ?? false,
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map(
                (c) => _CommentData(
                  userName: c['userName'],
                  userIcon: c['userIcon'],
                  content: c['content'],
                ),
              )
              .toList() ??
          [],
    );
  }
}

class FriendCircleStateManager {
  static String _key(int figureId) => 'friend_circle_$figureId';
  static const String _blockedKey = 'friend_circle_blocked_users';
  static const String _blockedCommentUsersKey =
      'friend_circle_blocked_comment_users';

  static Future<List<int>> getBlockedUserIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_blockedKey);
    if (ids == null) return [];
    return ids.map((e) => int.tryParse(e) ?? -1).where((id) => id > 0).toList();
  }

  static Future<void> blockUser(int figureId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_blockedKey) ?? [];
    if (!ids.contains(figureId.toString())) {
      ids.add(figureId.toString());
      await prefs.setStringList(_blockedKey, ids);
    }
  }

  static Future<bool> isBlocked(int figureId) async {
    final ids = await getBlockedUserIds();
    return ids.contains(figureId);
  }

  static Future<List<String>> getBlockedCommentUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_blockedCommentUsersKey) ?? [];
  }

  static Future<void> blockCommentUser(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_blockedCommentUsersKey) ?? [];
    if (!users.contains(userName)) {
      users.add(userName);
      await prefs.setStringList(_blockedCommentUsersKey, users);
    }
  }

  static Future<bool> isCommentUserBlocked(String userName) async {
    final users = await getBlockedCommentUsers();
    return users.contains(userName);
  }

  static Future<FriendCircleState> loadState(int figureId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key(figureId));
    if (jsonStr != null) {
      return FriendCircleState.fromJson(json.decode(jsonStr));
    } else {
      // 首次进入，随机生成
      final random = Random();
      final state = FriendCircleState(
        likeCount: 5 + random.nextInt(6), // 随机5-10个点赞
        commentCount: 1 + random.nextInt(3), // 随机1-3条评论
        liked: false,
        followed: false,
        comments: [], // 初始化空评论列表
      );
      await saveState(figureId, state);
      return state;
    }
  }

  static Future<void> saveState(int figureId, FriendCircleState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(figureId), json.encode(state.toJson()));
  }

  static Future<void> addComment(int figureId, _CommentData comment) async {
    final state = await loadState(figureId);
    state.comments.add(comment);
    state.commentCount++;
    await saveState(figureId, state);
  }

  static Future<void> like(int figureId) async {
    final state = await loadState(figureId);
    if (!state.liked) {
      state.likeCount++;
      state.liked = true;
      await saveState(figureId, state);
    }
  }

  static Future<void> unlike(int figureId) async {
    final state = await loadState(figureId);
    if (state.liked && state.likeCount > 0) {
      state.likeCount--;
      state.liked = false;
      await saveState(figureId, state);
    }
  }

  static Future<void> comment(int figureId) async {
    final state = await loadState(figureId);
    state.commentCount++;
    await saveState(figureId, state);
  }

  static Future<void> follow(int figureId) async {
    final state = await loadState(figureId);
    if (!state.followed) {
      state.followed = true;
      await saveState(figureId, state);
    }
  }

  static Future<void> unfollow(int figureId) async {
    final state = await loadState(figureId);
    if (state.followed) {
      state.followed = false;
      await saveState(figureId, state);
    }
  }
}

class _FriendCircleList extends StatelessWidget {
  final List<_FriendCircleItemData> items;
  final void Function(int figureId) onBlocked;
  final void Function(int figureId) onLike;
  final void Function(int figureId) onUnlike;
  final void Function(int figureId) onComment;
  final void Function(int figureId) onFollow;
  final void Function(int figureId) onUnfollow;
  const _FriendCircleList({
    required this.items,
    required this.onBlocked,
    required this.onLike,
    required this.onUnlike,
    required this.onComment,
    required this.onFollow,
    required this.onUnfollow,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No Video data',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    return Column(
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: FriendCircleCard(
                    key: ValueKey(item.figure.figureId),
                    data: item,
                    onLike: onLike,
                    onUnlike: onUnlike,
                    onComment: onComment,
                    onFollow: onFollow,
                    onUnfollow: onUnfollow,
                    onBlocked: onBlocked,
                  ),
                ),
              )
              .toList(),
    );
  }
}
