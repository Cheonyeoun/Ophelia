import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout_metrics.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';

/// The Settings root tab — matches the "Settings" frame in
/// docs/design/ophelia-ui-mockup-2.html. Playback/download/server rows
/// are decorative (no SettingsPort exists yet to persist them); Export
/// and Import library call the real use cases.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _gaplessPlayback = true;
  bool _wifiOnlyDownloads = true;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final bottomInset = ref.watch(bottomContentInsetProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(bottom: 24 + bottomInset),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Text('Settings', style: frauncesStyle(fontSize: 16)),
          ),
          profile.maybeWhen(
            data: (data) => data == null
                ? const SizedBox.shrink()
                : _ProfileRow(
                    displayName: data.displayName,
                    onTap: () => context.push('/profile'),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const _SectionLabel('Playback'),
          const _SettingRow(
            icon: Icons.equalizer_outlined,
            label: 'Streaming quality',
            value: 'High',
          ),
          _SettingRow(
            icon: Icons.auto_awesome_outlined,
            label: 'Gapless playback',
            toggleValue: _gaplessPlayback,
            onToggle: (v) => setState(() => _gaplessPlayback = v),
          ),
          const _SectionLabel('Downloads'),
          const _SettingRow(
            icon: Icons.high_quality_outlined,
            label: 'Download quality',
            value: 'Lossless',
          ),
          _SettingRow(
            icon: Icons.wifi_outlined,
            label: 'Wi-Fi only downloads',
            toggleValue: _wifiOnlyDownloads,
            onToggle: (v) => setState(() => _wifiOnlyDownloads = v),
          ),
          _SettingRow(
            icon: Icons.download_outlined,
            label: 'View downloads',
            onTap: () => context.push('/downloads'),
          ),
          const _SectionLabel('Media source'),
          const _SettingRow(
            icon: Icons.dns_outlined,
            label: 'Connected server',
            value: 'Home library',
          ),
          const _SectionLabel('Your data'),
          _SettingRow(
            icon: Icons.upload_outlined,
            label: 'Export library',
            onTap: () => ref.read(exportLibraryProvider)(),
          ),
          _SettingRow(
            icon: Icons.download_for_offline_outlined,
            label: 'Import library',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String displayName;
  final VoidCallback onTap;

  const _ProfileRow({required this.displayName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.ink2,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.pale),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mist),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.mist)),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.value,
    this.toggleValue,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.paleDim),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.pale)),
            ),
            if (value != null)
              Text(value!, style: const TextStyle(fontSize: 12, color: AppColors.mist)),
            if (toggleValue != null)
              Switch(
                value: toggleValue!,
                onChanged: onToggle,
                activeTrackColor: AppColors.willow,
              ),
          ],
        ),
      ),
    );
  }
}
