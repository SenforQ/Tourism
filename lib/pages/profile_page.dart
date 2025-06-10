import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_page.dart'; // 用于FriendCircleStateManager
import 'report_page.dart';
import 'chat_detail_page.dart';
import 'package:flutter/services.dart';
import '../../main.dart';

class ProfilePage extends StatefulWidget {
  final String nickname;
  final String signature;
  final String avatarPath;
  final String? bgImage;
  final int? figureId;
  const ProfilePage({
    Key? key,
    required this.nickname,
    required this.signature,
    required this.avatarPath,
    this.bgImage,
    this.figureId,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  bool _isBlocked = false;

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
    _loadBlockedStatus();
  }

  @override
  void initState() {
    super.initState();
    print('[ProfilePage] Initializing with figureId: ${widget.figureId}');
    print(
      '[ProfilePage] Figure data: {nickname: ${widget.nickname}, signature: ${widget.signature}, avatarPath: ${widget.avatarPath}}',
    );
    _loadBlockedStatus();
  }

  Future<void> _loadBlockedStatus() async {
    if (widget.figureId != null) {
      final isBlocked = await FriendCircleStateManager.isBlocked(
        widget.figureId!,
      );
      print('[ProfilePage] Is user blocked: $isBlocked');
      print(
        '[ProfilePage] Blocked users list: ${await FriendCircleStateManager.getBlockedUserIds()}',
      );
      setState(() {
        _isBlocked = isBlocked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              _showActionSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                widget.bgImage ?? 'assets/resource/me_top_2025_6_4.png',
                width: screenWidth,
                fit: BoxFit.fitWidth,
              ),
              Positioned(
                left: 24,
                bottom: -46,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(46),
                    child:
                        widget.avatarPath.startsWith('assets/')
                            ? Image.asset(widget.avatarPath, fit: BoxFit.cover)
                            : (File(widget.avatarPath).existsSync()
                                ? Image.file(
                                  File(widget.avatarPath),
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  'assets/resource/user_default_2025_6_4.png',
                                  fit: BoxFit.cover,
                                )),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 54),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.nickname,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.signature,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (widget.figureId != null) {
                      if (_isBlocked) {
                        showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text('Blocked'),
                                content: const Text(
                                  'This user is in your blacklist and cannot chat.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                        return;
                      }
                    }
                    final String jsonStr = await rootBundle.loadString(
                      'assets/figureInfoData.json',
                    );
                    final List figures = json.decode(jsonStr);
                    final figure = figures.firstWhere(
                      (f) => f['figureId'] == (widget.figureId ?? 0),
                      orElse: () => null,
                    );
                    if (figure != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailPage(figure: figure),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatDetailPage(
                                figure: {
                                  'figureId': widget.figureId ?? 0,
                                  'figureNickName': widget.nickname,
                                  'figureIntroduction': widget.signature,
                                  'figureHeaderIcon': widget.avatarPath,
                                },
                              ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 88,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9B49E2), Color(0xFF5BBAFA)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Now Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
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
                _buildActionButton(
                  context,
                  'Report',
                  const Color(0xFFFF3B30),
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportPage(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  'Block',
                  const Color(0xFFFF3B30),
                  () async {
                    Navigator.pop(context);
                    if (widget.figureId != null) {
                      await FriendCircleStateManager.blockUser(
                        widget.figureId!,
                      );
                      setState(() {
                        _isBlocked = true;
                      });
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
                    }
                  },
                ),
                _buildActionButton(
                  context,
                  'Hide',
                  const Color(0xFFFF3B30),
                  () async {
                    Navigator.pop(context);
                    if (widget.figureId != null) {
                      await FriendCircleStateManager.blockUser(
                        widget.figureId!,
                      );
                      setState(() {
                        _isBlocked = true;
                      });
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
                    }
                  },
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  context,
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
