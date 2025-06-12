import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int _coins = 0;
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _loading = true;
  final List<Map<String, dynamic>> _coinProducts = [
    {'desc': '96 Gold coins', 'price': '\$2.99', 'id': 'Meeya2', 'amount': 96},
    {
      'desc': '189 Gold coins',
      'price': '\$5.99',
      'id': 'Meeya5',
      'amount': 189
    },
    {
      'desc': '359 Gold coins',
      'price': '\$9.99',
      'id': 'Meeya9',
      'amount': 359
    },
    {
      'desc': '729 Gold coins',
      'price': '\$19.99',
      'id': 'Meeya19',
      'amount': 729
    },
    {
      'desc': '1869 Gold coins',
      'price': '\$49.99',
      'id': 'Meeya49',
      'amount': 1869
    },
    {
      'desc': '3799 Gold coins',
      'price': '\$99.99',
      'id': 'Meeya99',
      'amount': 3799
    },
    {
      'desc': '5999 Gold coins',
      'price': '\$159.99',
      'id': 'Meeya159',
      'amount': 5999
    },
    {
      'desc': '9059 Gold coins',
      'price': '\$239.99',
      'id': 'Meeya239',
      'amount': 9059
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCoins();
    _initializeIAP();
    _iap.purchaseStream
        .listen(_listenToPurchaseUpdated, onDone: () {}, onError: (error) {});
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _coins = prefs.getInt('my_coins') ?? 0;
    });
  }

  Future<void> _saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('my_coins', coins);
  }

  Future<void> _initializeIAP() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      setState(() => _loading = false);
      return;
    }
    final Set<String> ids = _coinProducts.map((e) => e['id'] as String).toSet();
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  void _buyProduct(String productId) async {
    try {
      final ProductDetails product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notice'),
          content: Text(
              'The in-app purchase product is currently unavailable. Please try again later.\n$e'),
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
        final product = _coinProducts.firstWhere(
            (e) => e['id'] == purchaseDetails.productID,
            orElse: () => <String, dynamic>{});
        if (product.isNotEmpty) {
          final add = product['amount'] as int;
          setState(() {
            _coins += add;
          });
          await _saveCoins(_coins);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Purchase Success'),
              content: Text('You have received $add coins!'),
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
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F2F2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F2F2F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('My Gold coins',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Coins'),
                  content: const Text(
                      'Coins are mainly used for posting comments and accessing some videos. Each time coins are consumed, you will be notified and must confirm before the deduction occurs.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text('$_coins',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text('current coins',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: _coinProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final p = _coinProducts[idx];
                  return GestureDetector(
                    onTap:
                        _loading ? null : () => _buyProduct(p['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF232B3A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(p['desc']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Text(p['price']!,
                              style: const TextStyle(
                                  color: Color(0xFF59BCFA),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
