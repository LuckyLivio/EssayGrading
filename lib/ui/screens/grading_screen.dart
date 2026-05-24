import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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
  String _recognizedText = '';
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
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        await _cropImage(pickedFile.path);
      }
    } catch (e) {
      _showError('获取图片失败: $e');
    }
  }

  Future<void> _cropImage(String path) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪图片',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          IOSUiSettings(
            title: '裁剪图片',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
        _processOCR();
      }
    } catch (e) {
      _showError('裁剪图片失败: $e');
    }
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
        _recognizedText = text;
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
      appBar: AppBar(title: const Text('申论批改官')),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_processStatus, style: const TextStyle(fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('选择题目', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Question>(
                    value: _selectedQuestion,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            _selectedQuestion?.content ?? '',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: InkWell(
                      onTap: () => _pickImage(ImageSource.camera),
                      borderRadius: BorderRadius.circular(64),
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, size: 64, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(child: Text('点击拍照上传手写答案', style: TextStyle(fontSize: 16, color: Colors.grey))),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('从相册选择'),
                  ),
                ],
              ),
            ),
    );
  }
}
