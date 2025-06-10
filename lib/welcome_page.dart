import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _agreed = false;

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
                    onPressed:
                        _agreed
                            ? () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/mainTab',
                              );
                            }
                            : null,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Color(0xFFBABABA);
                            }
                            return null;
                          }),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: Ink(
                      decoration:
                          _agreed
                              ? const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF9B49E2),
                                    Color(0xFF5BBAFA),
                                  ],
                                  begin: Alignment(-1, 0.5),
                                  end: Alignment(1, 0.5),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(26),
                                ),
                              )
                              : null,
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
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: (v) {
                        setState(() {
                          _agreed = v ?? false;
                        });
                      },
                      activeColor: const Color(0xFF5BBAFA),
                      shape: const CircleBorder(),
                      side: const BorderSide(color: Color(0xFFBABABA)),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFFBABABA),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: 'I have read and agree '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(context, '/terms');
                                    },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(context, '/privacy');
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
