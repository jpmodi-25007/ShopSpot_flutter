import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../addresses/presentation/bloc/addresses_bloc.dart';
import '../../../addresses/presentation/bloc/addresses_event.dart';
import '../../../addresses/presentation/bloc/addresses_state.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  String _selectedLabel = 'Home';
  bool _isDefault = false;

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'label': _selectedLabel,
        'line1': _line1Controller.text.trim(),
        'line2': _line2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'isDefault': _isDefault,
      };
      context.read<AddressesBloc>().add(CreateAddressRequested(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressesBloc, AddressesState>(
      listener: (context, state) {
        if (state is AddressesLoaded && state.isSuccess) {
          Navigator.pop(context, true);
        } else if (state is AddressesLoaded && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure!.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          title: Text('Add New Address', style: AppTextStyles.h4),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Address Label', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLabelOption('Home', LucideIcons.home),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLabelOption('Work', LucideIcons.briefcase),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLabelOption('Other', LucideIcons.mapPin),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                AppTextField(
                  label: 'Address Line 1',
                  hintText: 'House/Flat No., Building Name',
                  controller: _line1Controller,
                  validator: (val) => ValidationUtils.validateRequired(val, fieldName: 'Address Line 1'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Address Line 2 (Optional)',
                  hintText: 'Street, Sector, Landmark',
                  controller: _line2Controller,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'City',
                        hintText: 'e.g. Mumbai',
                        controller: _cityController,
                        validator: (val) => ValidationUtils.validateRequired(val, fieldName: 'City'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        label: 'Pincode',
                        hintText: 'e.g. 400001',
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        validator: (val) => ValidationUtils.validateRequired(val, fieldName: 'Pincode'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'State',
                  hintText: 'e.g. Maharashtra',
                  controller: _stateController,
                  validator: (val) => ValidationUtils.validateRequired(val, fieldName: 'State'),
                ),
                const SizedBox(height: 24),
                
                SwitchListTile(
                  title: Text('Make this my default address', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('This will be auto-selected for future orders', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                  value: _isDefault,
                  onChanged: (val) => setState(() => _isDefault = val),
                  activeThumbColor: AppColors.primary500,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<AddressesBloc, AddressesState>(
              builder: (context, state) {
                final isLoading = state is AddressesLoaded ? state.isLoading : false;
                return AppButton(
                  text: 'Save Address',
                  onPressed: _submit,
                  isLoading: isLoading,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelOption(String label, IconData icon) {
    final isSelected = _selectedLabel == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedLabel = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.neutral200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary500 : AppColors.neutral500, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary600 : AppColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
