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

class _GradingScreenState extends ConsumerState<GradingScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isProcessing = false;
  String _processStatus = '';
  Question? _selectedQuestion;
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedQuestion = widget.initialQuestion ?? builtInQuestions.first;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 28),
            const SizedBox(width: 12),
            const Text('需要配置 API Key'),
          ],
        ),
        content: const Text('在使用 AI 批改功能前，请先在"设置"中配置您的 API Key。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请点击底部导航栏的"设置"进行配置')),
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
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showEditTextDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                    child: Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '确认识别内容',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: '识别结果将显示在这里，您可以手动修改。',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('取消', style: TextStyle(color: Colors.grey[600])),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startGrading();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('开始批改'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withAlpha(13),
              Colors.white,
            ],
          ),
        ),
        child: _isProcessing
            ? _buildProcessingView()
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildQuestionCard(),
                      const SizedBox(height: 32),
                      _buildCameraSection(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '申论批改',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'AI 智能批改，让学习更高效',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  color: primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz_outlined, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 14),
              const Text(
                '选择题目',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Question>(
                value: _selectedQuestion,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[500]),
                items: builtInQuestions.map((q) {
                  return DropdownMenuItem(
                    value: q,
                    child: Text(
                      q.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedQuestion = val;
                  });
                },
              ),
            ),
          ),
          if (_selectedQuestion != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildInfoChip(_selectedQuestion!.type, const Color(0xFF3B82F6)),
                      const SizedBox(width: 10),
                      _buildInfoChip(_selectedQuestion!.year, const Color(0xFFF59E0B)),
                      const SizedBox(width: 10),
                      _buildInfoChip(_selectedQuestion!.province, const Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _selectedQuestion!.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildCameraSection() {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        const SizedBox(height: 20),
        ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, Color(primaryColor.value + 0x330000)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha(102),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 64, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    '拍照识别',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '准备好你的答卷了吗？',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '请确保光线充足，字迹清晰',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.photo_library_outlined,
          label: '从相册选',
          onTap: () => _pickImage(ImageSource.gallery),
        ),
        const SizedBox(width: 40),
        _buildActionButton(
          icon: Icons.edit_note_rounded,
          label: '手动输入',
          onTap: () {
            _textController.clear();
            _showEditTextDialog();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF374151), size: 26),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _processStatus,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '这可能需要几十秒，请稍候...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}