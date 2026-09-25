import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dio/dio.dart';

import '../../../core/audio_service.dart';
import '../../../core/http_client.dart';
import '../../../core/theme/boss_theme.dart';

class ParentRewardsScreen extends StatefulWidget {
  const ParentRewardsScreen({super.key});

  @override
  State<ParentRewardsScreen> createState() => _ParentRewardsScreenState();
}

class _ParentRewardsScreenState extends State<ParentRewardsScreen> {
  bool _isLoading = true;
  List<dynamic> _rewards = [];
  List<dynamic> _claims = [];

  final List<String> _emojiCatalog = [
    '🍕',
    '🎮',
    '💵',
    '🍦',
    '🚲',
    '📱',
    '🎬',
    '🧩',
    '🚀',
    '👕',
    '👟',
    '🍔',
    '🍟',
    '🍿',
    '⚽️',
    '🎨',
    '📚',
    '🧸',
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        HttpClient().dio.get('/api/rewards'),
        HttpClient().dio.get('/api/rewards/claims'),
      ]);

      if (mounted) {
        setState(() {
          _rewards = responses[0].data;
          _claims = responses[1].data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching rewards data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReward(String id) async {
    try {
      await HttpClient().dio.delete('/api/rewards/$id');
      setState(() => _rewards.removeWhere((r) => r['id'] == id));
      AudioService().playSfx('btn_click.wav');
    } catch (e) {
      debugPrint('Delete failed: $e');
    }
  }

  Future<void> _resolveClaim(String claimId, String status) async {
    try {
      await HttpClient().dio.post(
        '/api/rewards/claims/$claimId/resolve',
        data: {'status': status},
      );
      AudioService().playSfx(
        status == 'fulfilled' ? 'scan_success.wav' : 'scan_fail.wav',
      );
      _fetchData();
    } catch (e) {
      debugPrint('Resolve failed: $e');
    }
  }

  void _confirmResolveAction(Map<String, dynamic> claim, String status) {
    AudioService().playSfx('btn_click.wav');

    final bool isApprove = status == 'fulfilled';
    final reward = claim['reward'];

    final String title = isApprove ? 'Approve Claim?' : 'Reject Claim?';
    final String message = isApprove
        ? 'Are you sure you want to approve "${reward['title']}"?'
        : 'Are you sure you want to reject "${reward['title']}"? The stats will be refunded to the child.';

    final Color actionColor = isApprove
        ? const Color(0xFF28C995)
        : const Color(0xFFFF6578);
    final Color bgColor = isApprove
        ? const Color(0xFFD9F4E9)
        : const Color(0xFFFFE3E3);
    final IconData icon = isApprove
        ? LucideIcons.checkCircle2
        : LucideIcons.xCircle;

    showDialog(
      context: context,
      barrierColor: const Color(0xFF241642).withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: actionColor, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF241642),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF756B91),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          AudioService().playSfx('btn_click.wav');
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF756B91),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resolveClaim(claim['id'], status);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isApprove ? 'Approve' : 'Reject',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> reward) {
    AudioService().playSfx('btn_click.wav');
    showDialog(
      context: context,
      barrierColor: const Color(0xFF241642).withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3E3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    LucideIcons.trash2,
                    color: Color(0xFFFF6578),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Reward?',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF241642),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to remove "${reward['title']}"? This cannot be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF756B91),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          AudioService().playSfx('btn_click.wav');
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF756B91),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          _deleteReward(reward['id']); // Run the deletion
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6578),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRewardDialog([Map<String, dynamic>? existingReward]) {
    final bool isEdit = existingReward != null;
    final titleCtrl = TextEditingController(
      text: isEdit ? existingReward['title'] : '',
    );
    final descCtrl = TextEditingController(
      text: isEdit ? existingReward['description'] ?? '' : '',
    );
    final coinsCtrl = TextEditingController(
      text: isEdit ? existingReward['coin_cost'].toString() : '0',
    );
    final xpCtrl = TextEditingController(
      text: isEdit ? existingReward['xp_cost'].toString() : '0',
    );
    String selectedEmoji = isEdit ? existingReward['icon'] : '🎁';

    showDialog(
      context: context,
      barrierColor: const Color(0xFF241642).withOpacity(0.6),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Reward' : 'Create New Reward',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF241642),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Icon',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _emojiCatalog.map((emoji) {
                        final isSelected = selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedEmoji = emoji),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF4EFFF)
                                  : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF7554F6)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Reward Title (e.g., Pizza Night)',
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: coinsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Coin Cost',
                              prefixIcon: const Icon(
                                LucideIcons.coins,
                                color: Color(0xFFD89400),
                                size: 16,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F8FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: xpCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'XP Cost',
                              prefixIcon: const Icon(
                                LucideIcons.zap,
                                color: Color(0xFF7447F5),
                                size: 16,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F8FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF756B91),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (titleCtrl.text.isEmpty) return;

                            final payload = {
                              'title': titleCtrl.text.trim(),
                              'description': descCtrl.text.trim(),
                              'coin_cost': int.tryParse(coinsCtrl.text) ?? 0,
                              'xp_cost': int.tryParse(xpCtrl.text) ?? 0,
                              'icon': selectedEmoji,
                            };

                            try {
                              if (isEdit) {
                                await HttpClient().dio.put(
                                  '/api/rewards/${existingReward['id']}',
                                  data: payload,
                                );
                              } else {
                                await HttpClient().dio.post(
                                  '/api/rewards',
                                  data: payload,
                                );
                              }
                              AudioService().playSfx('btn_click.wav');
                              if (context.mounted) Navigator.pop(context);
                              _fetchData();
                            } catch (e) {
                              debugPrint('Save failed: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF172033),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Save Changes' : 'Create Reward',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;

    final pendingClaims = _claims
        .where((c) => c['status'] == 'pending')
        .toList();
    final resolvedClaims = _claims
        .where((c) => c['status'] != 'pending')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 80, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.gift, color: theme.primaryAction, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Rewards Warehouse',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF241642),
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showRewardDialog(),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text(
                  'Add Reward',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryAction,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Create real-world rewards your kids can buy with their earned Coins and XP.',
            style: TextStyle(
              color: Color(0xFF756B91),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            if (pendingClaims.isNotEmpty) ...[
              const Text(
                'PENDING CLAIMS',
                style: TextStyle(
                  color: Color(0xFFFF6578),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: pendingClaims
                    .map((claim) => _buildClaimCard(claim))
                    .toList(),
              ),
              const SizedBox(height: 40),
            ],

            const Text(
              'ACTIVE REWARDS',
              style: TextStyle(
                color: Color(0xFF9689AE),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (_rewards.isEmpty)
              const Text(
                'No rewards created yet. Add one above!',
                style: TextStyle(color: Color(0xFF756B91)),
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _rewards
                    .map((reward) => _buildRewardCard(reward))
                    .toList(),
              ),

            if (resolvedClaims.isNotEmpty) ...[
              const SizedBox(height: 40),
              const Text(
                'CLAIM HISTORY',
                style: TextStyle(
                  color: Color(0xFF9689AE),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: resolvedClaims
                    .map((claim) => _buildResolvedClaimCard(claim))
                    .toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> claim) {
    final reward = claim['reward'];
    final currency = claim['currency_used'] ?? 'coins';
    final isCoins = currency == 'coins';
    final int cost =
        claim['value'] ?? (isCoins ? reward['coin_cost'] : reward['xp_cost']);

    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFB3BD), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reward['icon'], style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isCoins ? LucideIcons.coins : LucideIcons.zap,
                          size: 14,
                          color: isCoins
                              ? const Color(0xFFD89400)
                              : const Color(0xFF7447F5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$cost',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isCoins
                                ? const Color(0xFFD89400)
                                : const Color(0xFF7447F5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmResolveAction(claim, 'rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6578),
                    side: const BorderSide(color: Color(0xFFFFB3BD), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmResolveAction(claim, 'fulfilled'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28C995),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResolvedClaimCard(Map<String, dynamic> claim) {
    final reward = claim['reward'];
    final status = claim['status'];

    Color statusColor;
    Color statusBg;
    String statusText;
    IconData statusIcon;

    if (status == 'fulfilled') {
      statusColor = const Color(0xFF159A72);
      statusBg = const Color(0xFFD9F4E9);
      statusText = 'APPROVED';
      statusIcon = LucideIcons.checkCircle2;
    } else {
      statusColor = const Color(0xFFFF6578);
      statusBg = const Color(0xFFFFE3E6);
      statusText = 'REJECTED';
      statusIcon = LucideIcons.xCircle;
    }

    return Container(
      width: 320,
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
            child: Text(
              reward['title'],
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF241642),
              ),
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

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reward['icon'],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.edit2,
                      size: 16,
                      color: Color(0xFF9689AE),
                    ),
                    onPressed: () => _showRewardDialog(reward),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: Color(0xFFFF6578),
                    ),
                    onPressed: () => _confirmDelete(reward),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            reward['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF241642),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (reward['coin_cost'] > 0) ...[
                const Icon(
                  LucideIcons.coins,
                  size: 14,
                  color: Color(0xFFD89400),
                ),
                const SizedBox(width: 4),
                Text(
                  '${reward['coin_cost']}',
                  style: const TextStyle(
                    color: Color(0xFFD89400),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (reward['xp_cost'] > 0) ...[
                const Icon(LucideIcons.zap, size: 14, color: Color(0xFF7447F5)),
                const SizedBox(width: 4),
                Text(
                  '${reward['xp_cost']}',
                  style: const TextStyle(
                    color: Color(0xFF7447F5),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
