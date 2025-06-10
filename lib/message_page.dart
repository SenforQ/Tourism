import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'pages/chat_detail_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<Map<String, dynamic>> _figures = [];
  List<Map<String, dynamic>> _figureSummaries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = await rootBundle.loadString(
      'assets/figureInfoData.json',
    );
    final List figures = json.decode(jsonStr);
    List<Map<String, dynamic>> figureList = List<Map<String, dynamic>>.from(
      figures,
    );
    List<Map<String, dynamic>> figureSummaries = [];
    for (var f in figureList) {
      final figureId = f['figureId'];
      final historyStr = prefs.getString('chat_history_$figureId');
      String lastMsg = '';
      String lastMsgRole = 'assistant';
      if (historyStr != null) {
        final history =
            (json.decode(historyStr) as List)
                .map<Map<String, String>>(
                  (e) => (e as Map).map(
                    (k, v) => MapEntry(k.toString(), v.toString()),
                  ),
                )
                .toList();
        if (history.isNotEmpty) {
          final last = history.last;
          lastMsg = last['content'] ?? '';
          lastMsgRole = last['role'] ?? 'assistant';
        }
      }
      if (lastMsg.isEmpty &&
          f['figureSayHi'] != null &&
          (f['figureSayHi'] as String).isNotEmpty) {
        lastMsg = f['figureSayHi'];
        lastMsgRole = 'assistant';
      }
      figureSummaries.add({
        'figure': f,
        'lastMsg': lastMsg,
        'lastMsgRole': lastMsgRole,
      });
    }
    setState(() {
      _figures = figureList;
      _figureSummaries = figureSummaries;
      _loading = false;
    });
    print('[MessagePage] All figure summaries:');
    for (var s in figureSummaries) {
      print(
        '  - ${s['figure']['figureNickName']} (ID: ${s['figure']['figureId']}), lastMsg: ${s['lastMsg']}',
      );
    }
  }

  Future<void> _tryOpenChat(
    BuildContext context,
    Map<String, dynamic> figure,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList('friend_circle_blocked_users') ?? [];
    final figureId = figure['figureId'].toString();
    if (blocked.contains(figureId)) {
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailPage(figure: figure)),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/resource/bg_top_2025_6_4.png',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Message',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children:
                          _figureSummaries.map((s) {
                            final f = s['figure'] as Map<String, dynamic>;
                            final lastMsg = s['lastMsg'] as String;
                            return InkWell(
                              onTap: () {
                                _tryOpenChat(context, f);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _tryOpenChat(context, f);
                                      },
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(
                                          'assets/' + f['figureHeaderIcon'],
                                        ),
                                        radius: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            f['figureNickName'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lastMsg,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
    );
  }
}
