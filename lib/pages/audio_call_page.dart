import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AudioCallPage extends StatefulWidget {
  final Map<String, dynamic> figure;
  const AudioCallPage({super.key, required this.figure});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  Timer? _timer;
  bool _isPlaying = false;
  late String _bgImg;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _initBgImg();
    _audioPlayer = AudioPlayer();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _startCall();
  }

  void _initBgImg() {
    final imgs = widget.figure['figureShowImgArray'] as List?;
    if (imgs != null && imgs.isNotEmpty) {
      _bgImg = imgs[Random().nextInt(imgs.length)];
      if (!_bgImg.startsWith('assets/')) _bgImg = 'assets/' + _bgImg;
    } else {
      _bgImg = 'assets/resource/user_default_2025_6_4.png';
    }
  }

  Future<void> _startCall() async {
    try {
      await _audioPlayer.play(AssetSource('resource/call_2025_6_6.mp3'));
      setState(() {
        _isPlaying = true;
      });
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 300, 200, 300, 200, 300]);
      }
      _timer = Timer(const Duration(seconds: 30), _hangUp);
    } catch (e) {
      _hangUp();
    }
  }

  void _hangUp() async {
    await _audioPlayer.stop();
    _timer?.cancel();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final figure = widget.figure;
    String avatarPath = figure['figureHeaderIcon'];
    if (!avatarPath.startsWith('assets/')) avatarPath = 'assets/' + avatarPath;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_bgImg, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.25)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    CircleAvatar(
                      backgroundImage: AssetImage(avatarPath),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          figure['figureNickName'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 2),
                            ],
                          ),
                        ),
                        if (figure['figureCountry'] != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 16,
                              ),
                              Text(
                                figure['figureCountry'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Invite you to a video call...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: GestureDetector(
                      onTap: _hangUp,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4D4F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
