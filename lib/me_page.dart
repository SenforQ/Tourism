import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  String? _nickname;
  String? _signature;
  String? _avatarPath;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _initUserProfileIfNeeded().then((_) => _loadProfile());
    _loadVipStatus();
  }

  Future<void> _initUserProfileIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    // 昵称
    if (!prefs.containsKey('profile_nickname')) {
      final nickname =
          'ID${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';
      await prefs.setString('profile_nickname', nickname);
    }
    // 个性签名
    if (!prefs.containsKey('profile_signature')) {
      await prefs.setString('profile_signature', 'No personal signature yet');
    }
    // 头像
    if (!prefs.containsKey('profile_avatar')) {
      await prefs.setString(
        'profile_avatar',
        'assets/resource/user_default_2025_6_4.png',
      );
    }
  }

  Future<void> _loadVipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVip = prefs.getBool('is_vip') ?? false;
    });
    final expire = prefs.getInt('vip_expire_time');
    if (expire != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(expire);
      debugPrint('[VIP] 当前VIP状态: [33m[1m[4m[7m$_isVip[0m, 到期时间: $dt');
    } else {
      debugPrint('[VIP] 当前VIP状态: $_isVip, 未设置到期时间');
    }
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final docDir = await getApplicationDocumentsDirectory();
    setState(() {
      _nickname = prefs.getString('profile_nickname') ?? '';
      _signature = prefs.getString('profile_signature') ?? '';
      final relativePath = prefs.getString('profile_avatar');
      if (relativePath != null && relativePath.isNotEmpty) {
        _avatarPath = path.join(docDir.path, relativePath);
      } else {
        _avatarPath = null;
      }
    });
    _loadVipStatus();
  }

  void _goToEditProfile() async {
    await Navigator.pushNamed(context, '/editProfile');
    await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Image.asset('assets/resource/vip_2025_6_12.png',
                width: 28, height: 28),
            onPressed: () => Navigator.pushNamed(context, '/vip'),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _goToEditProfile,
          ),
        ],
      ),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/resource/me_top_2025_6_4.png',
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
                    child: (_avatarPath != null &&
                            _avatarPath!.isNotEmpty &&
                            File(_avatarPath!).existsSync())
                        ? Image.file(File(_avatarPath!), fit: BoxFit.cover)
                        : Image.asset(
                            'assets/resource/user_default_2025_6_4.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Positioned(
                left: 24 + 92 - 16,
                bottom: -46 + 4,
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: _isVip
                      ? Image.asset('assets/resource/vip_detail_2025_6_12.png',
                          width: 12, height: 12)
                      : ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                              Colors.grey, BlendMode.srcIn),
                          child: Image.asset(
                              'assets/resource/vip_detail_2025_6_12.png',
                              width: 12,
                              height: 12),
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
                _nickname ?? '',
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
                _signature ?? '',
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
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFBABABA), width: 1),
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildListItem(context, 'Wallet', '/wallet'),
                  const Divider(height: 1, color: Color(0xFFBABABA)),
                  _buildListItem(context, 'Terms of service', '/terms'),
                  const Divider(height: 1, color: Color(0xFFBABABA)),
                  _buildListItem(context, 'Privacy policy', '/privacy'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 18,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
