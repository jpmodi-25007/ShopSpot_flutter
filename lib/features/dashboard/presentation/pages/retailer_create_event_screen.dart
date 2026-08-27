import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

class RetailerCreateEventScreen extends StatefulWidget {
  const RetailerCreateEventScreen({super.key});

  @override
  State<RetailerCreateEventScreen> createState() => _RetailerCreateEventScreenState();
}

class _RetailerCreateEventScreenState extends State<RetailerCreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;
  final CloudinaryService _cloudinary = getIt<CloudinaryService>();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart 
        ? (_startDate ?? DateTime.now()) 
        : (_endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 1)));
        
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.roleRetailer,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates')),
        );
        return;
      }
      
      String? imageUrl;
      
      if (_selectedImage != null) {
        setState(() => _isUploading = true);
        try {
          if (!kIsWeb) {
            final result = await _cloudinary.uploadImage(
              imageFile: File(_selectedImage!.path),
              folder: 'events',
            );
            imageUrl = result.secureUrl;
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed')));
          setState(() => _isUploading = false);
          return;
        }
        setState(() => _isUploading = false);
      }
      
      context.read<EventBloc>().add(
        CreateEventRequested(
          title: _titleController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          startDate: _startDate!,
          endDate: _endDate!,
          imageUrl: imageUrl ?? 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: Text('Create Shop Event', style: AppTextStyles.h3),
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event created successfully!'), backgroundColor: AppColors.roleRetailer),
            );
            context.read<EventBloc>().add(const GetEventsRequested()); // Refresh feed
            context.pop();
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message), backgroundColor: AppColors.error500),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster Upload Placeholder
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral300, style: BorderStyle.solid),
                      image: _selectedImage != null && !kIsWeb
                          ? DecorationImage(
                              image: FileImage(File(_selectedImage!.path)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.imagePlus, size: 48, color: AppColors.neutral400),
                              const SizedBox(height: 12),
                              Text('Upload Event Poster', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                              Text('16:9 ratio recommended', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                            ],
                          )
                        : const SizedBox(),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Form Fields
                Text('Event Details', style: AppTextStyles.h4),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    hintText: 'e.g. Summer Mega Sale',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.roleRetailer)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this event about?',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.roleRetailer)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'In-store or Online link',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.roleRetailer)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Dates
                Text('Duration & Expiry', style: AppTextStyles.h4),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neutral300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                              const SizedBox(height: 4),
                              Text(
                                _startDate != null ? DateFormat('MMM d, yyyy').format(_startDate!) : 'Select Date',
                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neutral300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expiry Date', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                              const SizedBox(height: 4),
                              Text(
                                _endDate != null ? DateFormat('MMM d, yyyy').format(_endDate!) : 'Select Date',
                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                
                // Submit Button
                BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is EventCreating || _isUploading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.roleRetailer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: state is EventCreating || _isUploading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Post Event', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
