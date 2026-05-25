import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/app_providers.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  int _strictness = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final storage = ref.read(storageServiceProvider);
    _apiUrlController.text = storage.getApiUrl();
    _apiKeyController.text = storage.getApiKey();
    _modelController.text = storage.getModel();
    _strictness = storage.getStrictness();
  }

  Future<void> _saveSettings() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setApiUrl(_apiUrlController.text.trim());
    await storage.setApiKey(_apiKeyController.text.trim());
    await storage.setModel(_modelController.text.trim());
    await storage.setStrictness(_strictness);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('设置已保存'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
            const SizedBox(width: 12),
            const Text('清除数据'),
          ],
        ),
        content: const Text('确定要清除所有设置和历史记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(storageServiceProvider).clearAllData();
      _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('数据已清除'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '设置',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              title: 'AI 接口配置',
              icon: Icons.smart_toy_outlined,
              children: [
                TextField(
                  controller: _apiUrlController,
                  decoration: InputDecoration(
                    labelText: 'API 地址',
                    hintText: AppConstants.defaultApiUrl,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '请填写完整接口地址，包含 /v1/chat/completions\nOpenAI: https://api.openai.com/v1/chat/completions\nDeepSeek: https://api.deepseek.com/v1/chat/completions',
                          style: TextStyle(fontSize: 12, color: Colors.blue[700], height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    suffixIcon: Icon(Icons.visibility_off, color: Colors.grey[400]),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    labelText: '模型名称',
                    hintText: AppConstants.defaultModel,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: '批改严格程度',
              icon: Icons.speed_outlined,
              children: [
                _buildStrictnessOption(0, '宽松', '评分较为宽松，适合新手练习', Icons.sentiment_satisfied_outlined, const Color(0xFF10B981)),
                const SizedBox(height: 12),
                _buildStrictnessOption(1, '适中', '平衡评分标准', Icons.balance_outlined, const Color(0xFF3B82F6)),
                const SizedBox(height: 12),
                _buildStrictnessOption(2, '严格', '高标准评分要求', Icons.sentiment_very_dissatisfied_outlined, const Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                '保存设置',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _clearData,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '清除所有数据',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Text(
                    '申论批改官 v1.0.0',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '基于 AI 智能批改技术',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStrictnessOption(int value, String label, String description, IconData icon, Color color) {
    final isSelected = _strictness == value;
    return GestureDetector(
      onTap: () => setState(() => _strictness = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color.withAlpha(30) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? color : const Color(0xFF9CA3AF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected ? color : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 26),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }
}