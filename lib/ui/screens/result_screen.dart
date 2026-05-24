import 'package:flutter/material.dart';
import '../../data/models/history_record.dart';

class ResultScreen extends StatelessWidget {
  final HistoryRecord record;

  const ResultScreen({Key? key, required this.record}) : super(key: key);

  Color _getScoreColor(int score) {
    if (score < 60) return Colors.red;
    if (score < 80) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final result = record.result;
    final scoreColor = _getScoreColor(result.score);

    return Scaffold(
      appBar: AppBar(title: const Text('批改结果')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 分数区
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${result.score}',
                        style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: scoreColor),
                      ),
                      const Text('/100', style: TextStyle(fontSize: 24, color: Colors.grey)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scoreColor),
                    ),
                    child: Text(
                      result.level,
                      style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 要点覆盖
            if (result.keypoints.isNotEmpty) ...[
              _buildSectionTitle('要点覆盖'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: result.keypoints.map((kp) {
                      final isHit = kp.status == '命中';
                      final isPartial = kp.status == '部分命中';
                      final color = isHit ? Colors.green : (isPartial ? Colors.orange : Colors.red);
                      final icon = isHit ? Icons.check_circle : (isPartial ? Icons.info : Icons.cancel);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, color: color, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(kp.point, style: const TextStyle(fontSize: 15)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(kp.status, style: TextStyle(color: color, fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildSectionTitle('结构评价'),
            _buildCardText(result.structure),
            const SizedBox(height: 16),

            _buildSectionTitle('语言表达'),
            _buildCardText(result.expression),
            const SizedBox(height: 16),

            _buildSectionTitle('改进建议'),
            _buildCardText(result.suggestions),
            const SizedBox(height: 16),

            _buildSectionTitle('优化示例'),
            _buildCardText(result.examplerewrite),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildCardText(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
      ),
    );
  }
}
