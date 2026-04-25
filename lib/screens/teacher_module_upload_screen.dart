import 'package:flutter/material.dart';
import 'package:klaro/models/module_upload.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';
import 'package:uuid/uuid.dart';

/// ============================================================
/// Teacher Module Upload Screen
/// ============================================================
/// Allows teachers to create and upload custom learning modules

class TeacherModuleUploadScreen extends StatefulWidget {
  final String teacherId;
  final ModuleUpload? existingModule;

  const TeacherModuleUploadScreen({
    super.key,
    required this.teacherId,
    this.existingModule,
  });

  @override
  State<TeacherModuleUploadScreen> createState() => _TeacherModuleUploadScreenState();
}

class _TeacherModuleUploadScreenState extends State<TeacherModuleUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;
  late TextEditingController _keyTermsController;
  late TextEditingController _objectivesController;

  String _selectedSubject = 'Science';
  String _selectedGrade = 'Grade 7';
  String? _selectedQuarter;
  bool _isPublished = false;
  bool _isLoading = false;

  final List<String> _subjects = ['Science', 'English', 'Mathematics'];
  final List<String> _grades = ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'];
  final List<String> _quarters = ['Quarter 1', 'Quarter 2', 'Quarter 3', 'Quarter 4'];

  @override
  void initState() {
    super.initState();
    final module = widget.existingModule;
    
    _titleController = TextEditingController(text: module?.title ?? '');
    _descriptionController = TextEditingController(text: module?.description ?? '');
    _contentController = TextEditingController(text: module?.content ?? '');
    _keyTermsController = TextEditingController(
      text: module?.keyTerms.join(', ') ?? '',
    );
    _objectivesController = TextEditingController(
      text: module?.learningObjectives.join(', ') ?? '',
    );

    if (module != null) {
      _selectedSubject = module.subject;
      _selectedGrade = module.gradeLevel;
      _selectedQuarter = module.quarter;
      _isPublished = module.isPublished;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _keyTermsController.dispose();
    _objectivesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: TranslatableText(
          widget.existingModule == null ? 'Upload New Module' : 'Edit Module',
        ),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // Title
            TranslatableText(
              'Module Title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KlaroTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g., The Water Cycle',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Subject and Grade Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatableText(
                        'Subject',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        items: _subjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSubject = value!);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatableText(
                        'Grade Level',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KlaroTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        items: _grades.map((grade) {
                          return DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedGrade = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Quarter (Optional)
            TranslatableText(
              'Quarter (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KlaroTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedQuarter,
              decoration: InputDecoration(
                hintText: 'Select quarter',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text('None')),
                ..._quarters.map((quarter) {
                  return DropdownMenuItem(
                    value: quarter,
                    child: Text(quarter),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedQuarter = value);
              },
            ),
            SizedBox(height: 20),

            // Description
            TranslatableText(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KlaroTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Brief description of the module',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Content
            TranslatableText(
              'Module Content',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KlaroTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Enter the full lesson content here...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter module content';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Key Terms
            TranslatableText(
              'Key Terms (comma-separated)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KlaroTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _keyTermsController,
              decoration: InputDecoration(
                hintText: 'e.g., evaporation, condensation, precipitation',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Learning Objectives
            TranslatableText(
              'Learning Objectives (comma-separated)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KlaroTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _objectivesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Understand the water cycle, Identify stages of water transformation',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Publish Toggle
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatableText(
                          'Publish Module',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: KlaroTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        TranslatableText(
                          'Make this module visible to students',
                          style: TextStyle(
                            fontSize: 12,
                            color: KlaroTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPublished,
                    onChanged: (value) {
                      setState(() => _isPublished = value);
                    },
                    activeColor: KlaroTheme.primaryBlue,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveModule,
              style: ElevatedButton.styleFrom(
                backgroundColor: KlaroTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: TranslatableText(
                widget.existingModule == null ? 'Upload Module' : 'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _saveModule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final keyTerms = _keyTermsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final objectives = _objectivesController.text
          .split(',')
          .map((o) => o.trim())
          .where((o) => o.isNotEmpty)
          .toList();

      final module = ModuleUpload(
        id: widget.existingModule?.id ?? Uuid().v4(),
        teacherId: widget.teacherId,
        title: _titleController.text.trim(),
        subject: _selectedSubject,
        gradeLevel: _selectedGrade,
        description: _descriptionController.text.trim(),
        content: _contentController.text.trim(),
        keyTerms: keyTerms,
        learningObjectives: objectives,
        createdAt: widget.existingModule?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isPublished: _isPublished,
        quarter: _selectedQuarter,
      );

      if (widget.existingModule == null) {
        await _firestoreService.createModule(module);
      } else {
        await _firestoreService.updateModule(module);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingModule == null
                  ? 'Module uploaded successfully!'
                  : 'Module updated successfully!',
            ),
            backgroundColor: KlaroTheme.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: KlaroTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
