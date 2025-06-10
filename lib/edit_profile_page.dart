import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nicknameController;
  late TextEditingController _signatureController;
  File? _avatarFile;
  bool _initialized = false;
  String? _avatarPath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      _nicknameController = TextEditingController(
        text: args?['nickname'] ?? '',
      );
      _signatureController = TextEditingController(
        text: args?['signature'] ?? '',
      );
      _loadProfile();
      _initialized = true;
    }
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final docDir = await getApplicationDocumentsDirectory();
    setState(() {
      _nicknameController.text =
          prefs.getString('profile_nickname') ?? _nicknameController.text;
      _signatureController.text =
          prefs.getString('profile_signature') ?? _signatureController.text;
      final relativePath = prefs.getString('profile_avatar');
      if (relativePath != null && relativePath.isNotEmpty) {
        _avatarPath = relativePath;
        _avatarFile = File(path.join(docDir.path, relativePath));
      }
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_nickname', _nicknameController.text);
    await prefs.setString('profile_signature', _signatureController.text);
    if (_avatarFile != null) {
      final docDir = await getApplicationDocumentsDirectory();
      final absPath = _avatarFile!.path;
      String relativePath =
          absPath.startsWith(docDir.path)
              ? absPath.substring(docDir.path.length + 1)
              : absPath;
      await prefs.setString('profile_avatar', relativePath);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(picked.path)}';
      final localPath = path.join(dir.path, fileName);
      final saved = await File(picked.path).copy(localPath);
      setState(() {
        _avatarFile = saved;
        _avatarPath = fileName;
      });
      await _saveProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2F2F2F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF2F2F2F),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
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
                      _avatarFile != null
                          ? Image.file(_avatarFile!, fit: BoxFit.cover)
                          : Image.asset(
                            'assets/resource/user_default_2025_6_4.png',
                            fit: BoxFit.cover,
                          ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nicknameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nickname',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _signatureController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Signature',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              maxLines: 2,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await _saveProfile();
                Navigator.pop(context, {
                  'nickname': _nicknameController.text,
                  'signature': _signatureController.text,
                  'avatarPath': _avatarFile?.path,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5BBAFA),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
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
