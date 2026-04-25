import 'package:flutter/material.dart';
import 'package:klaro/models/module_upload.dart';
import 'package:klaro/screens/teacher_module_upload_screen.dart';
import 'package:klaro/services/firestore_service.dart';
import 'package:klaro/utils/theme.dart';
import 'package:klaro/widgets/translatable_text.dart';

/// ============================================================
/// Teacher Modules Screen
/// ============================================================
/// Lists all modules uploaded by the teacher

class TeacherModulesScreen extends StatefulWidget {
  final String teacherId;

  const TeacherModulesScreen({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherModulesScreen> createState() => _TeacherModulesScreenState();
}

class _TeacherModulesScreenState extends State<TeacherModulesScreen> {
  final _firestoreService = FirestoreService();
  List<ModuleUpload> _modules = [];
  bool _isLoading = true;
  String _filterSubject = 'All';

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() => _isLoading = true);

    try {
      final modules = await _firestoreService.getTeacherModules(widget.teacherId);
      if (mounted) {
        setState(() {
          _modules = modules;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading modules: $e'),
            backgroundColor: KlaroTheme.error,
          ),
        );
      }
    }
  }

  List<ModuleUpload> get _filteredModules {
    if (_filterSubject == 'All') return _modules;
    return _modules.where((m) => m.subject == _filterSubject).toList();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ['All', ...{'Science', 'English', 'Mathematics'}];

    return Scaffold(
      backgroundColor: KlaroTheme.surfaceLight,
      appBar: AppBar(
        title: TranslatableText('My Modules'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadModules,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Chips
                Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      final isSelected = _filterSubject == subject;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(subject),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _filterSubject = subject);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: KlaroTheme.primaryBlue.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? KlaroTheme.primaryBlue : KlaroTheme.textDark,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Module List
                Expanded(
                  child: _filteredModules.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredModules.length,
                          itemBuilder: (context, index) {
                            return _buildModuleCard(_filteredModules[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherModuleUploadScreen(teacherId: widget.teacherId),
            ),
          );
          if (result == true) {
            _loadModules();
          }
        },
        backgroundColor: KlaroTheme.primaryBlue,
        icon: Icon(Icons.add),
        label: TranslatableText('New Module'),
      ),
    );
  }

  Widget _buildModuleCard(ModuleUpload module) {
    final subjectColor = _getSubjectColor(module.subject);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: subjectColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    module.subject,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: subjectColor,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  module.gradeLevel,
                  style: TextStyle(
                    fontSize: 11,
                    color: KlaroTheme.textMuted,
                  ),
                ),
                if (module.quarter != null) ...[
                  SizedBox(width: 8),
                  Text(
                    module.quarter!,
                    style: TextStyle(
                      fontSize: 11,
                      color: KlaroTheme.textMuted,
                    ),
                  ),
                ],
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: module.isPublished
                        ? KlaroTheme.success.withValues(alpha: 0.1)
                        : KlaroTheme.textMuted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        module.isPublished ? Icons.visibility : Icons.visibility_off,
                        size: 12,
                        color: module.isPublished ? KlaroTheme.success : KlaroTheme.textMuted,
                      ),
                      SizedBox(width: 4),
                      Text(
                        module.isPublished ? 'Published' : 'Draft',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: module.isPublished ? KlaroTheme.success : KlaroTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: KlaroTheme.textDark,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  module.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: KlaroTheme.textMuted,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (module.keyTerms.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: module.keyTerms.take(3).map((term) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: KlaroTheme.lightBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          term,
                          style: TextStyle(
                            fontSize: 11,
                            color: KlaroTheme.primaryBlue,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: KlaroTheme.textMuted),
                    SizedBox(width: 4),
                    Text(
                      _formatDate(module.updatedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: KlaroTheme.textMuted,
                      ),
                    ),
                    Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherModuleUploadScreen(
                              teacherId: widget.teacherId,
                              existingModule: module,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadModules();
                        }
                      },
                      icon: Icon(Icons.edit, size: 16),
                      label: TranslatableText('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: KlaroTheme.primaryBlue,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(module),
                      icon: Icon(Icons.delete, size: 16),
                      label: TranslatableText('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: KlaroTheme.error,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: KlaroTheme.textMuted.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          TranslatableText(
            _filterSubject == 'All' ? 'No modules yet' : 'No modules for $_filterSubject',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: KlaroTheme.textMuted,
            ),
          ),
          SizedBox(height: 8),
          TranslatableText(
            'Create your first module to get started',
            style: TextStyle(
              fontSize: 14,
              color: KlaroTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'science':
        return KlaroTheme.primaryBlue;
      case 'english':
        return Color(0xFF0F766E);
      case 'mathematics':
        return Color(0xFF7C3AED);
      default:
        return KlaroTheme.textDark;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _confirmDelete(ModuleUpload module) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatableText('Delete Module'),
        content: TranslatableText(
          'Are you sure you want to delete "${module.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: TranslatableText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: KlaroTheme.error,
            ),
            child: TranslatableText('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteModule(widget.teacherId, module.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Module deleted successfully'),
              backgroundColor: KlaroTheme.success,
            ),
          );
          _loadModules();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting module: $e'),
              backgroundColor: KlaroTheme.error,
            ),
          );
        }
      }
    }
  }
}
