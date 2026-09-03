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

import '../../domain/entities/event_entity.dart';

class RetailerCreateEventScreen extends StatefulWidget {
  final EventEntity? eventToEdit;
  const RetailerCreateEventScreen({super.key, this.eventToEdit});

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


  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _titleController.text = widget.eventToEdit!.title;
      _descriptionController.text = widget.eventToEdit!.description ?? '';
      _locationController.text = widget.eventToEdit!.location ?? '';
      _startDate = widget.eventToEdit!.startDate;
      _endDate = widget.eventToEdit!.endDate;
      // We can't set _selectedImage from network URL easily without downloading, 
      // so if they want to keep the old image they don't pick a new one.
    }
  }


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
          final result = await _cloudinary.uploadImage(
            imageFile: _selectedImage!,
            folder: 'events',
          );
          imageUrl = result.secureUrl;
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
          imageUrl: imageUrl, // null is valid — no image selected
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: Text('Create Shop Event', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event created successfully!'), backgroundColor: AppColors.success600),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          physics: const BouncingScrollPhysics(),
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
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.roleRetailerLight.withValues(alpha: 0.3),
                          AppColors.neutral50,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.roleRetailerLight, width: 2),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: kIsWeb 
                                  ? NetworkImage(_selectedImage!.path) 
                                  : FileImage(File(_selectedImage!.path)) as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.roleRetailer.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ]
                    ),
                    child: _selectedImage == null
                        ? (widget.eventToEdit != null && widget.eventToEdit!.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(widget.eventToEdit!.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              )
                            : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neutral900.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    )
                                  ]
                                ),
                                child: const Icon(LucideIcons.imagePlus, size: 32, color: AppColors.roleRetailer),
                              ),
                              const SizedBox(height: 16),
                              Text('Upload Event Poster', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('16:9 ratio recommended', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                            ],
                          ))
                        : const SizedBox(),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Form Fields
                Text('Event Details', style: AppTextStyles.h3),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _titleController,
                  label: 'Event Title',
                  hint: 'e.g. Summer Mega Sale',
                  icon: LucideIcons.type,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'What is this event about?',
                  icon: LucideIcons.alignLeft,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'In-store or Online link',
                  icon: LucideIcons.mapPin,
                ),
                const SizedBox(height: 32),
                
                // Dates
                Text('Duration & Expiry', style: AppTextStyles.h3),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: _buildDateCard('Start Date', _startDate),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: _buildDateCard('Expiry Date', _endDate),
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
                          elevation: 0,
                          shadowColor: AppColors.roleRetailer.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: state is EventCreating || _isUploading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Post Event', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.5)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral400),
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 10).toDouble() : 0),
            child: Icon(icon, color: AppColors.roleRetailer, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDateCard(String label, DateTime? date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: date != null ? AppColors.roleRetailer : AppColors.neutral200, width: date != null ? 1.5 : 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: AppColors.neutral500),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date != null ? DateFormat('MMM d, yyyy').format(date) : 'Select Date',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: date != null ? AppColors.neutral900 : AppColors.neutral400
            ),
          ),
        ],
      ),
    );
  }
}
