import 'package:flutter/material.dart';
import '../services/daily_challenge_service.dart';
import '../models/daily_challenge.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challenge = DailyChallengeService().getDailyChallenge();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              challenge.description,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Start challenge
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}