import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final List<String> _reasons = [
    'Pornographic or vulgar content',
    'Politically sensitive content',
    'Deception and Fraud',
    'Harassment and Threats',
    'Insults and Obscenity',
    'Incorrect Information',
    'Privacy Violation',
    'Plagiarism or Copyright Infringement',
    'Other',
  ];
  int _selectedReason = 0;
  final TextEditingController _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _submit() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Submitted successfully'),
            content: const Text('We will review and process within 24 hours.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // 占位
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Reason for Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: List.generate(_reasons.length, (index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedReason = index;
                            });
                          },
                          child: Row(
                            children: [
                              Radio<int>(
                                value: index,
                                groupValue: _selectedReason,
                                onChanged: (v) {
                                  setState(() {
                                    _selectedReason = v!;
                                  });
                                },
                                activeColor: const Color(0xFF00C6FF),
                              ),
                              Text(
                                _reasons[index],
                                style: TextStyle(
                                  color:
                                      index == _selectedReason
                                          ? const Color(0xFF00C6FF)
                                          : const Color(0xFF6B6B6B),
                                  fontSize: 15,
                                  fontWeight:
                                      index == _selectedReason
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Other Issue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _otherController,
                      enabled: _selectedReason == _reasons.length - 1,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Describe the issue',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: _submit,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF9B49E2), Color(0xFF5BBAFA)],
                                begin: Alignment(-1, 0.5),
                                end: Alignment(1, 0.5),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(28),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
