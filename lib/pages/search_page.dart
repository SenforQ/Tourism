import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _noData = false;
  Timer? _timer;

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _isLoading = false;
        _noData = false;
      });
      _timer?.cancel();
      return;
    }
    setState(() {
      _isLoading = true;
      _noData = false;
    });
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
        _noData = true;
      });
    });
  }

  Widget _buildNoData() {
    return FutureBuilder<bool>(
      future: rootBundle
          .load('assets/resource/nodata.png')
          .then((_) => true)
          .catchError((_) => false),
      builder: (context, snapshot) {
        final hasImage = snapshot.data == true;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasImage)
              Image.asset(
                'assets/resource/nodata.png',
                width: 120,
                height: 120,
              ),
            const SizedBox(height: 16),
            const Text(
              'No data found',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      body: Stack(
        children: [
          Image.asset(
            'assets/resource/bg_top_2025_6_4.png',
            width: screenWidth,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
          SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
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
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  autofocus: true,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Please enter search text',
                                    hintStyle: TextStyle(
                                      color: Color(0xFFCCCCCC),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: _onChanged,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Center(
                    child:
                        _isLoading
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Searching...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                            : _noData
                            ? _buildNoData()
                            : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
