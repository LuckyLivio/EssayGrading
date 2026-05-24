import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/providers/app_providers.dart';
import 'result_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    var history = storage.getHistory();

    if (_searchQuery.isNotEmpty) {
      history = history.where((r) => r.title.contains(_searchQuery) || r.answerText.contains(_searchQuery)).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('批改历史')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索题目或作答内容...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('暂无历史记录', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final record = history[index];
                      final scoreColor = record.result.score < 60 ? Colors.red : (record.result.score < 80 ? Colors.orange : Colors.green);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('作答时间：${DateFormat('yyyy-MM-dd HH:mm').format(record.createdAt)}'),
                              const SizedBox(height: 4),
                              Text('评级：${record.result.level}', style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: Text(
                            '${record.result.score}',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: scoreColor),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ResultScreen(record: record)),
                            );
                          },
                          onLongPress: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('删除记录'),
                                content: const Text('确定要删除这条批改记录吗？'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('删除'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await storage.deleteHistory(record.id);
                              setState(() {}); // refresh
                            }
                          },
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
