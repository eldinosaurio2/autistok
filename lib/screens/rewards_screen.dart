import 'package:autistock/services/reward_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Recompensas'),
      ),
      body: Consumer<RewardService>(
        builder: (context, rewardService, child) {
          final rewards = rewardService.rewards;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.9,
            ),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return Card(
                elevation: reward.unlocked ? 8.0 : 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: reward.unlocked
                        ? Colors.amber.shade700
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                color: reward.unlocked ? Colors.amber.shade50 : Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      reward.unlocked ? Icons.emoji_events : Icons.lock,
                      size: 60,
                      color: reward.unlocked
                          ? Colors.amber.shade800
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        reward.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              reward.unlocked ? Colors.black87 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        reward.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
