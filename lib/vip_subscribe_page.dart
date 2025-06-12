import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// 内购产品常量
const String kWeekVipProductId = 'MeeyaWeekVIP';
const String kMonthVipProductId = 'MeeyaMonthVIP';
const String kWeekVipPrice = '\$12.99';
const String kMonthVipPrice = '\$49.99';

class VipSubscribePage extends StatefulWidget {
  const VipSubscribePage({Key? key}) : super(key: key);

  @override
  State<VipSubscribePage> createState() => _VipSubscribePageState();
}

class _VipSubscribePageState extends State<VipSubscribePage> {
  int _selectedIndex = 0;
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _loading = true;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    _loadVipStatus();
    _iap.purchaseStream
        .listen(_listenToPurchaseUpdated, onDone: () {}, onError: (error) {});
  }

  Future<void> _initializeIAP() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      setState(() => _loading = false);
      return;
    }
    const Set<String> _kIds = {kWeekVipProductId, kMonthVipProductId};
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_kIds);
    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  Future<void> _loadVipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVip = prefs.getBool('is_vip') ?? false;
    });
  }

  void _buyProduct() async {
    final String productId =
        _selectedIndex == 0 ? kWeekVipProductId : kMonthVipProductId;
    try {
      final ProductDetails product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      String message =
          'The in-app purchase product is currently unavailable. Please try again later.';
      if (e is PlatformException && e.code == 'storekit2_purchase_cancelled') {
        message = 'Purchase has been cancelled by the user.';
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notice'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_vip', true);
        // 写入VIP到期时间
        int days = 7; // 默认周卡
        if (purchaseDetails.productID == kMonthVipProductId) {
          days = 30;
        }
        final expire =
            DateTime.now().add(Duration(days: days)).millisecondsSinceEpoch;
        await prefs.setInt('vip_expire_time', expire);
        setState(() {
          _isVip = true;
        });
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  void _restorePurchases() async {
    try {
      await _iap.restorePurchases();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notice'),
          content: const Text(
              'Restore request sent. If you have a valid subscription, your VIP status will be restored.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Failed'),
          content: Text('Failed to restore purchases: \\${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF181E29),
      appBar: AppBar(
        backgroundColor: Color(0xFF181E29),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部背景与渐变
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF232B3A), Color(0xFF181E29)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  // 渐变标题
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [Color(0xFFFFE29A), Color(0xFFFFB36A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Member benefits',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // VIP大图
                  Positioned(
                    top: 130,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/resource/vip_detail_2025_6_12.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 订阅卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF232B3A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _VipPlanCard(
                      price: kWeekVipPrice,
                      period: 'Per week',
                      total: 'Total $kWeekVipPrice',
                      selected: _selectedIndex == 0,
                      onTap: () => setState(() => _selectedIndex = 0),
                    ),
                    _VipPlanCard(
                      price: kMonthVipPrice,
                      period: 'Per month',
                      total: 'Total $kMonthVipPrice',
                      selected: _selectedIndex == 1,
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 权益标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Exclusive VIP Privileges',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 权益列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF232B3A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: const [
                    _VipPrivilegeItem(
                      icon: Icons.account_circle,
                      title: 'Unlimited avatar changes',
                      subtitle: 'VIPs can change avatars without limits',
                    ),
                    _VipPrivilegeItem(
                      icon: Icons.block,
                      title: 'Eliminate in-app advertising',
                      subtitle: 'VIPs can get rid of ads',
                    ),
                    _VipPrivilegeItem(
                      icon: Icons.list_alt,
                      title: 'Unlimited Avatar list views',
                      subtitle: 'VIPs can view avatar lists endlessly',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: _restorePurchases,
                child: const Text(
                  'Restore',
                  style: TextStyle(
                    color: Color(0xFF59BCFA),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 确认按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF59BCFA), Color(0xFF9D44E1)],
                      begin: Alignment(-1, 0.5),
                      end: Alignment(1, 0.5),
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _loading ? null : _buyProduct,
                    child: const Text(
                      'confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. You can manage or cancel your subscription in your App Store account settings. Refunds are handled by Apple according to their policies.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// 订阅卡片
class _VipPlanCard extends StatelessWidget {
  final String price;
  final String period;
  final String total;
  final bool selected;
  final VoidCallback onTap;
  const _VipPlanCard(
      {required this.price,
      required this.period,
      required this.total,
      required this.selected,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF22304A) : const Color(0xFF232B3A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF59BCFA) : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                period,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                total,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 权益条目组件
class _VipPrivilegeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _VipPrivilegeItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
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
