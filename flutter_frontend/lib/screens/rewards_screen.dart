import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? rewardsData;
  String? error;

  // Mock rewards data for better demo
  final List<Map<String, dynamic>> availableRewards = [
    {
      'id': '1',
      'title': 'Coffee Voucher',
      'description': 'Get a free coffee at participating cafes',
      'points': 50,
      'icon': Icons.local_cafe,
      'color': Colors.brown,
      'category': 'Food & Beverage',
    },
    {
      'id': '2',
      'title': 'Shopping Discount',
      'description': '10% off your next purchase',
      'points': 100,
      'icon': Icons.shopping_bag,
      'color': Colors.blue,
      'category': 'Shopping',
    },
    {
      'id': '3',
      'title': 'Tree Planting',
      'description': 'Plant a tree in your name',
      'points': 200,
      'icon': Icons.park,
      'color': Colors.green,
      'category': 'Environment',
    },
    {
      'id': '4',
      'title': 'Movie Ticket',
      'description': 'Free movie ticket at participating cinemas',
      'points': 150,
      'icon': Icons.movie,
      'color': Colors.purple,
      'category': 'Entertainment',
    },
    {
      'id': '5',
      'title': 'Eco Bag',
      'description': 'Reusable eco-friendly shopping bag',
      'points': 75,
      'icon': Icons.shopping_basket,
      'color': Colors.green.shade600,
      'category': 'Eco Products',
    },
  ];

  final List<Map<String, dynamic>> recentTransactions = [
    {
      'id': '1',
      'type': 'earned',
      'points': 15,
      'description': 'Recycled Plastic Bottle',
      'date': '2024-03-15',
      'icon': Icons.add_circle,
      'color': Colors.green,
    },
    {
      'id': '2',
      'type': 'redeemed',
      'points': -50,
      'description': 'Coffee Voucher',
      'date': '2024-03-14',
      'icon': Icons.remove_circle,
      'color': Colors.red,
    },
    {
      'id': '3',
      'type': 'earned',
      'points': 25,
      'description': 'Recycled Glass Jar',
      'date': '2024-03-13',
      'icon': Icons.add_circle,
      'color': Colors.green,
    },
  ];

  int get totalPoints {
    return recentTransactions
        .map((t) => t['points'] as int)
        .fold(0, (sum, points) => sum + points);
  }

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    try {
      final result = await ApiService.getRewards();
      setState(() {
        if (result['success']) {
          rewardsData = result['data'];
        } else {
          error = result['message'];
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load rewards: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'EcoChain',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Rewards',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Points Balance Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.trending_up,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your Balance',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${totalPoints + 150} Points',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Keep recycling to earn more!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Available Rewards Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Available Rewards',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            SizedBox(height: 16),

            Container(
              height: 200,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: availableRewards.length,
                itemBuilder: (context, index) {
                  final reward = availableRewards[index];
                  bool canAfford = (totalPoints + 150) >= reward['points'];

                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: reward['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              reward['icon'],
                              color: reward['color'],
                              size: 24,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reward['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                reward['description'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${reward['points']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          canAfford ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(12),
                          child: ElevatedButton(
                            onPressed:
                                canAfford ? () => _redeemReward(reward) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  canAfford ? Colors.green : Colors.grey[300],
                              foregroundColor:
                                  canAfford ? Colors.white : Colors.grey[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              canAfford
                                  ? 'Redeem'
                                  : 'Need ${reward['points'] - (totalPoints + 150)}',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // Recent Transactions Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // Navigate to full transaction history
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentTransactions.length,
              itemBuilder: (context, index) {
                final transaction = recentTransactions[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: transaction['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        transaction['icon'],
                        color: transaction['color'],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      transaction['description'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      transaction['date'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      '${transaction['points'] > 0 ? '+' : ''}${transaction['points']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: transaction['points'] > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _redeemReward(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: reward['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                reward['icon'],
                color: reward['color'],
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Redeem ${reward['title']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reward['description'],
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Cost: ${reward['points']} points',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Remaining balance: ${(totalPoints + 150) - reward['points']} points',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processRedemption(reward);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Confirm Redemption'),
          ),
        ],
      ),
    );
  }

  void _processRedemption(Map<String, dynamic> reward) {
    // Add transaction to recent list
    setState(() {
      recentTransactions.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'redeemed',
        'points': -reward['points'],
        'description': reward['title'],
        'date': DateTime.now().toString().split(' ')[0],
        'icon': Icons.remove_circle,
        'color': Colors.red,
      });
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('${reward['title']} redeemed successfully!'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
