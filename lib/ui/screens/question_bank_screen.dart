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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '上传自定义题目',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: '题目名称',
                    hintText: '例如：概括乡村振兴的主要做法',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: '题目内容',
                    hintText: '请输入完整的题目要求和给定资料...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: '题型',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: questionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => selectedType = v!,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedYear,
                        decoration: InputDecoration(
                          labelText: '年份',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: questionYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                        onChanged: (v) => selectedYear = v!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedProvince,
                        decoration: InputDecoration(
                          labelText: '来源',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: questionProvinces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (v) => selectedProvince = v!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('取消', style: TextStyle(color: Colors.grey[600])),
                    ),
                    const SizedBox(width: 12),
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    final userQs = storage.getUserQuestions();
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '题库中心',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[700]),
            tooltip: '联网搜索题目',
            onPressed: _searchOnline,
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: primaryColor),
            tooltip: '上传自定义题目',
            onPressed: _showAddQuestionDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown('题型', _selectedType, ['全部', ...questionTypes], (v) => setState(() => _selectedType = v!)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterDropdown('年份', _selectedYear, ['全部', ...questionYears], (v) => setState(() => _selectedYear = v!)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterDropdown('来源', _selectedProvince, ['全部', ...questionProvinces], (v) => setState(() => _selectedProvince = v!)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showUserQuestions = !_showUserQuestions),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _showUserQuestions ? primaryColor.withAlpha(26) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _showUserQuestions ? primaryColor : const Color(0xFFD1D5DB),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showUserQuestions ? Icons.check_circle : Icons.circle_outlined,
                              size: 18,
                              color: _showUserQuestions ? primaryColor : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '自定义题目 (${userQs.length})',
                              style: TextStyle(
                                fontSize: 13,
                                color: _showUserQuestions ? primaryColor : const Color(0xFF6B7280),
                                fontWeight: _showUserQuestions ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '共 ${filteredQuestions.length} 道',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredQuestions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final q = filteredQuestions[index];
                      return Dismissible(
                        key: Key(q.id),
                        direction: q.isUserAdded ? DismissDirection.endToStart : DismissDirection.none,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        confirmDismiss: (direction) async {
                          if (!q.isUserAdded) return false;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        child: _buildQuestionCard(q),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[500]),
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question q) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GradingScreen(initialQuestion: q),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    q.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A1A), height: 1.3),
                  ),
                ),
                if (q.isUserAdded)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '自定义',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              q.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildTag(q.type, const Color(0xFF3B82F6)),
                const SizedBox(width: 8),
                _buildTag(q.year, const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _buildTag(q.province, const Color(0xFF10B981)),
                const Spacer(),
                Icon(Icons.chevron_right, color: Colors.grey[300], size: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          Text(
            '暂无符合条件的题目',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试调整筛选条件或上传自定义题目',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _showAddQuestionDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('上传自定义题目'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}