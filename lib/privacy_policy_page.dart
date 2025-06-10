import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
            Text('1. Information Collection', style: _titleStyle),
            Text(
              'We collect information you provide directly to us when using the app.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('2. Use of Information', style: _titleStyle),
            Text(
              'We use your information to provide, maintain, and improve our services.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('3. Sharing of Information', style: _titleStyle),
            Text(
              'We do not share your personal information with third parties except as described in this policy.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('4. Data Security', style: _titleStyle),
            Text(
              'We implement security measures to protect your information.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('5. Cookies', style: _titleStyle),
            Text(
              'We may use cookies and similar technologies to enhance your experience.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('6. Children’s Privacy', style: _titleStyle),
            Text(
              'Our app is not intended for children under 13 years of age.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('7. Changes to Policy', style: _titleStyle),
            Text(
              'We may update this policy from time to time. Continued use of the app constitutes acceptance of those changes.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('8. Access and Correction', style: _titleStyle),
            Text(
              'You may access and update your personal information within the app.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('9. Third-Party Services', style: _titleStyle),
            Text(
              'We are not responsible for the privacy practices of third-party services linked in the app.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('10. International Users', style: _titleStyle),
            Text(
              'Your information may be transferred to and maintained on servers outside your country.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('11. Contact Us', style: _titleStyle),
            Text(
              'If you have any questions about this policy, please contact us.',
              style: _contentStyle,
            ),
            SizedBox(height: 16),
            Text('12. Consent', style: _titleStyle),
            Text(
              'By using the app, you consent to this privacy policy.',
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
