import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/audio_service.dart';
import '../../../core/http_client.dart';
import '../../../core/theme/boss_theme.dart';
import '../../../shared/widgets/navigation.dart';
import '../../../shared/widgets/top_header.dart';
import '../../child_hub/widgets/shop/shop_card.dart';

class ChildRewardsScreen extends StatefulWidget {
  const ChildRewardsScreen({super.key});

  @override
  State<ChildRewardsScreen> createState() => _ChildRewardsScreenState();
}

class _ChildRewardsScreenState extends State<ChildRewardsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _rewards = [];
  List<dynamic> _claims = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        AudioService().playSfx('btn_click.wav');
      }
    });

    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString('parent_uid') ?? '';

      final responses = await Future.wait([
        HttpClient().dio.get(
          '/api/rewards',
          queryParameters: {'parent_id': parentId},
        ),
        HttpClient().dio.get('/api/rewards/claims/me'),
      ]);

      if (mounted) {
        setState(() {
          _rewards = responses[0].data;
          _claims = responses[1].data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching child rewards: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
      child: Column(
        children: [
          TopHeader(theme: theme, role: UserRole.child),
          const SizedBox(height: 20),

          // Custom Tab Bar
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5D9F4), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 4)),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: theme.primaryAction,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF9689AE),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                fontSize: 12,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'LOOT SHOP'),
                Tab(text: 'MY BAG'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [_buildShopTab(), _buildHistoryTab()],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopTab() {
    if (_rewards.isEmpty) {
      return const Center(
        child: Text(
          'The shop is empty right now.\nCheck back later!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF756B91),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: _rewards.map((reward) {
          return ShopCard(
            reward: reward,
            onSuccess: () async {
              await _fetchData();
              _tabController.animateTo(1);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_claims.isEmpty) {
      return const Center(
        child: Text(
          'Your bag is empty.\nGo buy some loot!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF756B91),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: _claims.map((claim) => _buildHistoryCard(claim)).toList(),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> claim) {
    final reward = claim['reward'];
    final status = claim['status'];

    Color statusColor;
    Color statusBg;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF159A72);
        statusBg = const Color(0xFFD9F4E9);
        statusText = 'APPROVED';
        statusIcon = LucideIcons.checkCircle2;
        break;
      case 'rejected':
        statusColor = const Color(0xFFFF6578);
        statusBg = const Color(0xFFFFE3E6);
        statusText = 'REJECTED';
        statusIcon = LucideIcons.xCircle;
        break;
      default:
        statusColor = const Color(0xFFD89400);
        statusBg = const Color(0xFFFFF1AE);
        statusText = 'PENDING';
        statusIcon = LucideIcons.clock;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5D9F4), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(reward['icon'], style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward['title'],
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF241642),
                  ),
                ),
                if (reward['description'] != null &&
                    reward['description'].isNotEmpty)
                  Text(
                    reward['description'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF756B91),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
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
