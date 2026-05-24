import 'package:flutter/material.dart';
import '../../data/models/question.dart';
import 'grading_screen.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({Key? key}) : super(key: key);

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  String _selectedType = '全部';
  String _selectedYear = '全部';

  List<Question> get filteredQuestions {
    return mockQuestions.where((q) {
      if (_selectedType != '全部' && q.type != _selectedType) return false;
      if (_selectedYear != '全部' && q.year != _selectedYear) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('题库')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: '题型', border: OutlineInputBorder()),
                    items: ['全部', '归纳概括', '公文写作', '大作文'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedYear,
                    decoration: const InputDecoration(labelText: '年份', border: OutlineInputBorder()),
                    items: ['全部', '2023', '2022', '2021'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _selectedYear = v!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredQuestions.length,
              itemBuilder: (context, index) {
                final q = filteredQuestions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(q.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTag(q.type, Colors.blue),
                            const SizedBox(width: 8),
                            _buildTag(q.year, Colors.orange),
                            const SizedBox(width: 8),
                            _buildTag(q.province, Colors.green),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GradingScreen(initialQuestion: q),
                        ),
                      );
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
