import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF23235B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF23235B),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: const [
            Text('1. Acceptance of Terms', style: _titleStyle),
            Text(
              'By accessing and using this app, you accept and agree to be bound by the terms and provision of this agreement.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('2. Modification of Terms', style: _titleStyle),
            Text(
              'We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of those changes.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('3. User Responsibilities', style: _titleStyle),
            Text(
              'You agree to use the app only for lawful purposes and in a way that does not infringe the rights of others.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('4. Privacy', style: _titleStyle),
            Text(
              'Your privacy is important to us. Please review our Privacy Policy for more information.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('5. Account Security', style: _titleStyle),
            Text(
              'You are responsible for maintaining the confidentiality of your account and password.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('6. Intellectual Property', style: _titleStyle),
            Text(
              'All content in the app is the property of the company or its licensors.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('7. Termination', style: _titleStyle),
            Text(
              'We may terminate or suspend your access to the app at any time, without notice.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('8. Disclaimer of Warranties', style: _titleStyle),
            Text(
              'The app is provided on an "as is" and "as available" basis.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('9. Limitation of Liability', style: _titleStyle),
            Text(
              'We are not liable for any damages arising from your use of the app.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('10. Governing Law', style: _titleStyle),
            Text(
              'These terms are governed by the laws of the applicable jurisdiction.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('11. Contact Information', style: _titleStyle),
            Text(
              'For any questions about these terms, please contact us.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('12. Entire Agreement', style: _titleStyle),
            Text(
              'These terms constitute the entire agreement between you and the company.',
              style: _contentStyle,
            ),
          ],
        ),
      ),
    );
  }
}

const _titleStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);
const _contentStyle = TextStyle(
  color: Color(0xFFBABABA),
  fontSize: 14,
  fontWeight: FontWeight.normal,
);
