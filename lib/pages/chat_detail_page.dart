import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'report_page.dart';
import 'audio_call_page.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> figure;
  const ChatDetailPage({super.key, required this.figure});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  bool _aiLoading = false;
  String? _myAvatarPath;
  String? _myNickname;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _loadProfileAndChat();
  }

  Future<void> _loadProfileAndChat() async {
    final prefs = await SharedPreferences.getInstance();
    final docDir = await getApplicationDocumentsDirectory();
    // 用户昵称
    final nickname = prefs.getString('profile_nickname') ?? 'Me';
    // 用户头像
    String? avatarPath;
    final relativePath = prefs.getString('profile_avatar');
    if (relativePath != null && relativePath.isNotEmpty) {
      avatarPath =
          File('${docDir.path}/$relativePath').existsSync()
              ? '${docDir.path}/$relativePath'
              : relativePath;
    } else {
      avatarPath = 'assets/resource/user_default_2025_6_4.png';
    }
    // 聊天记录
    final figureId = widget.figure['figureId'];
    List<Map<String, dynamic>> messages = [];
    final history = prefs.getString('chat_history_${figureId}');
    print('[ChatDetailPage] Try load chat_history_$figureId: $history');
    if (history != null) {
      messages =
          (json.decode(history) as List)
              .map<Map<String, dynamic>>((e) => Map.from(e as Map))
              .toList();
    }
    // 如果没有历史消息，自动插入figureSayHi
    if (messages.isEmpty &&
        widget.figure['figureSayHi'] != null &&
        (widget.figure['figureSayHi'] as String).isNotEmpty) {
      messages.add({
        'role': 'assistant',
        'content': widget.figure['figureSayHi'],
      });
      // 持久化打招呼消息
      print(
        '[ChatDetailPage] Save initial chat_history_$figureId: ${json.encode(messages)}',
      );
      await prefs.setString('chat_history_${figureId}', json.encode(messages));
    }
    setState(() {
      _myNickname = nickname;
      _myAvatarPath = avatarPath;
      _messages = messages.reversed.toList();
      _loading = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _aiLoading) return;
    final prefs = await SharedPreferences.getInstance();
    final figureId = widget.figure['figureId'];
    final msg = {'role': 'user', 'content': text};
    setState(() {
      _messages.insert(0, msg);
      _aiLoading = true;
    });
    _controller.clear();
    final history = List<Map<String, dynamic>>.from(_messages.reversed);
    await prefs.setString('chat_history_${figureId}', json.encode(history));
    print(
      '[ChatDetailPage] Save chat_history_$figureId: ${json.encode(history)}',
    );
    await prefs.setInt('recent_chat_figureId', figureId);
    try {
      final aiReply = await _fetchAIReply(
        'Please answer in English only. ' + text,
      );
      final aiMsg = {'role': 'assistant', 'content': aiReply};
      setState(() {
        _messages.insert(0, aiMsg);
        _aiLoading = false;
      });
      final newHistory = List<Map<String, dynamic>>.from(_messages.reversed);
      await prefs.setString(
        'chat_history_${figureId}',
        json.encode(newHistory),
      );
      print(
        '[ChatDetailPage] Save chat_history_$figureId: ${json.encode(newHistory)}',
      );
    } catch (e) {
      setState(() {
        _aiLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI reply failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _fetchAIReply(String userMessage) async {
    final url = Uri.parse(
      'https://open.bigmodel.cn/api/paas/v4/chat/completions',
    );
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer bd81d4097f634c678201a57eaebd552b.w9gbyA8WNRG1r4TG',
      },
      body: json.encode({
        "model": "glm-4-flash",
        "messages": [
          {"role": "user", "content": userMessage},
        ],
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'] ?? 'No reply.';
    } else {
      throw Exception('AI API error: \\${response.body}');
    }
  }

  Future<void> _blockUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Block User'),
            content: const Text(
              'Are you sure you want to block this user? You will not be able to chat with them.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Block'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> blocked =
        prefs.getStringList('friend_circle_blocked_users') ?? [];
    final figureId = widget.figure['figureId'].toString();
    if (!blocked.contains(figureId)) {
      blocked.add(figureId);
      await prefs.setStringList('friend_circle_blocked_users', blocked);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _sendMediaMessage(String type) async {
    if (type == 'image') {
      final imgs = widget.figure['figureShowImgArray'] as List<dynamic>?;
      if (imgs == null || imgs.isEmpty) return;
      final img = (imgs..shuffle()).first;
      setState(() {
        _messages.insert(0, {
          'role': 'assistant',
          'type': 'image',
          'content': img,
        });
      });
    } else if (type == 'video') {
      final video = widget.figure['figureShowVideo'];
      setState(() {
        _messages.insert(0, {
          'role': 'assistant',
          'type': 'video',
          'content': video,
        });
      });
    }
    // 可选：持久化
  }

  Future<void> _showRequestDialog(String type) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(type == 'image' ? 'Request Photo' : 'Request Video'),
            content: Text(
              'The other party needs to agree before you can get the ${type == 'image' ? 'photo' : 'video'}.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('OK'),
              ),
            ],
          ),
    );
    if (result == true) {
      await _sendMediaMessage(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String figureAvatarPath = widget.figure['figureHeaderIcon'];
    if (!figureAvatarPath.startsWith('assets/')) {
      figureAvatarPath = 'assets/' + figureAvatarPath;
    }
    // 新增：角色背景图（用头像或可扩展为专用背景字段）
    String figureBgPath = figureAvatarPath;
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F2F2F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(figureAvatarPath),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text(
              widget.figure['figureNickName'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_gmailerrorred, color: Colors.white),
            tooltip: 'Report',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.block, color: Colors.white),
            tooltip: 'Block',
            onPressed: () async {
              await _blockUser();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 背景图
          Positioned.fill(child: Image.asset(figureBgPath, fit: BoxFit.cover)),
          // 遮罩层
          Positioned.fill(
            child: Container(
              color: const Color(0x33000000), // #000, 20%透明度
            ),
          ),
          // 聊天内容
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['role'] == 'user';
                        return Row(
                          mainAxisAlignment:
                              isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser) ...[
                              CircleAvatar(
                                backgroundImage: AssetImage(figureAvatarPath),
                                radius: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(child: _buildMessageBubble(msg)),
                            ],
                            if (isUser) ...[
                              Flexible(child: _buildMessageBubble(msg)),
                              const SizedBox(width: 8),
                              _myAvatarPath != null
                                  ? (_myAvatarPath!.startsWith('assets/')
                                      ? CircleAvatar(
                                        backgroundImage: AssetImage(
                                          _myAvatarPath!,
                                        ),
                                        radius: 20,
                                      )
                                      : CircleAvatar(
                                        backgroundImage: FileImage(
                                          File(_myAvatarPath!),
                                        ),
                                        radius: 20,
                                      ))
                                  : const CircleAvatar(
                                    backgroundImage: AssetImage(
                                      'assets/resource/user_default_2025_6_4.png',
                                    ),
                                    radius: 20,
                                  ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 33,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _CapsuleButton(
                          icon: Icons.photo_camera,
                          text: 'Request Photo',
                          onTap: () {
                            _showRequestDialog('image');
                          },
                        ),
                        const SizedBox(width: 12),
                        _CapsuleButton(
                          icon: Icons.videocam,
                          text: 'Request Video',
                          onTap: () {
                            _showRequestDialog('video');
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: const Color(0xFF2F2F2F),
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      top: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Say something...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFF5BBAFA),
                          ),
                          onPressed: _sendMessage,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.phone_in_talk_rounded,
                            color: Color(0xFF5BBAFA),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AudioCallPage(figure: widget.figure),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final type = msg['type'] ?? 'text';
    if (type == 'image') {
      final imgPath = msg['content'] as String;
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder:
                (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: InteractiveViewer(
                      child: Image.asset(
                        imgPath.startsWith('assets/')
                            ? imgPath
                            : 'assets/' + imgPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imgPath.startsWith('assets/') ? imgPath : 'assets/' + imgPath,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (type == 'video') {
      final videoPath = msg['content'] as String;
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => VideoFullScreenPage(
                    videoPath:
                        videoPath.startsWith('assets/')
                            ? videoPath
                            : 'assets/' + videoPath,
                  ),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 120,
                height: 80,
                color: Colors.black12,
                child: VideoPlayerPreview(
                  videoPath:
                      videoPath.startsWith('assets/')
                          ? videoPath
                          : 'assets/' + videoPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
          ],
        ),
      );
    } else {
      // 文本消息
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color:
              msg['role'] == 'user'
                  ? const Color(0xFFF0FFB4)
                  : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          msg['content'] ?? '',
          style: const TextStyle(color: Color(0xFF222222), fontSize: 16),
        ),
      );
    }
  }
}

class _CapsuleButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _CapsuleButton({
    required this.text,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2F2F2F),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerPreview extends StatefulWidget {
  final String videoPath;
  final BoxFit fit;
  const VideoPlayerPreview({
    required this.videoPath,
    this.fit = BoxFit.contain,
    Key? key,
  }) : super(key: key);
  @override
  State<VideoPlayerPreview> createState() => _VideoPlayerPreviewState();
}

class _VideoPlayerPreviewState extends State<VideoPlayerPreview> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.pause();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? FittedBox(
          fit: widget.fit,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        )
        : Container(color: Colors.black12);
  }
}

class VideoFullScreenPage extends StatefulWidget {
  final String videoPath;
  const VideoFullScreenPage({required this.videoPath, Key? key})
    : super(key: key);
  @override
  State<VideoFullScreenPage> createState() => _VideoFullScreenPageState();
}

class _VideoFullScreenPageState extends State<VideoFullScreenPage> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool _initialized = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child:
                  _initialized
                      ? Chewie(controller: _chewieController)
                      : const CircularProgressIndicator(),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
