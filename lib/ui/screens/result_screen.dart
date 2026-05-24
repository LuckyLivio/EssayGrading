import 'package:flutter/material.dart';
import '../../data/models/history_record.dart';
import '../../core/theme/app_theme.dart';

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
      appBar: AppBar(
        title: const Text('批改结果'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Implement share
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能开发中...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 分数区
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: 180,
                height: 180,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: result.score / 100,
                          strokeWidth: 12,
                          backgroundColor: scoreColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${result.score}',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                              Text(
                                '/100',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: scoreColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              result.level,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 要点覆盖
            if (result.keypoints.isNotEmpty) ...[
              _buildSectionTitle('要点覆盖', Icons.checklist_rtl),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: result.keypoints.map((kp) {
                      final isHit = kp.status == '命中';
                      final isPartial = kp.status == '部分命中';
                      final color = isHit ? Colors.green : (isPartial ? Colors.orange : Colors.red);
                      final icon = isHit ? Icons.check_circle : (isPartial ? Icons.info : Icons.cancel);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, color: color, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                kp.point, 
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isHit ? Colors.black87 : Colors.black54,
                                  fontWeight: isHit ? FontWeight.w500 : FontWeight.normal,
                                )
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              kp.status, 
                              style: TextStyle(
                                color: color, 
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            _buildSectionTitle('结构评价', Icons.account_tree_outlined),
            _buildCardText(result.structure),
            const SizedBox(height: 20),

            _buildSectionTitle('语言表达', Icons.translate),
            _buildCardText(result.expression),
            const SizedBox(height: 20),

            _buildSectionTitle('改进建议', Icons.lightbulb_outline),
            _buildCardText(result.suggestions),
            const SizedBox(height: 20),

            _buildSectionTitle('优化示例', Icons.auto_awesome_outlined),
            _buildExampleRewrite(result.examplerewrite),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleRewrite(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.format_quote, color: Colors.blueGrey, size: 16),
              SizedBox(width: 4),
              Text('示范文本', style: TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.blueGrey[900],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardText(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
        ),
      ),
    );
  }
}
