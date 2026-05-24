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
        const SnackBar(content: Text('设置已保存')),
      );
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除数据'),
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
          const SnackBar(content: Text('数据已清除')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI 接口配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiUrlController,
                    decoration: const InputDecoration(
                      labelText: 'API 地址',
                      hintText: AppConstants.defaultApiUrl,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '请填写完整接口地址，不要只填域名。\nOpenAI: https://api.openai.com/v1/chat/completions\nDeepSeek: https://api.deepseek.com/v1/chat/completions',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: '模型名称',
                      hintText: AppConstants.defaultModel,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('批改严格程度', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('宽松')),
                      ButtonSegment(value: 1, label: Text('适中')),
                      ButtonSegment(value: 2, label: Text('严格')),
                    ],
                    selected: {_strictness},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        _strictness = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('保存设置'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _clearData,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清除所有数据'),
          ),
        ],
      ),
    );
  }
}
