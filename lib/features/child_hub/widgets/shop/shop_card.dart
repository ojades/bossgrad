import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dio/dio.dart';

import '../../../../core/audio_service.dart';
import '../../../../core/child_stat_service.dart';
import '../../../../core/http_client.dart';

class ShopCard extends StatefulWidget {
  final Map<String, dynamic> reward;
  final VoidCallback onSuccess;

  const ShopCard({super.key, required this.reward, required this.onSuccess});

  @override
  State<ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> {
  bool _isClaiming = false;

  Future<void> _claimReward() async {
    final reward = widget.reward;
    AudioService().playSfx('btn_click.wav');

    final int costCoins = (reward['coin_cost'] as num?)?.toInt() ?? 0;
    final int costXp = (reward['xp_cost'] as num?)?.toInt() ?? 0;

    final bool canAffordCoins =
        costCoins > 0 && ChildStatsService().coins.value >= costCoins;
    final bool canAffordXp =
        costXp > 0 && ChildStatsService().xp.value >= costXp;

    if (!canAffordCoins && !canAffordXp) return;

    // If they can afford both, start as null so they choose.
    // If they can only afford one, jump straight to the confirmation step.
    String? pendingCurrency = (canAffordCoins && canAffordXp)
        ? null
        : (canAffordCoins ? 'coins' : 'xp');

    final selectedCurrency = await showDialog<String>(
      context: context,
      barrierColor: const Color(0xFF241642).withOpacity(0.6),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 340,
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
                  Text(reward['icon'], style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),

                  // STEP 1: CHOOSE CURRENCY
                  if (pendingCurrency == null) ...[
                    const Text(
                      'Buy this Loot?',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF241642),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'How would you like to pay?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF756B91),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (canAffordCoins)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                AudioService().playSfx('btn_click.wav');
                                setDialogState(() => pendingCurrency = 'coins');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFF5BB),
                                foregroundColor: const Color(0xFFD89400),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFFFD447),
                                  width: 2,
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.coins, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$costCoins',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (canAffordCoins && canAffordXp)
                          const SizedBox(width: 12),
                        if (canAffordXp)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                AudioService().playSfx('btn_click.wav');
                                setDialogState(() => pendingCurrency = 'xp');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF4EFFF),
                                foregroundColor: const Color(0xFF7447F5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFD8C9EB),
                                  width: 2,
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.zap, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$costXp',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF756B91),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ]
                  // STEP 2: CONFIRMATION
                  else ...[
                    const Text(
                      'Confirm Purchase',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF241642),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF756B91),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Fredoka',
                        ),
                        children: [
                          const TextSpan(
                            text: 'Are you sure you want to spend ',
                          ),
                          TextSpan(
                            text:
                                '${pendingCurrency == 'coins' ? costCoins : costXp} ${pendingCurrency == 'coins' ? 'Coins' : 'XP'}',
                            style: TextStyle(
                              color: pendingCurrency == 'coins'
                                  ? const Color(0xFFD89400)
                                  : const Color(0xFF7447F5),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(text: ' on ${reward['title']}?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              AudioService().playSfx('btn_click.wav');
                              if (canAffordCoins && canAffordXp) {
                                // Go back to selection step if they had a choice
                                setDialogState(() => pendingCurrency = null);
                              } else {
                                // Close dialog if they didn't have a choice
                                Navigator.pop(context, null);
                              }
                            },
                            child: Text(
                              (canAffordCoins && canAffordXp)
                                  ? 'Back'
                                  : 'Cancel',
                              style: const TextStyle(
                                color: Color(0xFF756B91),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context, pendingCurrency),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF28C995),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );

    if (selectedCurrency == null) return;

    setState(() => _isClaiming = true);

    final int actualCoinDeduction = selectedCurrency == 'coins' ? costCoins : 0;
    final int actualXpDeduction = selectedCurrency == 'xp' ? costXp : 0;

    ChildStatsService().deduct(
      costCoins: actualCoinDeduction,
      costXp: actualXpDeduction,
    );

    try {
      await HttpClient().dio.post(
        '/api/rewards/${reward['id']}/claim',
        data: {'currency': selectedCurrency},
      );
      AudioService().playSfx('scan_success.wav');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase successful! Waiting for approval.'),
            backgroundColor: Color(0xFF28C995),
          ),
        );
        widget.onSuccess();
      }
    } on DioException catch (e) {
      AudioService().playSfx('scan_fail.wav');

      ChildStatsService().updateStats(
        newCoins: ChildStatsService().coins.value + actualCoinDeduction,
        newXp: ChildStatsService().xp.value + actualXpDeduction,
      );

      final errorMsg = e.response?.data['error'] ?? 'Could not claim reward.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: const Color(0xFFFF6578),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reward = widget.reward;
    final int costCoins = (reward['coin_cost'] as num?)?.toInt() ?? 0;
    final int costXp = (reward['xp_cost'] as num?)?.toInt() ?? 0;

    return Container(
      width: 160,
      height: 280,
      padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(reward['icon'], style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              child: Text(
                reward['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF241642),
                  height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (costCoins > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.coins,
                      size: 14,
                      color: Color(0xFFD89400),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$costCoins',
                      style: const TextStyle(
                        color: Color(0xFFD89400),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              if (costXp > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.zap,
                      size: 14,
                      color: Color(0xFF7447F5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$costXp',
                      style: const TextStyle(
                        color: Color(0xFF7447F5),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                ChildStatsService().coins,
                ChildStatsService().xp,
              ]),
              builder: (context, _) {
                final bool canAffordCoins =
                    costCoins > 0 &&
                    ChildStatsService().coins.value >= costCoins;
                final bool canAffordXp =
                    costXp > 0 && ChildStatsService().xp.value >= costXp;

                final bool canAfford = canAffordCoins || canAffordXp;
                final bool isDisabled = _isClaiming || !canAfford;

                return ElevatedButton(
                  onPressed: isDisabled ? null : _claimReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF172033),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE8DEF5),
                    disabledForegroundColor: const Color(0xFFA49AB4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isClaiming
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          canAfford ? 'BUY' : 'LOCKED',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
