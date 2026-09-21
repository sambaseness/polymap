import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/campus_gps.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';

/// Real campus map using OpenStreetMap tiles via flutter_map.
///
/// Replaces the schematic CampusMap with a real geographic map.
/// Falls back to the schematic on web if tiles don't load.
class RealCampusMap extends StatefulWidget {
  const RealCampusMap({
    super.key,
    this.showUserPosition = true,
    this.onBuildingTap,
    this.routePoints,
    this.routeColor,
  });

  final bool showUserPosition;
  final void Function(BuildingGps building)? onBuildingTap;
  final List<LatLng>? routePoints;
  final Color? routeColor;

  @override
  State<RealCampusMap> createState() => _RealCampusMapState();
}

class _RealCampusMapState extends State<RealCampusMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Color _buildingMarkerColor(BuildingColor color, PmColors pm) {
    return switch (color) {
      BuildingColor.blue => pm.blue,
      BuildingColor.brown => pm.brown,
      BuildingColor.ochre => pm.ochre,
      BuildingColor.green => pm.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: CampusGps.campusCenter,
        initialZoom: 17.0,
        minZoom: 15.0,
        maxZoom: 19.0,
        onMapReady: () {},
        onTap: (_, __) => _mapController.move(
            _mapController.camera.center, _mapController.camera.zoom),
      ),
      children: [
        // OpenStreetMap tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.polymap.esp',
          maxZoom: 19,
        ),

        // Route polyline
        if (widget.routePoints != null && widget.routePoints!.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routePoints!,
                color: widget.routeColor ?? pm.blue,
                strokeWidth: 4.0,
                borderStrokeWidth: 2.0,
                borderColor: pm.surf,
              ),
            ],
          ),

        // Building markers
        MarkerLayer(
          markers: [
            // User position marker
            if (widget.showUserPosition)
              Marker(
                point: CampusGps.userPosition,
                width: 40,
                height: 40,
                child: _UserMarker(pm: pm),
              ),

            // Building markers
            for (final building in CampusGps.buildings)
              Marker(
                point: building.position,
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => widget.onBuildingTap?.call(building),
                  child: _BuildingMarker(
                    building: building,
                    color: _buildingMarkerColor(building.color, pm),
                    pm: pm,
                  ),
                ),
              ),
          ],
        ),

        // Attribution
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              textStyle: PmText.sans(10, color: pm.ink2),
            ),
          ],
        ),
      ],
    );
  }
}

/// Blue pulsing dot for user position.
class _UserMarker extends StatelessWidget {
  const _UserMarker({required this.pm});
  final PmColors pm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pm.blue.withValues(alpha: 0.3),
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pm.blue,
              border: Border.all(color: pm.surf, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

/// Building marker with colored icon and label.
class _BuildingMarker extends StatelessWidget {
  const _BuildingMarker({
    required this.building,
    required this.color,
    required this.pm,
  });

  final BuildingGps building;
  final Color color;
  final PmColors pm;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Building icon
        Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: pm.surf, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: pm.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                building.short.split('\n').first,
                style: PmText.sans(8, weight: FontWeight.w600, color: pm.surf),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        // Building name label (only for larger buildings)
        if (building.short.length > 6)
          Positioned(
            bottom: -18,
            left: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: pm.surf.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                building.short.split('\n').first,
                style: PmText.sans(7, color: pm.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
