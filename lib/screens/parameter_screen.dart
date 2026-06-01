import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pose_provider.dart';
import '../theme/app_theme.dart';
import 'pose_overlay_screen.dart';

class ParameterScreen extends ConsumerStatefulWidget {
  const ParameterScreen({super.key});

  @override
  ConsumerState<ParameterScreen> createState() => _ParameterScreenState();
}

class _ParameterScreenState extends ConsumerState<ParameterScreen> {
  final List<String> _ageGroups = ['儿童', '青少年', '青年', '中年', '老年', '混合'];
  final List<String> _styles = ['休闲', '正式', '创意'];

  @override
  Widget build(BuildContext context) {
    final poseNotifier = ref.read(poseProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        title: const Text('设置参数'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // People count
            _sectionTitle('合影人数', Icons.people),
            const SizedBox(height: 8),
            _buildPeopleCounter(poseNotifier),

            const SizedBox(height: 28),

            // Age group
            _sectionTitle('年龄段', Icons.person_outline),
            const SizedBox(height: 8),
            _buildChipRow(
              _ageGroups,
              poseNotifier.ageGroup,
              (v) => poseNotifier.setAgeGroup(v),
            ),

            const SizedBox(height: 28),

            // Style
            _sectionTitle('合影风格', Icons.style),
            const SizedBox(height: 8),
            _buildChipRow(
              _styles,
              poseNotifier.style,
              (v) => poseNotifier.setStyle(v),
            ),

            const Spacer(),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  poseNotifier.generatePoses();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PoseOverlayScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                ),
                child: const Text('生成姿势指引', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textPrimary),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildPeopleCounter(PoseNotifier notifier) {
    final count = notifier.peopleCount;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 36),
            color: count > 1 ? AppTheme.primaryDark : AppTheme.disabled,
            onPressed: count > 1 ? () {
              setState(() { notifier.setPeopleCount(count - 1); });
            } : null,
          ),

          SizedBox(
            width: 80,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 36),
            color: count < 20 ? AppTheme.primaryDark : AppTheme.disabled,
            onPressed: count < 20 ? () {
              setState(() { notifier.setPeopleCount(count + 1); });
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(List<String> items, String selected, void Function(String) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = item == selected;
        return GestureDetector(
          onTap: () => setState(() => onSelect(item)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.primaryBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
