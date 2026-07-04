import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import 'package:field_track/app/theme/app_colors.dart';
import 'package:field_track/app/theme/app_text_styles.dart';
import 'package:field_track/core/widgets/app_button.dart';
import 'package:field_track/core/widgets/app_text_field.dart';
import 'package:field_track/features/locations/domain/entities/location.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/features/locations/presentation/bloc/location_event.dart';
import 'package:field_track/features/locations/presentation/bloc/location_state.dart';

/// Add / Edit location screen — Figma Screen 05 & 06.
class AddEditLocationScreen extends StatefulWidget {
  final GeoLocation? existingLocation;

  const AddEditLocationScreen({super.key, this.existingLocation});

  bool get isEditing => existingLocation != null;

  @override
  State<AddEditLocationScreen> createState() => _AddEditLocationScreenState();
}

class _AddEditLocationScreenState extends State<AddEditLocationScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late double _radius;
  late bool _isActive;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    final loc = widget.existingLocation;
    _nameController = TextEditingController(text: loc?.locationName ?? '');
    _latController =
        TextEditingController(text: loc != null ? '${loc.latitude}' : '');
    _lngController =
        TextEditingController(text: loc != null ? '${loc.longitude}' : '');
    _radius = loc?.radiusM ?? 150;
    _isActive = loc?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(4);
        _lngController.text = position.longitude.toStringAsFixed(4);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (name.isEmpty || lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (widget.isEditing) {
      context.read<LocationBloc>().add(LocationUpdateRequested(
            id: widget.existingLocation!.id,
            locationName: name,
            latitude: lat,
            longitude: lng,
            radiusM: _radius,
            isActive: _isActive,
          ));
    } else {
      context.read<LocationBloc>().add(LocationAddRequested(
            locationName: name,
            latitude: lat,
            longitude: lng,
            radiusM: _radius,
            isActive: _isActive,
          ));
    }
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete location'),
        content:
            const Text('Are you sure you want to delete this location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LocationBloc>().add(
                    LocationDeleteRequested(
                        id: widget.existingLocation!.id),
                  );
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is LocationActionSuccess) {
          context.pop();
        } else if (state is LocationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ─── Header ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_back_ios_new, size: 16,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.isEditing ? 'Edit location' : 'New location',
                      style: AppTextStyles.heading3.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Body ───────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Map preview placeholder
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.pin_drop_rounded,
                              size: 34, color: AppColors.primary),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Use current location
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isLoadingLocation ? null : _useCurrentLocation,
                          icon: _isLoadingLocation
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Icon(Icons.my_location, size: 17),
                          label: const Text('Use my current location',
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSurface,
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Location name
                      AppTextField(
                        label: 'Location name',
                        hintText: 'Downtown Branch',
                        controller: _nameController,
                      ),

                      const SizedBox(height: 14),

                      // Lat / Lng side by side
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Latitude',
                              hintText: '25.2048',
                              controller: _latController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Longitude',
                              hintText: '55.2708',
                              controller: _lngController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Geofence radius slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Geofence radius',
                              style: AppTextStyles.fieldLabel.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              )),
                          Text('${_radius.toInt()} m',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                              )),
                        ],
                      ),
                      Slider(
                        value: _radius,
                        min: 50,
                        max: 500,
                        divisions: 45,
                        activeColor: AppColors.primary,
                        inactiveColor: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        onChanged: (v) => setState(() => _radius = v),
                      ),

                      const SizedBox(height: 8),

                      // Active toggle
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Active',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    )),
                                const SizedBox(height: 2),
                                Text('Workers can check in here',
                                    style: AppTextStyles.caption.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    )),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (v) =>
                                setState(() => _isActive = v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Save / Update button
                      BlocBuilder<LocationBloc, LocationState>(
                        builder: (context, state) {
                          return AppButton.primary(
                            text: widget.isEditing
                                ? 'Update location'
                                : 'Save location',
                            isLoading: state is LocationLoading,
                            onPressed: _onSave,
                          );
                        },
                      ),

                      // Delete button (edit mode only)
                      if (widget.isEditing) ...[
                        const SizedBox(height: 12),
                        AppButton.destructive(
                          text: 'Delete location',
                          icon: Icons.delete_outline,
                          onPressed: _onDelete,
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
