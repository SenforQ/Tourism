import 'package:flutter/material.dart';

class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/resource/welcome_bg_2025_6_3.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 200),
              Center(
                child: Image.asset(
                  'assets/resource/launch_center_icon_2025_6_3.png',
                  width: 287,
                  height: 211,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: SizedBox(
                  width: size.width - 96,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      // 进入主页面逻辑
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF9B49E2), Color(0xFF5BBAFA)],
                          begin: Alignment(-1, 0.5),
                          end: Alignment(1, 0.5),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(26)),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Enter APP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }
}
