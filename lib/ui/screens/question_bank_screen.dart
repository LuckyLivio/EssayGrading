import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/question.dart';
import '../../data/providers/app_providers.dart';
import 'grading_screen.dart';

class QuestionBankScreen extends ConsumerStatefulWidget {
  const QuestionBankScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends ConsumerState<QuestionBankScreen> {
  String _selectedType = '全部';
  String _selectedYear = '全部';
  String _selectedProvince = '全部';
  bool _showUserQuestions = true;

  List<Question> get allQuestions {
    final storage = ref.read(storageServiceProvider);
    final userQs = _showUserQuestions ? storage.getUserQuestions() : <Question>[];
    return [...builtInQuestions, ...userQs];
  }

  List<Question> get filteredQuestions {
    return allQuestions.where((q) {
      if (_selectedType != '全部' && q.type != _selectedType) return false;
      if (_selectedYear != '全部' && q.year != _selectedYear) return false;
      if (_selectedProvince != '全部' && q.province != _selectedProvince) return false;
      return true;
    }).toList();
  }

  Future<void> _searchOnline() async {
    final query = '$_selectedType申论真题$_selectedYear$_selectedProvince'.trim();
    final url = Uri.parse('https://www.baidu.com/s?wd=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showAddQuestionDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedType = questionTypes.first;
    String selectedYear = questionYears.first;
    String selectedProvince = questionProvinces.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('上传自定义题目'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '题目名称',
                    hintText: '例如：概括乡村振兴的主要做法',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '题目内容',
                    hintText: '请输入完整的题目要求和给定资料...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: '题型', border: OutlineInputBorder()),
                  items: questionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedYear,
                        decoration: const InputDecoration(labelText: '年份', border: OutlineInputBorder()),
                        items: questionYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                        onChanged: (v) => setDialogState(() => selectedYear = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedProvince,
                        decoration: const InputDecoration(labelText: '来源', border: OutlineInputBorder()),
                        items: questionProvinces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (v) => setDialogState(() => selectedProvince = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('题目名称和内容不能为空')),
                  );
                  return;
                }
                final question = Question.create(
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  type: selectedType,
                  year: selectedYear,
                  province: selectedProvince,
                );
                await ref.read(storageServiceProvider).addUserQuestion(question);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('题目已添加')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    final userQs = storage.getUserQuestions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('题库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '联网搜索题目',
            onPressed: _searchOnline,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '上传自定义题目',
            onPressed: _showAddQuestionDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: '题型',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        items: ['全部', ...questionTypes].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _selectedType = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          labelText: '年份',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        items: ['全部', ...questionYears].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _selectedYear = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedProvince,
                        decoration: const InputDecoration(
                          labelText: '来源',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        items: ['全部', ...questionProvinces].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _selectedProvince = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      label: Text('自定义题目 (${userQs.length})'),
                      selected: _showUserQuestions,
                      onSelected: (v) => setState(() => _showUserQuestions = v),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '共 ${filteredQuestions.length} 道',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredQuestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('暂无符合条件的题目', style: TextStyle(color: Colors.grey[400])),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('上传自定义题目'),
                          onPressed: _showAddQuestionDialog,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final q = filteredQuestions[index];
                      return Dismissible(
                        key: Key(q.id),
                        direction: q.isUserAdded ? DismissDirection.endToStart : DismissDirection.none,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (!q.isUserAdded) return false;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('删除题目'),
                              content: const Text('确定要删除这条自定义题目吗？'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('删除'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await storage.deleteUserQuestion(q.id);
                            setState(() {});
                          }
                          return false;
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GradingScreen(initialQuestion: q),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          q.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                      if (q.isUserAdded)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            '自定义',
                                            style: TextStyle(color: Colors.purple, fontSize: 10),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    q.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _buildTag(q.type, Colors.blue),
                                      const SizedBox(width: 6),
                                      _buildTag(q.year, Colors.orange),
                                      const SizedBox(width: 6),
                                      _buildTag(q.province, Colors.green),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
