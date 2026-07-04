import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:field_track/app/theme/app_colors.dart';
import 'package:field_track/app/theme/app_text_styles.dart';
import 'package:field_track/core/widgets/status_badge.dart';
import 'package:field_track/features/locations/domain/entities/location.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/features/locations/presentation/bloc/location_event.dart';
import 'package:field_track/features/locations/presentation/bloc/location_state.dart';

/// Locations list screen — Figma Screen 04.
class LocationsListScreen extends StatefulWidget {
  const LocationsListScreen({super.key});

  @override
  State<LocationsListScreen> createState() => _LocationsListScreenState();
}

class _LocationsListScreenState extends State<LocationsListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(const LocationsFetchRequested());
  }

  List<GeoLocation> _filterLocations(List<GeoLocation> locations) {
    if (_searchQuery.isEmpty) return locations;
    return locations
        .where((l) =>
            l.locationName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Locations',
                      style: AppTextStyles.heading1.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  _buildAddButton(isDark),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Search ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(isDark),
            ),

            const SizedBox(height: 12),

            // ─── List ──────────────────────────────────────
            Expanded(
              child: BlocBuilder<LocationBloc, LocationState>(
                builder: (context, state) {
                  if (state is LocationLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is LocationError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48,
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight),
                          const SizedBox(height: 12),
                          Text(state.message,
                              style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context
                                .read<LocationBloc>()
                                .add(const LocationsFetchRequested()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is LocationLoaded) {
                    final filtered = _filterLocations(state.locations);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pin_drop_outlined,
                                size: 48,
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight),
                            const SizedBox(height: 12),
                            Text('No locations found',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                )),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildLocationCard(filtered[index], isDark),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/locations/new'),
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/locations/new'),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.add, size: 20,
            color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: AppTextStyles.input.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search locations',
          hintStyle: AppTextStyles.inputHint.copyWith(
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          prefixIcon: Icon(Icons.search, size: 18,
              color: isDark ? AppColors.iconDark : AppColors.iconLight),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLocationCard(GeoLocation location, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/locations/${location.id}/edit',
          extra: location),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            // Pin icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pin_drop_rounded,
                  color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(location.locationName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.my_location, size: 13,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight),
                      const SizedBox(width: 6),
                      Text(location.formattedCoordinates,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StatusBadge.neutral(text: location.formattedRadius),
                      const SizedBox(width: 7),
                      location.isActive
                          ? const StatusBadge.active(text: 'Active')
                          : const StatusBadge.inactive(text: 'Inactive'),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, size: 18,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight),
          ],
        ),
      ),
    );
  }
}
