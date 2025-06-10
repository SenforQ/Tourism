import 'package:flutter/material.dart';

class MaldivesDetailPage extends StatelessWidget {
  const MaldivesDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部图片和返回按钮在内容流里，按钮随内容滚动
            Stack(
              children: [
                Image.asset(
                  'assets/resource/maldives_top_2025_6_6.png',
                  width: screenWidth,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 交通工具横排
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _transportIcon(Icons.flight, 'Flight'),
                  _transportIcon(Icons.directions_car, 'Car'),
                  _transportIcon(Icons.directions_boat, 'Boat'),
                  _transportIcon(Icons.motorcycle, 'Scooter'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Day 1
            _dayCard(
              day: 'Day 1',
              date: 'Jul 18',
              title: 'Arrival & Kuta Beach',
              transport: '✈️ Flight → 🚗 Car',
              activities: [
                'Arrive at Ngurah Rai International Airport (DPS)',
                'Transfer to Kuta Beach, hotel check-in',
                'Enjoy sunset at Kuta Beach',
              ],
              food: 'Bebek Betutu (Balinese Roast Duck)',
              drink: 'Fresh Coconut Water',
              experience: 'Beach sunset, local snacks',
            ),
            // Day 2
            _dayCard(
              day: 'Day 2',
              date: 'Jul 18',
              title: 'Ubud Culture & Jungle Swing',
              transport: '🚗 Car',
              activities: [
                'Visit Ubud Palace & Ubud Market',
                'Try the famous Jungle Swing',
                'Explore Tegallalang Rice Terrace',
              ],
              food: 'Babi Guling (Roast Suckling Pig)',
              drink: 'Luwak Coffee',
              experience: 'Jungle swing, handicraft shopping',
            ),
            // Day 3
            _dayCard(
              day: 'Day 3',
              date: 'Jul 19',
              title: 'Nusa Lembongan Island Adventure',
              transport: '🚗 Car → ⛵ Boat',
              activities: [
                'Take a boat to Nusa Lembongan',
                'Snorkeling, water sports, beach time',
                'Seafood lunch by the sea',
              ],
              food: 'Seafood Platter',
              drink: 'Fresh Juice',
              experience: 'Snorkeling, jet ski',
            ),
            // Day 4
            _dayCard(
              day: 'Day 4',
              date: 'Jul 20',
              title: 'South Coast & Uluwatu',
              transport: '🚗 Car',
              activities: [
                'Visit Uluwatu Temple (Cliff Temple)',
                'Enjoy sunset at Jimbaran Beach',
                'Seafood BBQ dinner on the beach',
              ],
              food: 'Grilled Seafood BBQ',
              drink: 'Bintang Beer',
              experience: 'Cliff sunset, beach BBQ',
            ),
            // Day 5
            _dayCard(
              day: 'Day 5',
              date: 'Jul 21',
              title: 'Seminyak & Departure',
              transport: '🚗 Car',
              activities: [
                'Shopping & café hopping in Seminyak',
                'Relax at a beach club',
                'Transfer to airport for departure',
              ],
              food: 'Nasi Goreng (Fried Rice)',
              drink: 'Bali Coffee',
              experience: 'Café, shopping',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 交通工具icon组件
  Widget _transportIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF232323),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  // 行程卡片组件
  Widget _dayCard({
    required String day,
    required String date,
    required String title,
    required String transport,
    required List<String> activities,
    required String food,
    required String drink,
    required String experience,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF7B5CF6), Color(0xFF5BBAFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 18),
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    date,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                transport,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...activities.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Expanded(
                      child: Text(
                        a,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                const Icon(Icons.restaurant, color: Colors.white, size: 18),
                Text(
                  'Food: ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  food,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                const Icon(Icons.local_drink, color: Colors.white, size: 18),
                Text(
                  'Drink: ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  drink,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 18),
                Text(
                  'Experience: ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  experience,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
