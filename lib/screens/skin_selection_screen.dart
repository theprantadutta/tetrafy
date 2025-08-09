import 'package:flutter/material.dart';
import '../models/block_skin.dart';
import '../main.dart';
import '../services/preferences_service.dart';
import '../main.dart';

class SkinSelectionScreen extends StatelessWidget {
  const SkinSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Skin'),
      ),
      body: ListView(
        children: BlockSkin.values
            .map(
              (skin) => ListTile(
                title: Text(skin.toString().split('.').last),
                onTap: () {
                  blockSkinNotifier.value = skin;
                  PreferencesService().setSkin(skin.toString().split('.').last);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}