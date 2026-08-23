import 'package:flutter/material.dart';
import 'package:mobile_web/core/widgets/shimmer_effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../addresses/presentation/bloc/addresses_bloc.dart';
import '../../../addresses/presentation/bloc/addresses_event.dart';
import '../../../addresses/presentation/bloc/addresses_state.dart';
import 'add_new_address_screen.dart';

class ManageAddressesScreen extends StatelessWidget {
  const ManageAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AddressesBloc>()..add(const GetAddressesRequested()),
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          title: Text('Manage Addresses', style: AppTextStyles.h4),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocBuilder<AddressesBloc, AddressesState>(
          builder: (context, state) {
            if (state is AddressesLoaded && state.isLoading) {
              return const GenericListShimmer();
            }
            final addresses = state is AddressesLoaded ? state.addresses ?? [] : [];
            
            if (addresses.isEmpty) {
              return Center(
                child: Text('No addresses found', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final addr = addresses[index];
                final isDefault = addr['isDefault'] ?? false;
                final label = addr['label'] ?? 'Address';
                final line1 = addr['line1'] ?? '';
                final line2 = addr['line2'];
                final city = addr['city'] ?? '';
                final stateName = addr['state'] ?? '';
                final pincode = addr['pincode'] ?? '';
                
                final fullAddressStr = [
                  line1,
                  if (line2 != null && line2.isNotEmpty) line2,
                  '$city, $stateName $pincode',
                ].join('\n');

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isDefault ? Border.all(color: AppColors.primary500, width: 1.5) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(label.toLowerCase() == 'home' ? LucideIcons.home : LucideIcons.briefcase, color: AppColors.primary500, size: 20),
                              const SizedBox(width: 8),
                              Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                              if (isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.primary50, borderRadius: BorderRadius.circular(4)),
                                  child: Text('Default', style: AppTextStyles.caption.copyWith(color: AppColors.primary600, fontWeight: FontWeight.w700)),
                                ),
                              ]
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(LucideIcons.moreVertical, size: 20),
                            onSelected: (value) {
                              if (value == 'delete') {
                                context.read<AddressesBloc>().add(DeleteAddressRequested(addr['id']));
                              } else if (value == 'set_default') {
                                context.read<AddressesBloc>().add(UpdateAddressRequested(addr['id'], {'isDefault': true}));
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'set_default',
                                child: Text('Set as Default'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(fullAddressStr, style: AppTextStyles.bodySmall.copyWith(height: 1.5, color: AppColors.neutral700)),
                    ],
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  text: 'Add New Address',
                  icon: LucideIcons.plus,
                  onPressed: () async {
                    // Navigate to add new address screen
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<AddressesBloc>(), child: const AddNewAddressScreen())));
                    if (result == true && context.mounted) context.read<AddressesBloc>().add(const GetAddressesRequested());
                  },
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
