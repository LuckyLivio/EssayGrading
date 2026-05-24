import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/app_providers.dart';
import '../../data/models/question.dart';
import '../../data/models/history_record.dart';
import 'result_screen.dart';

class GradingScreen extends ConsumerStatefulWidget {
  final Question? initialQuestion;
  
  const GradingScreen({Key? key, this.initialQuestion}) : super(key: key);

  @override
  ConsumerState<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends ConsumerState<GradingScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isProcessing = false;
  String _processStatus = '';

  Question? _selectedQuestion;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedQuestion = widget.initialQuestion ?? mockQuestions.first;
  }

  Future<void> _pickImage(ImageSource source) async {
    final storage = ref.read(storageServiceProvider);
    if (storage.getApiKey().isEmpty) {
      _showSettingsReminder();
      return;
    }
    
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        _processOCR();
      }
    } catch (e) {
      _showError('获取图片失败: $e');
    }
  }

  void _showSettingsReminder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要配置 API Key'),
        content: const Text('在使用 AI 批改功能前，请先在“设置”中配置您的 API Key。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Note: In a real app we'd navigate to the settings tab
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请点击底部导航栏的“设置”进行配置')),
              );
            },
            child: const Text('去配置'),
          ),
        ],
      ),
    );
  }

  Future<void> _processOCR() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
      _processStatus = '正在识别文字...';
    });

    try {
      final ocrService = ref.read(ocrServiceProvider);
      final text = await ocrService.recognizeText(_image!.path);
      setState(() {
        _textController.text = text;
      });
      _showEditTextDialog();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showEditTextDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('确认识别内容'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: _textController,
            maxLines: 15,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '识别结果将显示在这里，您可以手动修改。',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGrading();
            },
            child: const Text('开始批改'),
          ),
        ],
      ),
    );
  }

  Future<void> _startGrading() async {
    if (_textController.text.trim().isEmpty) {
      _showError('作答内容不能为空');
      return;
    }

    setState(() {
      _isProcessing = true;
      _processStatus = 'AI 专家正在阅卷中...';
    });

    try {
      final storage = ref.read(storageServiceProvider);
      final aiService = ref.read(aiServiceProvider);

      final result = await aiService.gradeEssay(
        apiUrl: storage.getApiUrl(),
        apiKey: storage.getApiKey(),
        model: storage.getModel(),
        questionType: _selectedQuestion!.type,
        questionText: _selectedQuestion!.content,
        answerText: _textController.text,
        strictness: storage.getStrictness(),
      );

      // Save to history
      final record = HistoryRecord(
        title: _selectedQuestion!.title,
        questionType: _selectedQuestion!.type,
        answerText: _textController.text,
        result: result,
      );
      await storage.addHistory(record);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(record: record),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('申论批改官'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      extendBodyBehindAppBar: false,
      body: _isProcessing
          ? Container(
              width: double.infinity,
              color: Colors.white.withOpacity(0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(strokeWidth: 6),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _processStatus,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('这可能需要几十秒，请稍候...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 题目选择区
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.library_books, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('选择题目', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Question>(
                          value: _selectedQuestion,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          ),
                          items: mockQuestions.map((q) {
                            return DropdownMenuItem(
                              value: q,
                              child: Text(q.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedQuestion = val;
                            });
                          },
                        ),
                        if (_selectedQuestion != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedQuestion!.content,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 拍照引导区
                  Column(
                    children: [
                      const Text(
                        '准备好你的答卷了吗？',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '请确保光线充足，字迹清晰',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      
                      // 拍照大按钮
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.camera),
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withBlue(255),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.4),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_enhance, size: 56, color: Colors.white),
                              SizedBox(height: 8),
                              Text('拍照识别', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // 辅助选项
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickAction(
                            icon: Icons.photo_library,
                            label: '从相册选',
                            onTap: () => _pickImage(ImageSource.gallery),
                          ),
                          const SizedBox(width: 40),
                          _buildQuickAction(
                            icon: Icons.history,
                            label: '查看历史',
                            onTap: () {
                              // Switch to history tab (this is a bit hacky since it's in a tab bar)
                              // For now, let's just show a tip or navigate if possible
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('请通过底部导航栏进入历史记录')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
